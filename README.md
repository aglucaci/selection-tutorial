# EEBG2026 HyPhy Selection Tutorial

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/aglucaci/selection-tutorial/blob/main/notebooks/EEBG2026_HyPhy_Selection_Tutorial_Colab.ipynb)

Runnable workshop materials for teaching codon-based tests of molecular adaptation with
[HyPhy](https://www.hyphy.org/). The package combines command-line scripts, a Jupyter
notebook, bundled empirical data, simulation exercises, result parsing, plots, and short
student prompts.

## Contents

```text
.
├── README.md
├── environment.yml
├── scripts/
│   ├── 00_setup_conda.sh
│   ├── 00_setup_colab.sh
│   ├── 01_grab_codon_alignment_and_tree.py
│   ├── 01_download_tutorial_data.sh
│   ├── 02_run_gene_wide.sh
│   ├── 03_run_site_level.sh
│   ├── 04_run_branch_lineage.sh
│   ├── 05_simulate_codon_data.py
│   ├── 06_run_simulated_selection.sh
│   ├── 07_collect_results.py
│   └── 08_summarize_empirical_data.py
├── notebooks/
│   ├── EEBG2026_HyPhy_Selection_Tutorial.ipynb
│   └── EEBG2026_HyPhy_Selection_Tutorial_Colab.ipynb
└── docs/
    └── instructor_notes.md
```

Bundled empirical data and generated outputs are written to:

```text
data/22-empirical/
data/22-empirical/empirical_alignment_metrics.csv
data/simulated/
results/
tables/
figures/
```

## Quick start

### Google Colab

Use the Colab notebook when students do not have Conda or HyPhy installed locally:

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/aglucaci/selection-tutorial/blob/main/notebooks/EEBG2026_HyPhy_Selection_Tutorial_Colab.ipynb)

The first cells clone this repository into `/content/selection-tutorial`, install HyPhy
with `apt`, install Python dependencies with `pip`, verify the bundled empirical data,
and then run the same workshop scripts used by the local workflow.

### Local Conda

Install Conda or Mamba, then create the workshop environment:

```bash
bash scripts/00_setup_conda.sh
conda activate eebg2026-hyphy
```

Verify the bundled empirical data:

```bash
bash scripts/01_download_tutorial_data.sh
```

Run all analyses:

```bash
bash scripts/02_run_gene_wide.sh
bash scripts/03_run_site_level.sh
bash scripts/04_run_branch_lineage.sh
bash scripts/06_run_simulated_selection.sh
python scripts/07_collect_results.py
```

Open the notebook:

```bash
jupyter lab notebooks/EEBG2026_HyPhy_Selection_Tutorial.ipynb
```

## Session 1: Gene-wide selection

Students run BUSTED on the `HIVvif.nex` empirical dataset and compare standard BUSTED with
synonymous-rate variation and multiple-hit model variants.

Questions:

- What exactly is BUSTED testing?
- Does a significant BUSTED result identify the selected codon site?
- Did synonymous-rate variation change the result?
- Did multi-hit modeling change the result?
- Which result would you report in a manuscript?

## Session 2: Site-level selection

Students run FEL, MEME, and FUBAR on the lysin example and compare pervasive versus
episodic diversifying selection.

Questions:

- What is the difference between pervasive and episodic diversifying selection?
- Which codons were detected by FEL?
- Which codons were detected by MEME?
- Why might FEL and MEME disagree?
- Which sites would you annotate on a protein schematic?

## Session 3: Branch and lineage selection

Students run aBSREL on the `HIVvif.masked_nex` empirical dataset.

Questions:

- What does aBSREL test that BUSTED does not?
- Why does aBSREL need multiple-testing correction?
- Which branches, if any, show evidence after correction?
- How would branch labels change the questions you could ask?

## Session 4: Simulation and model checking

The bundled simulated dataset in `data/simulated` contains a small codon alignment with three known regimes:

- Purifying block: omega = 0.15
- Neutral-like block: omega = 1.0
- Positive-enriched block: omega = 2.5

Students run HyPhy methods on the bundled simulated data and compare inference to the known
truth table.

Questions:

- Which simulated block should be easiest to detect?
- Did HyPhy recover the positive-enriched region?
- Were there signals outside the positive-enriched block?
- What is the difference between false positives, low power, and model mismatch?
- How would more taxa or longer alignments change power?

## Final deliverable

Prepare a mini-report or three-slide summary covering:

- Dataset
- Gene-wide result
- Site-level result
- Branch or lineage result
- Biological interpretation
- Caveats
- Next steps

## Notes

The analysis scripts read empirical alignments from `data/22-empirical` by default. Set
`EMPIRICAL_DATA_DIR=/path/to/empirical-data` to run the same workflow on another
directory with the same file names.
