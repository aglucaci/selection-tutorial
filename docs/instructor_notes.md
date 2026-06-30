# Instructor Notes

## Learning goals

By the end of the practical, students should be able to:

- Explain the biological question addressed by BUSTED, FEL, MEME, FUBAR, and aBSREL.
- Distinguish gene-wide, site-level, branch-level, and lineage-comparison tests.
- Interpret p-values, posterior probabilities, and multiple-testing correction.
- Compare inferred selection signals with known simulated truth.
- Describe caveats around power, model fit, recombination, alignment quality, and sampling.

## Suggested timing

- 15 min: environment check and bundled empirical data verification.
- 35 min: Session 1 gene-wide tests.
- 45 min: Session 2 site-level tests and plotting.
- 35 min: Session 3 branch and lineage tests.
- 45 min: Session 4 simulation and model checking.
- 20 min: student synthesis and mini-report discussion.

## Teaching notes

BUSTED is a gene-wide test. A significant result supports evidence that at least one
site on at least one tested branch has experienced episodic diversifying selection, but
it does not identify the causal site.

FEL targets pervasive site-level selection. MEME targets episodic site-level selection.
FUBAR is fast and Bayesian; emphasize that posterior probabilities should not be read as
ordinary p-values.

aBSREL tests individual branches for episodic diversifying selection and therefore needs
multiple-testing correction across branches.

The simulation exercise is deliberately short, so students may see weak power or extra
signals. Use that outcome as a feature: it opens discussion of finite data, model
mismatch, and uncertainty.

## Common troubleshooting

- `hyphy: command not found`: activate the Conda environment.
- In Google Colab, run `bash scripts/00_setup_colab.sh` before running the analysis
  scripts. The Colab notebook does this in its setup section.
- Missing empirical data: run `bash scripts/01_download_tutorial_data.sh` to verify the
  bundled files in `data/22-empirical`.
- Empty tables: confirm that the corresponding JSON files exist in `results/`.
