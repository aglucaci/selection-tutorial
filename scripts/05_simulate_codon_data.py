#!/usr/bin/env python3
"""Simulate codon data with known omega regimes for the HyPhy workshop."""

from __future__ import annotations

from pathlib import Path
import json
import random

import pyvolve


OUT_DIR = Path("data/simulated")
ALIGNMENT = OUT_DIR / "simulated_codon_blocks.fna"
TREE = OUT_DIR / "simulated_tree.nwk"
LABELED_ALIGNMENT = OUT_DIR / "simulated_codon_blocks_labeled.fna"
TRUTH = OUT_DIR / "simulated_truth.json"


def main() -> None:
    random.seed(2026)
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    tree_text = (
        "((taxon01:0.08,taxon02:0.08):0.05,"
        "(taxon03:0.07,taxon04:0.07):0.06,"
        "(taxon05:0.06,(taxon06:0.04,taxon07:0.04):0.03):0.04,"
        "taxon08:0.10);"
    )
    TREE.write_text(tree_text + "\n", encoding="utf-8")

    partitions = [
        ("purifying", 60, 0.15),
        ("neutral_like", 60, 1.0),
        ("positive_enriched", 60, 2.5),
    ]

    tree = pyvolve.read_tree(tree=tree_text)
    pyvolve_partitions = []
    start = 1
    truth_blocks = []
    for name, length, omega in partitions:
        model = pyvolve.Model("codon", {"omega": omega})
        pyvolve_partitions.append(pyvolve.Partition(models=model, size=length))
        truth_blocks.append(
            {
                "name": name,
                "start_codon": start,
                "end_codon": start + length - 1,
                "omega": omega,
            }
        )
        start += length

    evolver = pyvolve.Evolver(partitions=pyvolve_partitions, tree=tree)
    evolver(seqfile=str(ALIGNMENT), seqfmt="fasta", ratefile=None, infofile=None)

    # Keep a companion copy for exercises that need the simulated alignment in a
    # separate path.
    LABELED_ALIGNMENT.write_text(ALIGNMENT.read_text(encoding="utf-8"), encoding="utf-8")

    TRUTH.write_text(
        json.dumps(
            {
                "alignment": str(ALIGNMENT),
                "tree": str(TREE),
                "blocks": truth_blocks,
                "note": "Sites are codon positions; use this truth table when comparing FEL/MEME calls.",
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    print(f"Wrote {ALIGNMENT}")
    print(f"Wrote {TREE}")
    print(f"Wrote {TRUTH}")


if __name__ == "__main__":
    main()
