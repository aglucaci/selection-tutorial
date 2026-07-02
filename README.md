# EEBG2026 HyPhy Selection Tutorial

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/aglucaci/selection-tutorial/blob/main/notebooks/analysis/EEBG2026_HyPhy_Selection_Tutorial_Colab.ipynb)

Runnable workshop materials for teaching codon-based tests of molecular adaptation with
[HyPhy](https://www.hyphy.org/). The repository includes empirical codon alignments,
Google Colab and local Jupyter notebooks, command-line scripts for workshop sessions,
batch scripts for precomputing HyPhy results, and helper scripts for summary tables and
plots.

## What Is Included

```text
.
├── README.md
├── environment.yml
├── data/
│   ├── 21-empirical/
│   │   └── *.nex, *.mtnex
│   └── empirical_alignment_metrics.csv
├── docs/
│   ├── instructor_notes.md
│   └── selection_tutorial_student_handout.md
├── notebooks/
│   ├── EEBG2026_HyPhy_Selection_Tutorial.ipynb
│   └── analysis/
│       └── EEBG2026_HyPhy_Selection_Tutorial_Colab.ipynb
├── pdf/
│   └── msad150.pdf
└── scripts/
    ├── 00_setup_conda.sh
    ├── 00_setup_colab.sh
    ├── 01_download_tutorial_data.sh
    ├── 01_grab_codon_alignment_and_tree.py
    ├── 02_run_gene_wide.sh
    ├── 03_run_site_level.sh
    ├── 04_run_branch_lineage.sh
    ├── 05_simulate_codon_data.py
    ├── 07_collect_results.py
    ├── 08_summarize_empirical_data.py
    ├── 09_run_all_empirical_selection.sh
    └── 10_all_empirical_hyphy_commands.sh
```

Generated outputs are written to ignored directories:

```text
results/
tables/
figures/
```

## Data

The workshop uses bundled empirical alignments. Students do not need to download
alignments during the session.

- `data/21-empirical/`: empirical codon alignments in Nexus-like formats.
- `data/empirical_alignment_metrics.csv`: precomputed dataset metrics for quick review.
- `pdf/msad150.pdf`: source paper used by the student handout for dataset context.

Most empirical alignments use HyPhy's default `Universal` genetic code. The two
mitochondrial datasets use dataset-specific codes:

- `COXI.mtnex`: `--code Invertebrate-mtDNA`
- `mammalian_mtDNA.mtnex`: `--code Vertebrate-mtDNA`

The metrics CSV includes sequence counts, alignment lengths, codon-site counts, GC/gap
summaries, variable-site summaries, mean pairwise identity, tree presence, taxon-name
checks, and file size.

To verify that the required bundled data are present:

```bash
bash scripts/01_download_tutorial_data.sh
```

Despite the historical script name, `01_download_tutorial_data.sh` verifies local
bundled files. It does not download data.

## Run In Google Colab

Use Colab when students do not have Conda or HyPhy installed locally.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/aglucaci/selection-tutorial/blob/main/notebooks/analysis/EEBG2026_HyPhy_Selection_Tutorial_Colab.ipynb)

In Colab:

1. Open the notebook with the badge above.
2. Run the cells from top to bottom.
3. If you are teaching from a fork, edit the `REPO_URL` cell before cloning.

The Colab setup script clones or reuses `/content/selection-tutorial`, installs command
line helpers, installs HyPhy from `apt` when available, falls back to Bioconda with
micromamba when needed, installs Python packages with `pip`, and verifies the bundled
data.

At the end of the Colab notebook, an optional cell zips `results/`, `tables/`, and
`figures/` for download.

## Install HyPhy Locally

You can run the tutorial locally after installing HyPhy and the Python/Jupyter
dependencies. The Conda setup below is the recommended workshop path because it installs
HyPhy and the Python packages into one reproducible environment.

Install Conda or Mamba, then create or update the environment:

```bash
bash scripts/00_setup_conda.sh
conda activate eebg2026-hyphy
hyphy --version
```

On macOS, Homebrew is also an option:

```bash
brew update
brew install hyphy
hyphy --version
```

On Windows, use Windows Subsystem for Linux with Ubuntu, then run the Conda setup inside
the Ubuntu terminal.

## Run Locally

Create and activate the tutorial environment:

```bash
bash scripts/00_setup_conda.sh
conda activate eebg2026-hyphy
```

Verify the bundled data:

```bash
bash scripts/01_download_tutorial_data.sh
```

Run the guided local notebook:

```bash
jupyter lab notebooks/EEBG2026_HyPhy_Selection_Tutorial.ipynb
```

Or run the workflow from the command line:

```bash
bash scripts/02_run_gene_wide.sh
bash scripts/04_run_branch_lineage.sh
bash scripts/03_run_site_level.sh
python scripts/07_collect_results.py
```

## Workshop Sessions

### Session 1: Gene-Wide Selection

Script:

```bash
bash scripts/02_run_gene_wide.sh
```

Default dataset: `data/21-empirical/HIVvif.nex`

Methods:

- BUSTED standard
- BUSTED with synonymous-rate variation
- BUSTED with multiple-hit modeling
- FitMultiModel with standard MG94 and multi-hit model options

To run Session 1 on another empirical dataset:

```bash
SESSION1_ALIGNMENT=data/21-empirical/lysin.nex bash scripts/02_run_gene_wide.sh
python scripts/07_collect_results.py
```

For mitochondrial datasets, the script automatically uses the appropriate genetic code
unless `SESSION1_CODE` is set.

### Session 2: Branch-Level Selection

Script:

```bash
bash scripts/04_run_branch_lineage.sh
```

Default dataset: `data/21-empirical/HIVvif.nex`

Method:

- aBSREL

The bundled empirical files do not define named test/reference branch sets, so this
session uses aBSREL rather than RELAX.

### Session 3: Site-Level Selection

Script:

```bash
bash scripts/03_run_site_level.sh
```

Default dataset: `data/21-empirical/lysin.nex`

Methods:

- FEL
- MEME
- SLAC

## Precompute Results For Students

To run the default empirical batch over every bundled alignment:

```bash
bash scripts/09_run_all_empirical_selection.sh
```

By default, this loop-based runner enables:

- BUSTED with multiple-hit modeling
- aBSREL
- FEL
- MEME
- SLAC

It skips an enabled method when its JSON output already exists, unless `FORCE=1` is set.
It runs jobs in parallel, controlled by `MAX_JOBS`, and applies dataset-specific
mitochondrial genetic codes to `COXI.mtnex` and `mammalian_mtDNA.mtnex`.

To run only selected datasets:

```bash
bash scripts/09_run_all_empirical_selection.sh HIVvif.nex lysin.nex
```

Useful options:

```bash
FORCE=1 bash scripts/09_run_all_empirical_selection.sh
MAX_JOBS=4 bash scripts/09_run_all_empirical_selection.sh
RUN_BUSTED=1 bash scripts/09_run_all_empirical_selection.sh
RUN_BUSTED_SRV=1 bash scripts/09_run_all_empirical_selection.sh
RUN_BUSTED_MULTIHIT=0 bash scripts/09_run_all_empirical_selection.sh
RUN_FITMODEL=1 bash scripts/09_run_all_empirical_selection.sh
RUN_FITMULTIMODELMH=1 bash scripts/09_run_all_empirical_selection.sh
RUN_ABSREL=0 bash scripts/09_run_all_empirical_selection.sh
RUN_SLAC=0 RUN_MEME=0 bash scripts/09_run_all_empirical_selection.sh
RUN_COLLECT=0 bash scripts/09_run_all_empirical_selection.sh
```

Batch logs are written to:

```text
results/logs/all_empirical/
```

After a batch run, share these directories with students:

```text
results/
tables/
figures/
```

### Explicit HyPhy Command File

If you want a command ledger that spells out every HyPhy call, use:

```bash
bash scripts/10_all_empirical_hyphy_commands.sh
```

This explicit command file runs, for each empirical alignment:

- BUSTED standard
- BUSTED with synonymous-rate variation
- BUSTED with multiple-hit modeling
- FitMultiModel with standard MG94 and multi-hit model options
- aBSREL
- FEL
- MEME
- SLAC

To print all commands without running them:

```bash
DRY_RUN=1 bash scripts/10_all_empirical_hyphy_commands.sh
```

To force rerunning outputs that already exist:

```bash
FORCE=1 bash scripts/10_all_empirical_hyphy_commands.sh
```

The loop-based `scripts/09_run_all_empirical_selection.sh` is shorter and easier to
maintain. The explicit `scripts/10_all_empirical_hyphy_commands.sh` is longer, but it is
useful when you want a visible command ledger for teaching, review, or reproducibility.

## Tables And Figures

Collect HyPhy JSON outputs into CSV tables and plots:

```bash
python scripts/07_collect_results.py
```

Key outputs include:

```text
tables/session1_gene_wide_summary_long.csv
tables/session2_branch_lineage_summary_long.csv
tables/session3_site_level_tables.csv
figures/
```

The collected summary tables include explicit `dataset` and `analysis` columns so they
can be shared without requiring students to parse filenames.

## Regenerating Data Products

The repository already includes empirical alignments and a metrics CSV. Regenerate
metrics only if you intentionally change the underlying empirical data:

```bash
python scripts/08_summarize_empirical_data.py
```

`scripts/01_grab_codon_alignment_and_tree.py` is an optional utility for fetching and
normalizing an additional public codon alignment/tree pair. It is not required for the
standard workshop.

`scripts/05_simulate_codon_data.py` is retained as a utility script, but the current
checked-in workshop materials focus on empirical datasets.

## Teaching Materials

- `docs/instructor_notes.md`: teaching goals, timing, method notes, and troubleshooting.
- `docs/selection_tutorial_student_handout.md`: student-facing workflow and questions.
- `pdf/msad150.pdf`: paper referenced by the student handout.

## Troubleshooting

- `hyphy: command not found`: activate the Conda environment locally, or rerun
  `bash scripts/00_setup_colab.sh` in Colab.
- `Unable to locate package hyphy` in Colab: the setup script should fall back to
  micromamba and Bioconda. Pull the latest repo version if your notebook still uses an
  old apt-only setup.
- Missing bundled data: run `bash scripts/01_download_tutorial_data.sh` and check that
  `data/21-empirical/` is present.
- Empty tables: confirm that the corresponding HyPhy JSON files exist in `results/`.
- Batch run is too slow: run selected datasets, lower `MAX_JOBS`, or disable expensive
  methods with the `RUN_*` environment toggles shown above.
