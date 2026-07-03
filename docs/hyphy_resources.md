# HyPhy Learning Resources

This page collects short video and reading resources that can help students review
HyPhy, DataMonkey, and related selection-analysis workflows before or after the
practical.

## Overview

- [Hyphy Vision YouTube channel](https://www.youtube.com/@hyphyvision7202/videos)
- [HyPhy software](https://www.hyphy.org/)
- [DataMonkey](https://www.datamonkey.org/)
- [HyPhy Vision](https://vision.hyphy.org/)
- [HyPhy book](https://hyphy.org/resources/hyphybook2007.pdf)
- [Evolution of viral genomes tutorial chapter](https://hyphy.org/resources/tutorial-2017.pdf)
- [AOC JOSS paper](https://joss.theoj.org/papers/10.21105/joss.09872)
- [RASCL workflow](https://github.com/veg/RASCL)

## Reading

### [HyPhy Book](https://hyphy.org/resources/hyphybook2007.pdf)

A longer-form reference for HyPhy concepts, syntax, and phylogenetic hypothesis testing.
This is best used as a background resource for students who want deeper context than a
short tutorial video can provide, or for instructors preparing examples and explanations.

### [Evolution of viral genomes: Interplay between selection, recombination and other forces](https://hyphy.org/resources/tutorial-2017.pdf)

A tutorial-style chapter focused on viral genome evolution and the interaction among
selection, recombination, and other evolutionary forces. This is especially relevant for
students analyzing viral datasets or thinking about why recombination and model
assumptions matter when interpreting HyPhy selection results.

## Workflow Software

### [AOC: A Snakemake workflow for the characterization of natural selection in protein-coding genes](https://joss.theoj.org/papers/10.21105/joss.09872)

Lucaci, A. G., and Pond, S. (2026). DOI:
[10.21105/joss.09872](https://doi.org/10.21105/joss.09872). Published in the
Journal of Open Source Software on 19 May 2026.

AOC, the Analysis of Orthologous Collections, is a Snakemake workflow for scaling
selection analyses across protein-coding genes. It automates the path from unaligned
homologous sequences to completed results and interactive visualizations, helping users
identify genomic sites and species or lineages affected by negative selection,
diversifying or directional positive selection, and differential selection between
branch groups. The workflow is useful for moving beyond one-gene examples and for
connecting site-level dN/dS estimates, lineage-specific patterns, and statistical support
to functional or evolutionary hypotheses.

### [RASCL: Rapid Assessment of Selection in Clades Through Molecular Sequence Analysis](https://github.com/veg/RASCL)

Lucaci, A. G., et al. (2022). DOI:
[10.1371/journal.pone.0275623](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0275623).

RASCL is a workflow for using molecular sequence data from genotypically distinct viral
lineages to identify distinguishing features and evolutionary patterns within lineages.
Using whole-genome sequences, a query set of sequences is compared against a globally
diverse background set of circulating viral sequences. The application combines several
open-source tools with selection analysis methods from [HyPhy](https://www.hyphy.org/)
and assembles analysis results into JSON files that can be explored in a full-featured
[Observable notebook](https://observablehq.com/@aglucaci/rascl). Selected SARS-CoV-2
clade results are available in the notebook as examples.

## General Introduction

### [Introduction to HyPhy: Hypothesis testing using Phylogenies](https://www.youtube.com/watch?v=4gcQ6CCTRIY)

A broad seminar-style introduction to HyPhy and phylogenetic hypothesis testing. This is
the best starting point for students who want conceptual background before running
method-specific analyses.

## Hyphy Vision Channel Videos

These videos are from the [Hyphy Vision YouTube channel](https://www.youtube.com/@hyphyvision7202/videos).

### [How to use BUSTED[S] on DataMonkey.org](https://www.youtube.com/watch?v=FRcJjYIcnY8)

A walkthrough for running and interpreting BUSTED[S] on DataMonkey. Useful for the
gene-wide selection session, especially when discussing how BUSTED-style tests ask
whether any site on the tested branches has experienced episodic diversifying selection.

### [Download, install, and run HYPHY in under 10 Minutes! A quick intro to our software](https://www.youtube.com/watch?v=fgNrPbOTpxE)

A quick installation and first-run overview for HyPhy, including basic software setup,
running tools, and visualizing results. This is useful as a backup reference for students
who want to see the command-line workflow demonstrated.

### [Intro to using DataMonkey.org](https://www.youtube.com/watch?v=GD0T0UJSuYU)

A tour of DataMonkey.org and its web-based HyPhy analysis tools. This is useful for
students who cannot install software locally or who want to compare command-line HyPhy
with the web interface.

### [How to Use SLAC on DataMonkey](https://www.youtube.com/watch?v=flgt-lGu6tw)

A method-specific tutorial for SLAC, including how to submit a coding alignment and
interpret site-level synonymous and nonsynonymous substitution summaries. Pair this with
the SLAC section of the practical.

### [How to Use MultiHit on DataMonkey](https://www.youtube.com/watch?v=shS2MDEvLAs)

An introduction to the MultiHit workflow on DataMonkey. This is useful when discussing
why instantaneous multiple-nucleotide changes can matter for codon-model inference and
why multi-hit model checks can change interpretation.

### [How to Use Contrast-FEL on DataMonkey](https://www.youtube.com/watch?v=UROQ6w9j0DU)

A tutorial on Contrast-FEL, which compares site-level selective pressures between
predefined branch sets. This is most relevant as an extension topic after students
understand FEL and branch labeling.

## Suggested Viewing Order

1. Watch the general HyPhy introduction for conceptual framing.
2. Watch the HyPhy installation/quick-start video if local setup is confusing.
3. Watch the DataMonkey overview if using web-based analyses.
4. Watch the BUSTED[S], SLAC, MultiHit, or Contrast-FEL videos as needed for specific
   methods.

## Notes For Instructors

- The Hyphy Vision channel videos are concise, method-oriented tutorials.
- Some interface details may have changed since the videos were recorded, but the
  biological questions and interpretation points remain useful.
- For this workshop, prioritize videos that match the session goals: BUSTED[S] for
  gene-wide selection, SLAC for site-level counting methods, and MultiHit for
  model-checking discussions.
