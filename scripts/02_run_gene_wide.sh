#!/usr/bin/env bash
set -euo pipefail

EMPIRICAL_DATA_DIR="${EMPIRICAL_DATA_DIR:-data/21-empirical}"
ALIGNMENT="${SESSION1_ALIGNMENT:-$EMPIRICAL_DATA_DIR/HIVvif.nex}"
RESULTS_DIR="results/session1_gene_wide"
DATASET_NAME="$(basename "$ALIGNMENT")"
if [[ "$DATASET_NAME" == *.mtnex ]]; then
  DATASET_PREFIX="${DATASET_NAME%.mtnex}"
else
  DATASET_PREFIX="${DATASET_NAME%.nex}"
fi
DATASET_PREFIX="${DATASET_PREFIX//[^A-Za-z0-9_]/_}"

GENETIC_CODE="${SESSION1_CODE:-Universal}"
if [[ -z "${SESSION1_CODE:-}" ]]; then
  case "$DATASET_NAME" in
    COXI.mtnex)
      GENETIC_CODE="Invertebrate-mtDNA"
      ;;
    mammalian_mtDNA.mtnex)
      GENETIC_CODE="Vertebrate-mtDNA"
      ;;
  esac
fi
CODE_ARGS=(--code "$GENETIC_CODE")

mkdir -p "$RESULTS_DIR"

if ! command -v hyphy >/dev/null 2>&1; then
  echo "ERROR: hyphy is not on PATH. Activate the conda environment first." >&2
  exit 1
fi

if [[ -z "${FITMULTIMODEL_BF:-}" ]]; then
  HYPHY_PREFIX="$(cd "$(dirname "$(command -v hyphy)")/.." && pwd)"
  FITMULTIMODEL_BF="$HYPHY_PREFIX/share/hyphy/TemplateBatchFiles/SelectionAnalyses/FitMultiModel.bf"
fi
if [[ ! -s "$FITMULTIMODEL_BF" && -s "/usr/local/share/hyphy/TemplateBatchFiles/SelectionAnalyses/FitMultiModel.bf" ]]; then
  FITMULTIMODEL_BF="/usr/local/share/hyphy/TemplateBatchFiles/SelectionAnalyses/FitMultiModel.bf"
fi
if [[ ! -s "$FITMULTIMODEL_BF" ]]; then
  echo "ERROR: could not find FitMultiModel.bf. Set FITMULTIMODEL_BF to its full path." >&2
  exit 1
fi

if [[ ! -s "$ALIGNMENT" ]]; then
  echo "ERROR: missing $ALIGNMENT. Run scripts/01_download_tutorial_data.sh to verify bundled data." >&2
  exit 1
fi

echo "Running Session 1 gene-wide tests on $ALIGNMENT"
echo "Using genetic code: $GENETIC_CODE"

echo "Running standard BUSTED..."
hyphy busted \
  "${CODE_ARGS[@]}" \
  --alignment "$ALIGNMENT" \
  --branches All \
  --output "$RESULTS_DIR/${DATASET_PREFIX}_busted_standard.json"

echo "Running BUSTED with synonymous-rate variation..."
hyphy busted \
  "${CODE_ARGS[@]}" \
  --alignment "$ALIGNMENT" \
  --branches All \
  --srv Yes \
  --syn-rates 3 \
  --output "$RESULTS_DIR/${DATASET_PREFIX}_busted_srv.json"

echo "Running BUSTED with multiple-hit model..."
hyphy busted \
  "${CODE_ARGS[@]}" \
  --alignment "$ALIGNMENT" \
  --branches All \
  --multiple-hits Double+Triple \
  --output "$RESULTS_DIR/${DATASET_PREFIX}_busted_multihit.json"

echo "Running FitMultiModel with standard MG94 and multi-hit models..."
hyphy "$FITMULTIMODEL_BF" \
  "${CODE_ARGS[@]}" \
  --alignment "$ALIGNMENT" \
  --rates 1 \
  --triple-islands No \
  --output "$RESULTS_DIR/${DATASET_PREFIX}_fitmultimodel.json"
