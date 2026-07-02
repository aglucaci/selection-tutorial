# EEBG2026 Hands-on Selection Tutorial

## Quantifying Natural Selection in Protein-Coding Sequences  
### From HyPhy analyses to biological interpretation and visualization

**Instructor:** Alexander Lucaci, Weill Cornell Medicine  
**Workshop:** Eastern European Bioinformatics and Computational Genomics Workshop, EEBG2026  
**Focus:** Codon models, HyPhy selection tests, empirical datasets, JSON output, and visualization.

---

## 0. What students will do

In this hands-on session, students will choose one empirical protein-coding dataset, inspect the alignment, run multiple HyPhy selection analyses, visualize the JSON output, and write a short biological interpretation.

Students will:

1. Install or access the required software.
2. Download the tutorial data from GitHub.
3. Read the dataset description PDF and choose one protein.
4. Inspect the codon alignment in AliView.
5. Run five HyPhy selection analyses:
   - **BUSTED**
   - **aBSREL**
   - **FEL**
   - **MEME**
   - **SLAC**
6. Re-run selected analyses with additional model options where available.
7. Upload HyPhy JSON output files to [**HyPhy Vision**](https://vision.hyphy.org/) for visualization.
8. Use Google Colab only for downstream plotting, table generation, and result interpretation.
9. Answer guided biological interpretation questions.

---

## 1. Software setup

### 1.1 Install HyPhy locally

Start with the official HyPhy installation page:

<https://hyphy.org/installation/>

Recommended Conda installation:

```bash
conda install -c bioconda hyphy
```

If Bioconda has not been configured:

```bash
conda config --add channels bioconda
conda config --add channels conda-forge
conda install -c bioconda hyphy
```

Check that HyPhy works:

```bash
hyphy --help
```

or:

```bash
hyphy --version
```

Expected outcome: HyPhy prints a help menu, version information, or a list of available analyses.

> **Windows note:** HyPhy is not currently distributed as a native Windows executable through the official installation page. Windows users should use WSL, Datamonkey, Galaxy, or another browser-based option.

---

### 1.2 Install AliView

AliView will be used to inspect alignments before analysis.

Official AliView page:

<https://ormbunkar.se/aliview/>

Conda installation:

```bash
conda install -c bioconda aliview
```

Start AliView:

```bash
aliview
```

Students should use AliView to check:

- Are sequences aligned?
- Does the alignment look codon-aware?
- Are there obvious frameshifts?
- Are there large gap-rich regions?
- Are there premature stop codons?
- Are some sequences much shorter than others?

---

### 1.3 If HyPhy cannot be installed: use Datamonkey

If local installation fails, use Datamonkey:

<https://datamonkey.org/>

Datamonkey provides web interfaces for several HyPhy analyses, including:

- BUSTED
- aBSREL
- FEL
- MEME
- SLAC

General Datamonkey workflow:

1. Open the Datamonkey method page.
2. Select the desired method.
3. Upload the alignment file.
4. Select the genetic code, usually **Universal**.
5. Choose the branch set if the method asks for it.
6. Adjust advanced settings if needed.
7. Run the analysis.
8. Download or save the JSON output.
9. Upload the JSON output to HyPhy Vision.

[HyPhy Methods Citations](https://datamonkey.org/citations)

**Useful pages:** 

| Analysis | Datamonkey page |
|---|---|
| BUSTED | <https://datamonkey.org/busted> |
| aBSREL | <https://datamonkey.org/absrel> |
| FEL | <https://datamonkey.org/fel> |
| MEME | <https://datamonkey.org/meme> |
| SLAC | <https://datamonkey.org/slac> |


---

### 1.4 Optional: use Galaxy Europe

Galaxy Europe is optional for this exercise:

<https://usegalaxy.eu/>

Students may use Galaxy if they prefer a workflow-based web environment. This is not required for the core session.

Recommended priority order:

1. Local HyPhy command line.
2. Datamonkey if local HyPhy does not work.
3. Galaxy Europe as an optional alternative.

---

## 2. Download the tutorial data

Data are provided here:

<https://github.com/aglucaci/selection-tutorial>

Clone the repository:

```bash
git clone https://github.com/aglucaci/selection-tutorial.git
cd selection-tutorial
```

The empirical data are expected under:

```bash
data/21-empirical
```

---

## 3. Read the dataset PDF and choose one protein

Open the PDF:

<https://github.com/aglucaci/selection-tutorial/blob/main/pdf/msad150.pdf>

This PDF gives short descriptions of empirical protein-coding datasets. Students should read the descriptions and choose one protein based on biological interest, sequence diversity, taxonomic scope, and interpretability.

---

## 4. Choose your input alignment

Set an input file.

Example using HIV Vif:

```bash
export DATASET_NAME=HIVvif
export ALIGNMENT="$EMPIRICAL_DIR/HIVvif.nex"
```

If a masked alignment is available, use it for the main analyses:

```bash
export ALIGNMENT="$EMPIRICAL_DIR/HIVvif.masked_nex"
```

Check that the file exists:

```bash
ls -lh "$ALIGNMENT"
```

Create an output directory:

```bash
mkdir -p results/$DATASET_NAME
```

---

## 5. Inspect the alignment in AliView

Open the alignment:

```bash
aliview "$ALIGNMENT"
```

### Alignment inspection checklist

Before running HyPhy, answer:

1. How many sequences are present?
2. What is the approximate alignment length?
3. Does the alignment appear to be in codon frame?
4. Are there obvious gap-rich regions?
5. Are any sequences much shorter than the others?
6. Are there stop codons?
7. Does the alignment look suitable for codon-model analysis?
8. Would you use the full alignment or a masked/filtered alignment?

### Student note

HyPhy selection inference depends strongly on the quality of the alignment and tree. A significant result from a poor alignment is not biologically meaningful.

---

## 6. Analysis 1: BUSTED

### Biological question

**Has this gene experienced episodic diversifying selection at at least one site on at least one branch?**

BUSTED is a gene-wide test. It does **not** identify selected sites as formal site-level results.

### Standard BUSTED

```bash
hyphy busted \
  --alignment "$ALIGNMENT" \
  --branches All \
  --output "results/$DATASET_NAME/${DATASET_NAME}.BUSTED.json"
```

### BUSTED with synonymous-rate variation

```bash
hyphy busted \
  --alignment "$ALIGNMENT" \
  --branches All \
  --srv Yes \
  --syn-rates 3 \
  --output "results/$DATASET_NAME/${DATASET_NAME}.BUSTED_SRV.json"
```

### BUSTED with synonymous-rate variation and multiple-hit support

```bash
hyphy busted \
  --alignment "$ALIGNMENT" \
  --branches All \
  --srv Yes \
  --syn-rates 3 \
  --multiple-hits Double+Triple \
  --output "results/$DATASET_NAME/${DATASET_NAME}.BUSTED_SRV_MH.json"
```

### Questions for students

1. What is the null hypothesis of BUSTED?
2. What is the alternative hypothesis?
3. Was BUSTED significant?
4. Did adding synonymous-rate variation change the result?
5. Did adding multiple-hit substitutions change the result?
6. Does a significant BUSTED result mean every site is under positive selection?
7. Does BUSTED formally identify individual positively selected sites?
8. Which BUSTED model would you report and why?
9. What biological process could explain gene-wide episodic diversification in this protein?
10. What caveats would you include?

---

## 7. Analysis 2: aBSREL

### Biological question

**Which branches, if any, show evidence of episodic diversifying selection?**

aBSREL is branch-focused. It does not formally identify individual selected sites.

### Exploratory aBSREL on all branches

```bash
hyphy absrel \
  --alignment "$ALIGNMENT" \
  --branches All \
  --output "results/$DATASET_NAME/${DATASET_NAME}.aBSREL_all.json"
```

### Optional hypothesis-driven aBSREL

If a labeled tree or labeled NEXUS file is available, students can test a predefined branch class instead of all branches.

Example:

```bash
hyphy absrel \
  --alignment "$ALIGNMENT" \
  --branches Foreground \
  --output "results/$DATASET_NAME/${DATASET_NAME}.aBSREL_foreground.json"
```

Only use this if the branch labels are actually present.

### Questions for students

1. What does aBSREL test?
2. How is aBSREL different from BUSTED?
3. How many branches were tested?
4. Were any branches significant after correction?
5. Were the significant branches terminal or internal?
6. Are the significant branches biologically meaningful?
7. Could the result reflect sampling, recombination, or alignment artifacts?
8. How would you define foreground branches if you had metadata?
9. Does aBSREL identify selected codon sites?
10. Write one sentence interpreting the branch-level result.

---

## 8. Analysis 3: FEL

### Biological question

**Which sites show evidence of pervasive purifying or diversifying selection across the phylogeny?**

FEL estimates site-specific synonymous and nonsynonymous substitution rates and tests whether dN differs from dS at each site.

### FEL with synonymous-rate variation

```bash
hyphy fel \
  --alignment "$ALIGNMENT" \
  --branches All \
  --srv Yes \
  --pvalue 0.1 \
  --output "results/$DATASET_NAME/${DATASET_NAME}.FEL_SRV.json"
```

### FEL with multiple-hit support

```bash
hyphy fel \
  --alignment "$ALIGNMENT" \
  --branches All \
  --srv Yes \
  --multiple-hits Double+Triple \
  --pvalue 0.1 \
  --output "results/$DATASET_NAME/${DATASET_NAME}.FEL_SRV_MH.json"
```

### FEL with confidence intervals, if supported by your HyPhy version

```bash
hyphy fel \
  --alignment "$ALIGNMENT" \
  --branches All \
  --srv Yes \
  --ci Yes \
  --pvalue 0.1 \
  --output "results/$DATASET_NAME/${DATASET_NAME}.FEL_CI.json"
```

If the `--ci` option is not recognized, run:

```bash
hyphy fel --help
```

and use the options available in your installed version.

### Questions for students

1. What is FEL testing at each codon?
2. Which sites show evidence of purifying selection?
3. Which sites show evidence of pervasive diversifying selection?
4. Are the positively selected sites clustered in the alignment?
5. Are the selected sites near gaps or poorly aligned regions?
6. Do the results change when multiple-hit substitutions are allowed?
7. Do the results change when synonymous-rate variation is allowed?
8. What p-value threshold did you use and why?
9. Which sites would you prioritize for biological interpretation?
10. What domain or structural annotation would help interpret these sites?

---

## 9. Analysis 4: MEME

### Biological question

**Which individual sites show evidence of episodic diversifying selection?**

MEME is designed to detect sites that may experience positive selection only on a subset of branches.

### Standard MEME

```bash
hyphy meme \
  --alignment "$ALIGNMENT" \
  --branches All \
  --pvalue 0.1 \
  --output "results/$DATASET_NAME/${DATASET_NAME}.MEME.json"
```

### MEME with multiple-hit support

```bash
hyphy meme \
  --alignment "$ALIGNMENT" \
  --branches All \
  --multiple-hits Double+Triple \
  --pvalue 0.1 \
  --output "results/$DATASET_NAME/${DATASET_NAME}.MEME_MH.json"
```

### MEME with additional rate classes, if supported

```bash
hyphy meme \
  --alignment "$ALIGNMENT" \
  --branches All \
  --rates 3 \
  --pvalue 0.1 \
  --output "results/$DATASET_NAME/${DATASET_NAME}.MEME_rates3.json"
```

If the option is not recognized:

```bash
hyphy meme --help
```

### Questions for students

1. What is episodic diversifying selection?
2. How is MEME different from FEL?
3. Which sites are significant under MEME?
4. Do MEME sites overlap with FEL sites?
5. If FEL and MEME disagree, what does that imply?
6. Are MEME sites located in biologically interpretable regions?
7. Do MEME results change with multiple-hit modeling?
8. What is the strongest candidate adaptive site?
9. Could recombination or alignment error create false-positive MEME results?
10. Write one sentence interpreting the MEME result.

---

## 10. Analysis 5: SLAC

### Biological question

**Which sites show evidence of selection using a counting-based ancestral reconstruction approach?**

SLAC is generally faster and simpler than FEL or MEME, but it can be less accurate for highly divergent datasets.

### Standard SLAC

```bash
hyphy slac \
  --alignment "$ALIGNMENT" \
  --branches All \
  --pvalue 0.1 \
  --output "results/$DATASET_NAME/${DATASET_NAME}.SLAC.json"
```

### Questions for students

1. What does SLAC estimate?
2. How is SLAC different from FEL?
3. How many sites are inferred as negatively selected?
4. How many sites are inferred as positively selected?
5. Do SLAC results agree with FEL?
6. Is this dataset low-divergence or high-divergence?
7. Is SLAC appropriate for this dataset?
8. Which SLAC results would you trust most?
9. Which SLAC results would you treat cautiously?
10. Write one sentence comparing SLAC and FEL.

---

## 11. Optional pre-analysis: GARD

Selection analyses can be affected by recombination. If time allows, run GARD before interpreting results.

```bash
hyphy gard \
  --alignment "$ALIGNMENT" \
  --output "results/$DATASET_NAME/${DATASET_NAME}.GARD.json"
```

Questions:

1. Is there evidence of recombination?
2. If recombination is present, how could it affect BUSTED, FEL, MEME, aBSREL, or SLAC?
3. Should the dataset be partitioned before selection testing?

---

## 12. Visualize HyPhy results using HyPhy Vision

Use HyPhy Vision:

<https://vision.hyphy.org/>

### Workflow

1. Open HyPhy Vision.
2. Choose the method-specific visualization page, or drag and drop the JSON output file if supported.
3. Upload one HyPhy JSON file at a time.
4. Start with:
   - BUSTED JSON
   - FEL JSON
   - MEME JSON
   - aBSREL JSON
   - SLAC JSON
5. Inspect the summary statistics, site tables, branch plots, evidence ratios, or method-specific figures.
6. Export figures or take screenshots for the final report.
7. Record the key interpretation in your notes.

### Recommended files to upload

```bash
results/$DATASET_NAME/${DATASET_NAME}.BUSTED.json
results/$DATASET_NAME/${DATASET_NAME}.BUSTED_SRV.json
results/$DATASET_NAME/${DATASET_NAME}.BUSTED_SRV_MH.json
results/$DATASET_NAME/${DATASET_NAME}.aBSREL_all.json
results/$DATASET_NAME/${DATASET_NAME}.FEL_SRV.json
results/$DATASET_NAME/${DATASET_NAME}.FEL_SRV_MH.json
results/$DATASET_NAME/${DATASET_NAME}.MEME.json
results/$DATASET_NAME/${DATASET_NAME}.MEME_MH.json
results/$DATASET_NAME/${DATASET_NAME}.SLAC.json
```

### Visualization checklist

For each JSON file, record:

| Method | Visualization to inspect | What to record |
|---|---|---|
| BUSTED | Test summary, evidence ratios | p-value, LRT, evidence for gene-wide selection |
| aBSREL | Branch-level results/tree | significant branches, corrected p-values |
| FEL | Site table/plot | purifying sites, diversifying sites, p-values |
| MEME | Site table/plot | episodic sites, p-values |
| SLAC | Site table | counted synonymous/nonsynonymous changes, selected sites |

---

## 13. Google Colab visualization

Google Colab is used only for downstream visualization and summaries.

Students should use Colab to:

1. Upload HyPhy JSON output files.
2. Parse method summaries.
3. Create summary tables.
4. Plot p-values or evidence ratios.
5. Plot selected sites across the protein.
6. Compare FEL, MEME, and SLAC site calls.
7. Save figures for the final report.

### Minimal Colab upload cell

```python
from google.colab import files
uploaded = files.upload()
```

### Minimal JSON loading cell

```python
import json
from pathlib import Path

json_files = list(uploaded.keys())

for file in json_files:
    with open(file) as handle:
        data = json.load(handle)
    print(file)
    print(data.keys())
```

### Suggested visualizations

1. **BUSTED model comparison bar chart**
   - Standard BUSTED
   - BUSTED + synonymous-rate variation
   - BUSTED + synonymous-rate variation + multiple hits

2. **Site-level selected-site plot**
   - x-axis: codon position
   - y-axis: `-log10(p-value)`
   - overlay FEL, MEME, and SLAC if possible

3. **Method overlap table**
   - rows: codon sites
   - columns: FEL, MEME, SLAC
   - indicate whether each method detected selection

4. **Branch-level aBSREL summary**
   - branch name
   - corrected p-value
   - evidence for episodic selection

---

## 14. Final student report

Each student or group should prepare a short report or 3-slide summary.

### Slide/report structure

#### 1. Dataset

- Protein:
- Organism or taxonomic group:
- File analyzed:
- Number of sequences:
- Alignment length:
- Why this protein was selected:

#### 2. BUSTED result

- Was there gene-wide evidence of episodic diversifying selection?
- Did synonymous-rate variation change the conclusion?
- Did multiple-hit modeling change the conclusion?

#### 3. Site-level results

- FEL selected sites:
- MEME selected sites:
- SLAC selected sites:
- Overlap among methods:
- Most biologically interesting codons:

#### 4. Branch-level result

- aBSREL significant branches:
- Were results significant after correction?
- What biological hypothesis could explain selected branches?

#### 5. Biological interpretation

Write 3–5 sentences.

Template:

> We analyzed **[protein]** using HyPhy codon models to test for gene-wide, branch-level, and site-level evidence of natural selection. **[BUSTED result]** suggested that the gene **[does/does not]** show evidence of episodic diversifying selection. Site-level methods identified **[number]** candidate codons, with **[FEL/MEME/SLAC]** showing **[agreement/disagreement]**, suggesting **[biological interpretation]**. aBSREL identified **[number]** candidate branches, indicating that selection may be concentrated in **[lineages/branches]**. These results should be interpreted cautiously because **[alignment quality/recombination/model assumptions/sampling]** may affect inference.

#### 6. Caveats

Include at least three:

- Alignment quality
- Recombination
- Sampling bias
- Tree uncertainty
- Multiple testing
- Model misspecification
- Synonymous-rate variation
- Multiple nucleotide substitutions
- Lack of structural/domain annotation

---

## 15. Master question list

### Dataset questions

1. Which protein did you choose?
2. Why did you choose this protein?
3. What biological question could this protein answer?
4. How many sequences are in the alignment?
5. How long is the alignment?
6. Does the alignment appear reliable?
7. Are there obvious problematic regions?

### BUSTED questions

1. Was gene-wide episodic diversifying selection detected?
2. What was the p-value?
3. Did SRV affect the result?
4. Did multiple-hit modeling affect the result?
5. What does this imply biologically?

### aBSREL questions

1. Were any branches significant?
2. Were results corrected for multiple testing?
3. Do significant branches correspond to known biology?
4. Are selected branches terminal or internal?
5. What follow-up analysis would you run?

### FEL questions

1. Which sites show purifying selection?
2. Which sites show pervasive diversifying selection?
3. Are positively selected sites clustered?
4. Are they in well-aligned regions?
5. Do results change under multi-hit models?

### MEME questions

1. Which sites show episodic diversifying selection?
2. Do MEME sites overlap with FEL sites?
3. What does disagreement between FEL and MEME mean?
4. Which site is the best adaptive candidate?
5. What biological annotation would help?

### SLAC questions

1. How many selected sites does SLAC detect?
2. Does SLAC agree with FEL?
3. Is SLAC appropriate for this dataset?
4. What are the limitations of counting-based methods?

### Visualization questions

1. Which plot is most informative?
2. Which method produces the clearest biological signal?
3. Are signals consistent across methods?
4. What would you show in a publication figure?
5. What result would you not over-interpret?

---

## 16. Recommended method citations

Students should check and copy current citations from:

<https://datamonkey.org/citations>

Common method citations:

| Method | Citation |
|---|---|
| BUSTED | Murrell et al. 2015, *Molecular Biology and Evolution* |
| aBSREL | Smith et al. 2015, *Molecular Biology and Evolution* |
| FEL | Kosakovsky Pond and Frost 2005, *Molecular Biology and Evolution* |
| MEME | Murrell et al. 2012, *PLoS Genetics* |
| SLAC | Kosakovsky Pond and Frost 2005, *Molecular Biology and Evolution* |
| GARD | Kosakovsky Pond et al. 2006, *Molecular Biology and Evolution* |

---

## 17. Minimal command summary

```bash
# Clone data
git clone https://github.com/aglucaci/selection-tutorial.git
cd selection-tutorial

# Pick empirical directory
if [ -d data/21-empirical ]; then
    export EMPIRICAL_DIR=data/21-empirical
elif [ -d data/22-empirical ]; then
    export EMPIRICAL_DIR=data/22-empirical
fi

# Choose dataset
export DATASET_NAME=HIVvif
export ALIGNMENT="$EMPIRICAL_DIR/HIVvif.nex"
mkdir -p results/$DATASET_NAME

# Inspect
aliview "$ALIGNMENT"

# Run analyses
hyphy busted --alignment "$ALIGNMENT" --branches All --output "results/$DATASET_NAME/${DATASET_NAME}.BUSTED.json"

hyphy busted --alignment "$ALIGNMENT" --branches All --srv Yes --syn-rates 3 --output "results/$DATASET_NAME/${DATASET_NAME}.BUSTED_SRV.json"

hyphy busted --alignment "$ALIGNMENT" --branches All --srv Yes --syn-rates 3 --multiple-hits Double+Triple --output "results/$DATASET_NAME/${DATASET_NAME}.BUSTED_SRV_MH.json"

hyphy absrel --alignment "$ALIGNMENT" --branches All --output "results/$DATASET_NAME/${DATASET_NAME}.aBSREL_all.json"

hyphy fel --alignment "$ALIGNMENT" --branches All --srv Yes --pvalue 0.1 --output "results/$DATASET_NAME/${DATASET_NAME}.FEL_SRV.json"

hyphy fel --alignment "$ALIGNMENT" --branches All --srv Yes --multiple-hits Double+Triple --pvalue 0.1 --output "results/$DATASET_NAME/${DATASET_NAME}.FEL_SRV_MH.json"

hyphy meme --alignment "$ALIGNMENT" --branches All --pvalue 0.1 --output "results/$DATASET_NAME/${DATASET_NAME}.MEME.json"

hyphy meme --alignment "$ALIGNMENT" --branches All --multiple-hits Double+Triple --pvalue 0.1 --output "results/$DATASET_NAME/${DATASET_NAME}.MEME_MH.json"

hyphy slac --alignment "$ALIGNMENT" --branches All --pvalue 0.1 --output "results/$DATASET_NAME/${DATASET_NAME}.SLAC.json"
```

---

## 18. End-of-session deliverable

By the end of the practical, students should submit:

1. The protein/dataset they selected.
2. One screenshot or exported figure from HyPhy Vision.
3. One small table summarizing BUSTED, aBSREL, FEL, MEME, and SLAC.
4. A list of top candidate sites or branches.
5. A 3–5 sentence biological interpretation.
6. A short caveats paragraph.

Example final statement:

> In this analysis, **[protein]** showed **[evidence/no evidence]** for gene-wide episodic diversifying selection by BUSTED. Site-level methods identified **[number]** candidate codons, with **[agreement/disagreement]** among FEL, MEME, and SLAC. Branch-level testing with aBSREL suggested that selection may be concentrated on **[branches/lineages]**. Together, these results suggest **[biological interpretation]**, although conclusions remain limited by **[main caveats]**.
