#!/usr/bin/env bash
set -uo pipefail

EMPIRICAL_DATA_DIR="${EMPIRICAL_DATA_DIR:-data/21-empirical}"
RESULTS_DIR="${RESULTS_DIR:-results}"
LOG_DIR="${LOG_DIR:-results/logs/all_empirical}"
FORCE="${FORCE:-0}"
MAX_JOBS="${MAX_JOBS:-}"

RUN_BUSTED="${RUN_BUSTED:-0}"
RUN_BUSTED_SRV="${RUN_BUSTED_SRV:-0}"
RUN_BUSTED_MULTIHIT="${RUN_BUSTED_MULTIHIT:-1}" # BUSTED +S +MH
RUN_FITMODEL="${RUN_FITMODEL:-0}"
RUN_FITMULTIMODELMH="${RUN_FITMULTIMODELMH:-0}"
RUN_FEL="${RUN_FEL:-1}"
RUN_MEME="${RUN_MEME:-1}"
RUN_SLAC="${RUN_SLAC:-1}"
RUN_ABSREL="${RUN_ABSREL:-1}"
RUN_COLLECT="${RUN_COLLECT:-1}"

usage() {
  cat <<'USAGE'
Run all empirical HyPhy selection tests for every bundled alignment.

Usage:
  bash scripts/09_run_all_empirical_selection.sh [dataset ...]

Datasets may be full paths or names under data/21-empirical, for example:
  bash scripts/09_run_all_empirical_selection.sh HIVvif.nex lysin.nex

Environment toggles:
  FORCE=1                 rerun methods even if JSON output already exists
  MAX_JOBS=4              run up to 4 HyPhy jobs at once
  RUN_BUSTED=0            skip standard BUSTED
  RUN_BUSTED_SRV=0        skip BUSTED with synonymous-rate variation
  RUN_BUSTED_MULTIHIT=0   skip BUSTED with multiple-hit model
  RUN_FITMULTIMODEL=0     skip FitMultiModel standard MG94 and multi-hit fits
  RUN_FEL=0               skip FEL
  RUN_MEME=0              skip MEME
  RUN_SLAC=0              skip SLAC
  RUN_ABSREL=0            skip aBSREL
  RUN_COLLECT=0           skip scripts/07_collect_results.py at the end

Notes:
  COXI.mtnex is analyzed with --code Invertebrate-mtDNA.
  mammalian_mtDNA.mtnex is analyzed with --code Vertebrate-mtDNA.

Outputs:
  results/session1_gene_wide/
  results/session2_branch_lineage/
  results/session3_site_level/
  results/logs/all_empirical/
  tables/
  figures/
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v hyphy >/dev/null 2>&1; then
  echo "ERROR: hyphy is not on PATH. Activate the conda environment or run scripts/00_setup_colab.sh." >&2
  exit 1
fi

if [[ "$RUN_FITMODEL" == "1" ]]; then
  if [[ -z "${FITMODEL_BF:-}" ]]; then
    HYPHY_PREFIX="$(cd "$(dirname "$(command -v hyphy)")/.." && pwd)"
    FITMODEL_BF="$HYPHY_PREFIX/share/hyphy/TemplateBatchFiles/SelectionAnalyses/FitModel.bf"
  fi
  if [[ ! -s "$FITMODEL_BF" && -s "/usr/local/share/hyphy/TemplateBatchFiles/SelectionAnalyses/FitModel.bf" ]]; then
    FITMODEL_BF="/usr/local/share/hyphy/TemplateBatchFiles/SelectionAnalyses/FitModel.bf"
  fi
  if [[ ! -s "$FITMODEL_BF" ]]; then
    echo "ERROR: could not find FitModel.bf. Set FITMODEL_BF to its full path." >&2
    exit 1
  fi
fi



if [[ "$RUN_FITMULTIMODELMH" == "1" ]]; then
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
fi

mkdir -p \
  "$RESULTS_DIR/session1_gene_wide" \
  "$RESULTS_DIR/session2_branch_lineage" \
  "$RESULTS_DIR/session3_site_level" \
  "$LOG_DIR"

if [[ -z "$MAX_JOBS" ]]; then
  if command -v getconf >/dev/null 2>&1; then
    MAX_JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || true)"
  fi
  if [[ -z "$MAX_JOBS" ]] && command -v sysctl >/dev/null 2>&1; then
    MAX_JOBS="$(sysctl -n hw.ncpu 2>/dev/null || true)"
  fi
  MAX_JOBS="${MAX_JOBS:-2}"
fi
if [[ ! "$MAX_JOBS" =~ ^[0-9]+$ || "$MAX_JOBS" -lt 1 ]]; then
  echo "ERROR: MAX_JOBS must be a positive integer." >&2
  exit 1
fi

dataset_prefix() {
  local name prefix
  name="$(basename "$1")"
  if [[ "$name" == *.mtnex ]]; then
    prefix="${name%.mtnex}"
  else
    prefix="${name%.nex}"
  fi
  prefix="${prefix//[^A-Za-z0-9_]/_}"
  printf '%s\n' "$prefix"
}

resolve_dataset() {
  local value="$1"
  if [[ -s "$value" ]]; then
    printf '%s\n' "$value"
  elif [[ -s "$EMPIRICAL_DATA_DIR/$value" ]]; then
    printf '%s\n' "$EMPIRICAL_DATA_DIR/$value"
  else
    echo "ERROR: dataset not found: $value" >&2
    return 1
  fi
}

discover_datasets() {
  find "$EMPIRICAL_DATA_DIR" -maxdepth 1 -type f \
    \( -name '*.nex' -o -name '*.mtnex' \) \
    | sort
}

genetic_code_for_dataset() {
  local name
  name="$(basename "$1")"
  case "$name" in
    COXI.mtnex)
      printf '%s\n' "Invertebrate-mtDNA"
      ;;
    mammalian_mtDNA.mtnex)
      printf '%s\n' "Vertebrate-mtDNA"
      ;;
    *)
      printf '%s\n' "Universal"
      ;;
  esac
}

run_hyphy() {
  local label="$1"
  local output="$2"
  shift 2
  local log="$LOG_DIR/$(basename "${output%.json}").log"

  echo "RUN  $label"
  echo "LOG  $log"
  "$@" --output "$output" >"$log" 2>&1
  local status=$?
  if [[ "$status" -ne 0 ]]; then
    echo "FAIL $label (exit $status). Last log lines:" >&2
    tail -40 "$log" >&2
    return "$status"
  fi
  echo "DONE $label -> $output"
  return 0
}

active_jobs() {
  jobs -rp | wc -l | tr -d '[:space:]'
}

wait_for_slot() {
  while [[ "$(active_jobs)" -ge "$MAX_JOBS" ]]; do
    sleep 1
  done
}

submit_hyphy() {
  local label="$1"
  local failure_key="$2"
  local output="$3"
  local status_file="$4"
  shift 4

  if [[ -s "$output" && "$FORCE" != "1" ]]; then
    echo "SKIP $label -> $output"
    printf 'OK\t%s\n' "$failure_key" >"$status_file"
    skipped_jobs=$((skipped_jobs + 1))
    return 0
  fi

  wait_for_slot
  submitted_jobs=$((submitted_jobs + 1))
  (
    if run_hyphy "$label" "$output" "$@"; then
      printf 'OK\t%s\n' "$failure_key" >"$status_file"
    else
      printf 'FAIL\t%s\n' "$failure_key" >"$status_file"
    fi
  ) &
}

datasets=()
if [[ "$#" -gt 0 ]]; then
  for arg in "$@"; do
    if resolved="$(resolve_dataset "$arg")"; then
      datasets+=("$resolved")
    else
      exit 1
    fi
  done
else
  while IFS= read -r path; do
    datasets+=("$path")
  done < <(discover_datasets)
fi

if [[ "${#datasets[@]}" -eq 0 ]]; then
  echo "ERROR: no empirical datasets found in $EMPIRICAL_DATA_DIR" >&2
  exit 1
fi

echo "Running empirical selection tests with MAX_JOBS=$MAX_JOBS"

job_id=0
submitted_jobs=0
skipped_jobs=0
status_dir="$LOG_DIR/status_$(date +%Y%m%d_%H%M%S)_$$"
mkdir -p "$status_dir"
status_files=()

for alignment in "${datasets[@]}"; do
  prefix="$(dataset_prefix "$alignment")"
  genetic_code="$(genetic_code_for_dataset "$alignment")"
  code_args=(--code "$genetic_code")
  echo
  echo "=== $prefix ($alignment) ==="
  echo "Genetic code: $genetic_code"
 
  # BUSTED --------------------------------------------------------------------
  if [[ "$RUN_BUSTED" == "1" ]]; then
    job_id=$((job_id + 1))
    status_files+=("$status_dir/$job_id.status")
    submit_hyphy "$prefix BUSTED standard" "$prefix busted_standard" \
      "$RESULTS_DIR/session1_gene_wide/${prefix}_busted_standard.json" \
      "$status_dir/$job_id.status" \
      hyphy busted "${code_args[@]}" --alignment "$alignment" --srv No --branches All
  fi

  if [[ "$RUN_BUSTED_SRV" == "1" ]]; then
    job_id=$((job_id + 1))
    status_files+=("$status_dir/$job_id.status")
    submit_hyphy "$prefix BUSTED SRV" "$prefix busted_srv" \
      "$RESULTS_DIR/session1_gene_wide/${prefix}_busted_srv.json" \
      "$status_dir/$job_id.status" \
      hyphy busted "${code_args[@]}" --alignment "$alignment" --branches All --srv Yes --syn-rates 3
  fi

  if [[ "$RUN_BUSTED_MULTIHIT" == "1" ]]; then
    job_id=$((job_id + 1))
    status_files+=("$status_dir/$job_id.status")
    submit_hyphy "$prefix BUSTED multi-hit" "$prefix busted_multihit" \
      "$RESULTS_DIR/session1_gene_wide/${prefix}_busted_multihit.json" \
      "$status_dir/$job_id.status" \
      hyphy busted "${code_args[@]}" --alignment "$alignment" --branches All --srv Yes --multiple-hits Double+Triple
  fi

  # MG94 ----------------------------------------------------------------------
  if [[ "$RUN_FITMODEL" == "1" ]]; then
    job_id=$((job_id + 1))
    status_files+=("$status_dir/$job_id.status")
    submit_hyphy "$prefix FitModel MG94" "$prefix fitmodel" \
      "$RESULTS_DIR/session1_gene_wide/${prefix}_fitmodel.json" \
      "$status_dir/$job_id.status" \
      hyphy "$FITMODEL_BF" "${code_args[@]}" --alignment "$alignment"
  fi
  
  if [[ "$RUN_FITMULTIMODELMH" == "1" ]]; then
    job_id=$((job_id + 1))
    status_files+=("$status_dir/$job_id.status")
    submit_hyphy "$prefix FitMultiModel MG94/multi-hit" "$prefix fitmultimodel" \
      "$RESULTS_DIR/session1_gene_wide/${prefix}_fitmultimodelmh.json" \
      "$status_dir/$job_id.status" \
      hyphy "$FITMULTIMODEL_BF" "${code_args[@]}" --alignment "$alignment" --rates 3 --triple-islands No
  fi

  # aBSREL --------------------------------------------------------------------
  if [[ "$RUN_ABSREL" == "1" ]]; then
    job_id=$((job_id + 1))
    status_files+=("$status_dir/$job_id.status")
    submit_hyphy "$prefix aBSREL" "$prefix absrel" \
      "$RESULTS_DIR/session2_branch_lineage/${prefix}_absrel.json" \
      "$status_dir/$job_id.status" \
      hyphy absrel "${code_args[@]}" --alignment "$alignment" --branches All
  fi

  # FEL, MEME, and SLAC
  if [[ "$RUN_FEL" == "1" ]]; then
    job_id=$((job_id + 1))
    status_files+=("$status_dir/$job_id.status")
    submit_hyphy "$prefix FEL" "$prefix fel" \
      "$RESULTS_DIR/session3_site_level/${prefix}_fel.json" \
      "$status_dir/$job_id.status" \
      hyphy fel "${code_args[@]}" --alignment "$alignment" --branches All --srv Yes
  fi

  if [[ "$RUN_MEME" == "1" ]]; then
    job_id=$((job_id + 1))
    status_files+=("$status_dir/$job_id.status")
    submit_hyphy "$prefix MEME" "$prefix meme" \
      "$RESULTS_DIR/session3_site_level/${prefix}_meme.json" \
      "$status_dir/$job_id.status" \
      hyphy meme "${code_args[@]}" --alignment "$alignment" --branches All
  fi

  if [[ "$RUN_SLAC" == "1" ]]; then
    job_id=$((job_id + 1))
    status_files+=("$status_dir/$job_id.status")
    submit_hyphy "$prefix SLAC" "$prefix slac" \
      "$RESULTS_DIR/session3_site_level/${prefix}_slac.json" \
      "$status_dir/$job_id.status" \
      hyphy slac "${code_args[@]}" --alignment "$alignment" --branches All
  fi
done

if [[ "$submitted_jobs" -gt 0 ]]; then
  echo
  echo "Checked $job_id enabled method/dataset combination(s): submitted $submitted_jobs HyPhy job(s), skipped $skipped_jobs existing output(s)."
  echo "Waiting for submitted jobs to complete..."
  wait
elif [[ "$job_id" -gt 0 ]]; then
  echo
  echo "Checked $job_id enabled method/dataset combination(s): submitted 0 HyPhy jobs, skipped $skipped_jobs existing output(s)."
else
  echo
  echo "No HyPhy jobs were enabled."
fi

failures=()
if [[ "$job_id" -gt 0 ]]; then
  for status_file in "${status_files[@]}"; do
    if [[ ! -s "$status_file" ]]; then
      failures+=("missing status: $(basename "$status_file")")
      continue
    fi
    IFS=$'\t' read -r status failure_key <"$status_file"
    if [[ "$status" == "FAIL" ]]; then
      failures+=("$failure_key")
    fi
  done
fi

if [[ "$RUN_COLLECT" == "1" ]]; then
  echo
  echo "Collecting result tables and figures..."
  if ! python scripts/07_collect_results.py; then
    failures+=("collect_results")
  fi
fi

echo
if [[ "${#failures[@]}" -gt 0 ]]; then
  echo "Completed with ${#failures[@]} failure(s):" >&2
  printf '  %s\n' "${failures[@]}" >&2
  exit 1
fi

echo "Completed all requested empirical selection tests."
