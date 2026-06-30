#!/usr/bin/env python3
"""Download a public codon alignment and matching phylogenetic tree.

The default source is HyPhy's public command-line tutorial archive. The script scans
the downloaded files for codon-aware alignments, pairs them with an embedded or
standalone Newick tree, validates basic codon properties, and writes normalized outputs:

  data/22-empirical/codon_tree/alignment.fna
  data/22-empirical/codon_tree/tree.nwk
  data/22-empirical/codon_tree/metadata.json
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from io import BytesIO
import json
from pathlib import Path
import re
import shutil
import sys
import tempfile
from urllib.request import urlopen
import zipfile


DEFAULT_URL = "https://www.hyphy.org/resources/tutorials/hyphy-cmd-tutorial.zip"
DEFAULT_OUTDIR = Path("data/22-empirical/codon_tree")
STOP_CODONS = {"TAA", "TAG", "TGA"}
DNA = set("ACGTNRYKMSWBDHV?-")


@dataclass
class Alignment:
    path: Path
    records: list[tuple[str, str]]


@dataclass
class TreeHit:
    path: Path
    newick: str
    source: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Download a codon-aware alignment and matching phylogenetic tree."
    )
    parser.add_argument("--url", default=DEFAULT_URL, help="Zip archive URL to scan.")
    parser.add_argument(
        "--dataset",
        default=None,
        help="Prefer files whose name contains this text, for example lysin or hiv1.",
    )
    parser.add_argument(
        "--outdir",
        type=Path,
        default=DEFAULT_OUTDIR,
        help="Directory for normalized alignment, tree, and metadata.",
    )
    parser.add_argument(
        "--keep-workdir",
        type=Path,
        default=None,
        help="Optional directory where the downloaded archive is extracted for inspection.",
    )
    return parser.parse_args()


def download_zip(url: str) -> bytes:
    print(f"Downloading {url}")
    with urlopen(url, timeout=60) as response:
        return response.read()


def extract_zip(payload: bytes, workdir: Path) -> None:
    with zipfile.ZipFile(BytesIO(payload)) as archive:
        archive.extractall(workdir)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def sanitize_name(name: str) -> str:
    name = name.strip()
    name = re.sub(r"[\s,;:()]+", "_", name)
    return name.strip("_") or "unnamed_taxon"


def parse_fasta(path: Path) -> Alignment | None:
    records: list[tuple[str, str]] = []
    name: str | None = None
    chunks: list[str] = []

    for raw in read_text(path).splitlines():
        line = raw.strip()
        if not line:
            continue
        if line.startswith(">"):
            if name is not None:
                records.append((sanitize_name(name), "".join(chunks).upper()))
            name = line[1:].strip().split()[0]
            chunks = []
        elif name is not None:
            seq = re.sub(r"\s+", "", line).upper()
            if set(seq) <= DNA:
                chunks.append(seq)

    if name is not None:
        records.append((sanitize_name(name), "".join(chunks).upper()))

    return Alignment(path, records) if records else None


def parse_nexus_matrix(path: Path) -> Alignment | None:
    text = read_text(path)
    match = re.search(r"matrix(.*?);", text, flags=re.IGNORECASE | re.DOTALL)
    if not match:
        return None

    records: list[tuple[str, str]] = []
    for raw in match.group(1).splitlines():
        line = raw.strip()
        if not line or line.startswith("["):
            continue
        parts = line.split()
        if len(parts) < 2:
            continue
        name, seq = parts[0], "".join(parts[1:]).upper()
        if set(seq) <= DNA:
            records.append((sanitize_name(name), seq))

    return Alignment(path, records) if records else None


def parse_alignment(path: Path) -> Alignment | None:
    suffix = path.suffix.lower()
    if suffix in {".fna", ".fa", ".fas", ".fasta"}:
        return parse_fasta(path)
    if suffix in {".nex", ".nexus"}:
        return parse_nexus_matrix(path)
    return None


def has_internal_stops(seq: str) -> bool:
    ungapped = seq.replace("-", "").replace("?", "").replace("N", "")
    for i in range(0, len(ungapped) - 3, 3):
        codon = ungapped[i : i + 3]
        if len(codon) == 3 and codon in STOP_CODONS:
            return True
    return False


def is_codon_alignment(aln: Alignment) -> tuple[bool, str]:
    if len(aln.records) < 4:
        return False, "fewer than four taxa"
    lengths = {len(seq) for _, seq in aln.records}
    if len(lengths) != 1:
        return False, "sequences are not aligned to equal length"
    length = next(iter(lengths))
    if length == 0 or length % 3 != 0:
        return False, "alignment length is not a positive multiple of three"
    bad = [name for name, seq in aln.records if has_internal_stops(seq)]
    if bad:
        return False, f"internal stop codons found in {', '.join(bad[:3])}"
    return True, "ok"


def normalize_newick(text: str) -> str:
    newick = " ".join(text.strip().split())
    if not newick.endswith(";"):
        newick += ";"
    return newick


def extract_newicks(path: Path) -> list[TreeHit]:
    text = read_text(path)
    hits: list[TreeHit] = []

    if path.suffix.lower() in {".nwk", ".tree", ".tre"}:
        stripped = text.strip()
        if "(" in stripped and ")" in stripped:
            hits.append(TreeHit(path, normalize_newick(stripped), "standalone"))
        return hits

    for match in re.finditer(
        r"(?:tree\s+[^=]+=\s*(?:\[&[^\]]+\]\s*)?)([^;]+;)",
        text,
        flags=re.IGNORECASE,
    ):
        hits.append(TreeHit(path, normalize_newick(match.group(1)), "nexus-tree"))

    for match in re.finditer(r"(\([^;\n]*:[^;\n]*\)[^;\n]*;)", text):
        hits.append(TreeHit(path, normalize_newick(match.group(1)), "embedded-newick"))

    return hits


def tree_taxa(newick: str) -> set[str]:
    masked = re.sub(r":[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", "", newick)
    tokens = re.findall(r"[A-Za-z0-9_.|/-]+", masked)
    reserved = {"tree", "utree"}
    return {sanitize_name(token) for token in tokens if token.lower() not in reserved}


def find_pair(workdir: Path, dataset: str | None) -> tuple[Alignment, TreeHit]:
    files = [path for path in workdir.rglob("*") if path.is_file()]
    alignments: list[Alignment] = []
    for path in files:
        aln = parse_alignment(path)
        if not aln:
            continue
        ok, reason = is_codon_alignment(aln)
        if ok:
            alignments.append(aln)
        else:
            print(f"Skipping {path.name}: {reason}")

    tree_hits: list[TreeHit] = []
    for path in files:
        tree_hits.extend(extract_newicks(path))

    if dataset:
        needle = dataset.lower()
        alignments.sort(key=lambda aln: (needle not in aln.path.name.lower(), aln.path.name))
        tree_hits.sort(key=lambda hit: (needle not in hit.path.name.lower(), hit.path.name))
    else:
        alignments.sort(key=lambda aln: aln.path.name)
        tree_hits.sort(key=lambda hit: hit.path.name)

    for aln in alignments:
        aln_taxa = {name for name, _ in aln.records}
        same_stem = [hit for hit in tree_hits if hit.path.stem == aln.path.stem]
        candidates = same_stem + [hit for hit in tree_hits if hit not in same_stem]
        for hit in candidates:
            overlap = aln_taxa & tree_taxa(hit.newick)
            if len(overlap) == len(aln_taxa):
                return aln, hit

    details = {
        "codon_alignments": [str(aln.path.relative_to(workdir)) for aln in alignments],
        "trees": [str(hit.path.relative_to(workdir)) for hit in tree_hits],
    }
    raise SystemExit(
        "Could not find a codon alignment with a matching tree.\n"
        + json.dumps(details, indent=2)
    )


def write_alignment(aln: Alignment, output: Path) -> None:
    with output.open("w", encoding="utf-8") as handle:
        for name, seq in aln.records:
            handle.write(f">{name}\n")
            for i in range(0, len(seq), 80):
                handle.write(seq[i : i + 80] + "\n")


def main() -> None:
    args = parse_args()

    if args.keep_workdir:
        workdir = args.keep_workdir
        workdir.mkdir(parents=True, exist_ok=True)
        cleanup = False
    else:
        tmp = tempfile.TemporaryDirectory()
        workdir = Path(tmp.name)
        cleanup = True

    try:
        payload = download_zip(args.url)
        extract_zip(payload, workdir)
        aln, tree = find_pair(workdir, args.dataset)

        args.outdir.mkdir(parents=True, exist_ok=True)
        alignment_out = args.outdir / "alignment.fna"
        tree_out = args.outdir / "tree.nwk"
        metadata_out = args.outdir / "metadata.json"

        write_alignment(aln, alignment_out)
        tree_out.write_text(tree.newick + "\n", encoding="utf-8")

        metadata = {
            "source_url": args.url,
            "requested_dataset": args.dataset,
            "source_alignment": str(aln.path.relative_to(workdir)),
            "source_tree": str(tree.path.relative_to(workdir)),
            "tree_source_type": tree.source,
            "taxa": len(aln.records),
            "nucleotides": len(aln.records[0][1]),
            "codons": len(aln.records[0][1]) // 3,
            "alignment": str(alignment_out),
            "tree": str(tree_out),
        }
        metadata_out.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")

        print("Wrote codon-aware dataset:")
        print(f"  alignment: {alignment_out}")
        print(f"  tree:      {tree_out}")
        print(f"  metadata:  {metadata_out}")
        print(
            f"Selected {metadata['source_alignment']} with {metadata['taxa']} taxa "
            f"and {metadata['codons']} codons."
        )
    finally:
        if cleanup:
            tmp.cleanup()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)
