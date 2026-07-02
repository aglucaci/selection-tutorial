# EEBG2026 HyPhy Selection Tutorial

Runnable workshop materials for teaching codon-based tests of molecular adaptation with
[HyPhy](https://www.hyphy.org/). The repository includes empirical codon alignments,
local Jupyter notebooks, command-line scripts for workshop sessions, batch scripts for
precomputing HyPhy results, and helper scripts for summary tables and plots.

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
│   └── EEBG2026_HyPhy_Selection_Tutorial.ipynb
├── pdf/
│   └── msad150.pdf
└── scripts/
    ├── 00_setup_conda.sh
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

## Install HyPhy Locally

You can run the tutorial locally after installing HyPhy and the Python/Jupyter
dependencies. The Conda setup below is the recommended workshop path because it installs
HyPhy and the Python packages into one reproducible environment.

Install Miniforge or Mambaforge if `conda` is not already available. These installers
use the `conda-forge` ecosystem by default and tend to be more reliable for workshops
than a base Anaconda install with mixed channels.

- Miniforge: <https://conda-forge.org/download/>
- Mambaforge: <https://github.com/conda-forge/miniforge>

Choose the installer for your operating system:

- macOS Apple Silicon: use the macOS `arm64` installer.
- macOS Intel: use the macOS `x86_64` installer.
- Linux: use the Linux installer for your CPU architecture, usually `x86_64`.
- Windows: use Windows Subsystem for Linux with Ubuntu, then install Miniforge inside
  the Ubuntu terminal. Native Windows shells are not the recommended workshop path.

After installing, close and reopen the terminal. Confirm that one solver is available:

```bash
conda --version
mamba --version
```

If `mamba --version` fails but `conda` works, that is fine. Create or update the
tutorial environment from the repository root:

```bash
bash scripts/00_setup_conda.sh
conda activate eebg2026-hyphy
hyphy --version
```

If environment creation is slow or fails with channel/solver errors, try the manual
commands below:

```bash
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --set channel_priority strict
conda env update -n eebg2026-hyphy -f environment.yml
```

If the environment does not exist yet:

```bash
conda env create -f environment.yml
conda activate eebg2026-hyphy
```

If solving still stalls, install `mamba` into the base environment and retry:

```bash
conda install -n base -c conda-forge mamba
mamba env update -n eebg2026-hyphy -f environment.yml
```

If activation fails, initialize Conda for your shell, then open a new terminal:

```bash
conda init
```

Platform notes:

- macOS: if the Conda route is blocked, Homebrew can install HyPhy directly, but the
  Conda environment is still recommended for the Python/Jupyter dependencies.
- Linux: use the Miniforge Linux installer, then run `bash scripts/00_setup_conda.sh`
  from the repository root.
- Windows WSL Ubuntu: install Ubuntu with WSL, open the Ubuntu terminal, clone this
  repository there, install Miniforge inside Ubuntu, and run the Conda setup script
  from that Ubuntu filesystem.

Homebrew fallback for macOS:

```bash
brew update
brew install hyphy
hyphy --version
```

Minimal WSL Ubuntu setup outline:

```powershell
wsl --install -d Ubuntu
```

Then open Ubuntu and continue there:

```bash
sudo apt update
sudo apt install -y git curl wget bzip2
git clone https://github.com/aglucaci/selection-tutorial.git
cd selection-tutorial
bash scripts/00_setup_conda.sh
conda activate eebg2026-hyphy
```

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

- `hyphy: command not found`: activate the Conda environment with
  `conda activate eebg2026-hyphy`, then run `hyphy --version`.
- `conda activate` is unavailable: run `conda init`, close the terminal, reopen it, and
  try again.
- Environment solving is very slow: install `mamba` and rerun the setup with Mamba
  available in the base environment.
- Package conflicts or missing HyPhy: set strict channel priority and make sure both
  `conda-forge` and `bioconda` are configured.
- Missing bundled data: run `bash scripts/01_download_tutorial_data.sh` and check that
  `data/21-empirical/` is present.
- Empty tables: confirm that the corresponding HyPhy JSON files exist in `results/`.
- Batch run is too slow: run selected datasets, lower `MAX_JOBS`, or disable expensive
  methods with the `RUN_*` environment toggles shown above.
