#!/usr/bin/env python3
"""Summarize bundled empirical alignments for the tutorial notebooks."""

from __future__ import annotations

import csv
from itertools import combinations
from pathlib import Path
import re
from statistics import mean


DATA_DIR = Path("data/21-empirical")
OUT_CSV = Path("data/empirical_alignment_metrics.csv")
DNA_BASES = set("ACGT")
MISSING = set("?N-")

def empirical_paths(data_dir: Path) -> list[Path]:
    return sorted(
        path
        for path in data_dir.iterdir()
        if path.is_file()
        and path.name != OUT_CSV.name
        and path.suffix in {".nex", ".mtnex"}
    )


def parse_nexus_matrix(path: Path) -> tuple[list[tuple[str, str]], str]:
    text = path.read_text(encoding="utf-8", errors="replace")
    records: list[tuple[str, str]] = []
    in_matrix = False

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        upper = line.upper()
        if upper.startswith("MATRIX"):
            in_matrix = True
            line = line[6:].strip()
            if not line:
                continue
        if not in_matrix:
            continue
        if line.startswith(";") or upper.startswith("END;"):
            break
        if line.startswith("["):
            continue

        line = line.rstrip(";").strip()
        match = re.match(r"^'([^']+)'\s+([A-Za-z?\-]+)$", line)
        if not match:
            match = re.match(r"^(\S+)\s+([A-Za-z?\-]+)$", line)
        if match:
            records.append((match.group(1), match.group(2).upper()))

    return records, text


def matrix_columns(sequences: list[str], length: int) -> list[list[str]]:
    return [[seq[index] if index < len(seq) else "?" for seq in sequences] for index in range(length)]


def variable_site_count(columns: list[list[str]]) -> int:
    count = 0
    for column in columns:
        states = {base for base in column if base in DNA_BASES}
        if len(states) > 1:
            count += 1
    return count


def parsimony_informative_count(columns: list[list[str]]) -> int:
    count = 0
    for column in columns:
        state_counts = {base: column.count(base) for base in DNA_BASES}
        informative_states = [base for base, base_count in state_counts.items() if base_count >= 2]
        if len(informative_states) >= 2:
            count += 1
    return count


def pairwise_identity(sequences: list[str]) -> float | None:
    identities: list[float] = []
    for left, right in combinations(sequences, 2):
        comparable = 0
        matches = 0
        for a, b in zip(left, right):
            if a in MISSING or b in MISSING:
                continue
            comparable += 1
            if a == b:
                matches += 1
        if comparable:
            identities.append(100 * matches / comparable)
    return mean(identities) if identities else None


def row_for_path(path: Path) -> dict[str, str | int | float]:
    records, text = parse_nexus_matrix(path)
    sequences = [sequence for _, sequence in records]
    nt_sites = max((len(sequence) for sequence in sequences), default=0)
    total_chars = sum(len(sequence) for sequence in sequences)
    acgt = sum(sequence.count(base) for sequence in sequences for base in "ACGT")
    gc = sum(sequence.count(base) for sequence in sequences for base in "GC")
    gaps = sum(sequence.count("-") for sequence in sequences)
    ambiguous = sum(sum(1 for char in sequence if char not in "ACGT-") for sequence in sequences)
    columns = matrix_columns(sequences, nt_sites)
    variable_sites = variable_site_count(columns)
    parsimony_sites = parsimony_informative_count(columns)
    identity = pairwise_identity(sequences)
    taxa = [taxon for taxon, _ in records]

    return {
        "dataset": path.name,
        "sequences": len(sequences),
        "unique_sequences": len(set(sequences)),
        "nt_sites": nt_sites,
        "codon_sites": nt_sites // 3 if nt_sites and nt_sites % 3 == 0 else "",
        "multiple_of_3": "yes" if nt_sites and nt_sites % 3 == 0 else "no",
        "gc_percent": round(100 * gc / acgt, 2) if acgt else "",
        "gap_percent": round(100 * gaps / total_chars, 2) if total_chars else "",
        "ambiguous_percent": round(100 * ambiguous / total_chars, 2) if total_chars else "",
        "variable_sites": variable_sites,
        "variable_sites_percent": round(100 * variable_sites / nt_sites, 2) if nt_sites else "",
        "parsimony_informative_sites": parsimony_sites,
        "parsimony_informative_sites_percent": round(100 * parsimony_sites / nt_sites, 2) if nt_sites else "",
        "mean_pairwise_identity_percent": round(identity, 2) if identity is not None else "",
        "tree_present": "yes" if "BEGIN TREES" in text.upper() else "no",
        "taxon_names_unique": "yes" if len(taxa) == len(set(taxa)) else "no",
        "file_size_kb": round(path.stat().st_size / 1024, 1),
    }


def main() -> None:
    rows = [row_for_path(path) for path in empirical_paths(DATA_DIR)]
    if not rows:
        raise SystemExit(f"No empirical Nexus files found in {DATA_DIR}")

    with OUT_CSV.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)

    print(f"Wrote {OUT_CSV}")


if __name__ == "__main__":
    main()
