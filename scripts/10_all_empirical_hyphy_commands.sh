#!/usr/bin/env bash
set -uo pipefail

# Explicit HyPhy command ledger for every bundled empirical sample.
#
# Default behavior runs every command. To print the commands without running them:
#   DRY_RUN=1 bash scripts/10_all_empirical_hyphy_commands.sh
#
# To rerun existing outputs:
#   FORCE=1 bash scripts/10_all_empirical_hyphy_commands.sh

RESULTS_DIR="${RESULTS_DIR:-results}"
LOG_DIR="${LOG_DIR:-results/logs/all_empirical_commands}"
DRY_RUN="${DRY_RUN:-0}"
FORCE="${FORCE:-0}"
RUN_COLLECT="${RUN_COLLECT:-1}"

if ! command -v hyphy >/dev/null 2>&1; then
  echo "ERROR: hyphy is not on PATH. Activate the conda environment or run scripts/00_setup_colab.sh." >&2
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

mkdir -p \
  "$RESULTS_DIR/session1_gene_wide" \
  "$RESULTS_DIR/session2_branch_lineage" \
  "$RESULTS_DIR/session3_site_level" \
  "$LOG_DIR"

quote_cmd() {
  printf "%q " "$@"
  printf "\n"
}

run_cmd() {
  local label="$1"
  local output="$2"
  shift 2
  local log="$LOG_DIR/$(basename "${output%.json}").log"

  echo
  echo "# $label"
  quote_cmd "$@" --output "$output"

  if [[ "$DRY_RUN" == "1" ]]; then
    return 0
  fi
  if [[ -s "$output" && "$FORCE" != "1" ]]; then
    echo "SKIP existing output: $output"
    return 0
  fi

  "$@" --output "$output" >"$log" 2>&1
  local status=$?
  if [[ "$status" -ne 0 ]]; then
    echo "FAIL $label (exit $status). See $log" >&2
    return "$status"
  fi
  echo "DONE $label -> $output"
}

failures=()

# ===== Bacterial_PTS_trehalose_transporter_suIII =====
run_cmd "Bacterial_PTS_trehalose_transporter_suIII / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/Bacterial_PTS_trehalose_transporter_suIII_busted_standard.json" hyphy busted --alignment data/21-empirical/Bacterial_PTS_trehalose_transporter_suIII.nex --branches All || failures+=("Bacterial_PTS_trehalose_transporter_suIII busted_standard")
run_cmd "Bacterial_PTS_trehalose_transporter_suIII / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/Bacterial_PTS_trehalose_transporter_suIII_busted_srv.json" hyphy busted --alignment data/21-empirical/Bacterial_PTS_trehalose_transporter_suIII.nex --branches All --srv Yes --syn-rates 3 || failures+=("Bacterial_PTS_trehalose_transporter_suIII busted_srv")
run_cmd "Bacterial_PTS_trehalose_transporter_suIII / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/Bacterial_PTS_trehalose_transporter_suIII_busted_multihit.json" hyphy busted --alignment data/21-empirical/Bacterial_PTS_trehalose_transporter_suIII.nex --branches All --multiple-hits Double+Triple || failures+=("Bacterial_PTS_trehalose_transporter_suIII busted_multihit")
run_cmd "Bacterial_PTS_trehalose_transporter_suIII / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/Bacterial_PTS_trehalose_transporter_suIII_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/Bacterial_PTS_trehalose_transporter_suIII.nex --rates 1 --triple-islands No || failures+=("Bacterial_PTS_trehalose_transporter_suIII fitmultimodel")

run_cmd "Bacterial_PTS_trehalose_transporter_suIII / aBSREL" "$RESULTS_DIR/session2_branch_lineage/Bacterial_PTS_trehalose_transporter_suIII_absrel.json" hyphy absrel --alignment data/21-empirical/Bacterial_PTS_trehalose_transporter_suIII.nex --branches All || failures+=("Bacterial_PTS_trehalose_transporter_suIII absrel")
run_cmd "Bacterial_PTS_trehalose_transporter_suIII / FEL" "$RESULTS_DIR/session3_site_level/Bacterial_PTS_trehalose_transporter_suIII_fel.json" hyphy fel --alignment data/21-empirical/Bacterial_PTS_trehalose_transporter_suIII.nex --branches All --srv Yes || failures+=("Bacterial_PTS_trehalose_transporter_suIII fel")
run_cmd "Bacterial_PTS_trehalose_transporter_suIII / MEME" "$RESULTS_DIR/session3_site_level/Bacterial_PTS_trehalose_transporter_suIII_meme.json" hyphy meme --alignment data/21-empirical/Bacterial_PTS_trehalose_transporter_suIII.nex --branches All || failures+=("Bacterial_PTS_trehalose_transporter_suIII meme")
run_cmd "Bacterial_PTS_trehalose_transporter_suIII / SLAC" "$RESULTS_DIR/session3_site_level/Bacterial_PTS_trehalose_transporter_suIII_slac.json" hyphy slac --alignment data/21-empirical/Bacterial_PTS_trehalose_transporter_suIII.nex --branches All || failures+=("Bacterial_PTS_trehalose_transporter_suIII slac")
# ===== COXI =====
run_cmd "COXI / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/COXI_busted_standard.json" hyphy busted --code Invertebrate-mtDNA --alignment data/21-empirical/COXI.mtnex --branches All || failures+=("COXI busted_standard")
run_cmd "COXI / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/COXI_busted_srv.json" hyphy busted --code Invertebrate-mtDNA --alignment data/21-empirical/COXI.mtnex --branches All --srv Yes --syn-rates 3 || failures+=("COXI busted_srv")
run_cmd "COXI / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/COXI_busted_multihit.json" hyphy busted --code Invertebrate-mtDNA --alignment data/21-empirical/COXI.mtnex --branches All --multiple-hits Double+Triple || failures+=("COXI busted_multihit")
run_cmd "COXI / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/COXI_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --code Invertebrate-mtDNA --alignment data/21-empirical/COXI.mtnex --rates 1 --triple-islands No || failures+=("COXI fitmultimodel")

run_cmd "COXI / aBSREL" "$RESULTS_DIR/session2_branch_lineage/COXI_absrel.json" hyphy absrel --code Invertebrate-mtDNA --alignment data/21-empirical/COXI.mtnex --branches All || failures+=("COXI absrel")
run_cmd "COXI / FEL" "$RESULTS_DIR/session3_site_level/COXI_fel.json" hyphy fel --code Invertebrate-mtDNA --alignment data/21-empirical/COXI.mtnex --branches All --srv Yes || failures+=("COXI fel")
run_cmd "COXI / MEME" "$RESULTS_DIR/session3_site_level/COXI_meme.json" hyphy meme --code Invertebrate-mtDNA --alignment data/21-empirical/COXI.mtnex --branches All || failures+=("COXI meme")
run_cmd "COXI / SLAC" "$RESULTS_DIR/session3_site_level/COXI_slac.json" hyphy slac --code Invertebrate-mtDNA --alignment data/21-empirical/COXI.mtnex --branches All || failures+=("COXI slac")
# ===== ENCenv =====
run_cmd "ENCenv / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/ENCenv_busted_standard.json" hyphy busted --alignment data/21-empirical/ENCenv.nex --branches All || failures+=("ENCenv busted_standard")
run_cmd "ENCenv / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/ENCenv_busted_srv.json" hyphy busted --alignment data/21-empirical/ENCenv.nex --branches All --srv Yes --syn-rates 3 || failures+=("ENCenv busted_srv")
run_cmd "ENCenv / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/ENCenv_busted_multihit.json" hyphy busted --alignment data/21-empirical/ENCenv.nex --branches All --multiple-hits Double+Triple || failures+=("ENCenv busted_multihit")
run_cmd "ENCenv / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/ENCenv_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/ENCenv.nex --rates 1 --triple-islands No || failures+=("ENCenv fitmultimodel")

run_cmd "ENCenv / aBSREL" "$RESULTS_DIR/session2_branch_lineage/ENCenv_absrel.json" hyphy absrel --alignment data/21-empirical/ENCenv.nex --branches All || failures+=("ENCenv absrel")
run_cmd "ENCenv / FEL" "$RESULTS_DIR/session3_site_level/ENCenv_fel.json" hyphy fel --alignment data/21-empirical/ENCenv.nex --branches All --srv Yes || failures+=("ENCenv fel")
run_cmd "ENCenv / MEME" "$RESULTS_DIR/session3_site_level/ENCenv_meme.json" hyphy meme --alignment data/21-empirical/ENCenv.nex --branches All || failures+=("ENCenv meme")
run_cmd "ENCenv / SLAC" "$RESULTS_DIR/session3_site_level/ENCenv_slac.json" hyphy slac --alignment data/21-empirical/ENCenv.nex --branches All || failures+=("ENCenv slac")
# ===== HIV_RT =====
run_cmd "HIV_RT / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/HIV_RT_busted_standard.json" hyphy busted --alignment data/21-empirical/HIV_RT.nex --branches All || failures+=("HIV_RT busted_standard")
run_cmd "HIV_RT / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/HIV_RT_busted_srv.json" hyphy busted --alignment data/21-empirical/HIV_RT.nex --branches All --srv Yes --syn-rates 3 || failures+=("HIV_RT busted_srv")
run_cmd "HIV_RT / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/HIV_RT_busted_multihit.json" hyphy busted --alignment data/21-empirical/HIV_RT.nex --branches All --multiple-hits Double+Triple || failures+=("HIV_RT busted_multihit")
run_cmd "HIV_RT / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/HIV_RT_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/HIV_RT.nex --rates 1 --triple-islands No || failures+=("HIV_RT fitmultimodel")

run_cmd "HIV_RT / aBSREL" "$RESULTS_DIR/session2_branch_lineage/HIV_RT_absrel.json" hyphy absrel --alignment data/21-empirical/HIV_RT.nex --branches All || failures+=("HIV_RT absrel")
run_cmd "HIV_RT / FEL" "$RESULTS_DIR/session3_site_level/HIV_RT_fel.json" hyphy fel --alignment data/21-empirical/HIV_RT.nex --branches All --srv Yes || failures+=("HIV_RT fel")
run_cmd "HIV_RT / MEME" "$RESULTS_DIR/session3_site_level/HIV_RT_meme.json" hyphy meme --alignment data/21-empirical/HIV_RT.nex --branches All || failures+=("HIV_RT meme")
run_cmd "HIV_RT / SLAC" "$RESULTS_DIR/session3_site_level/HIV_RT_slac.json" hyphy slac --alignment data/21-empirical/HIV_RT.nex --branches All || failures+=("HIV_RT slac")
# ===== HIVvif =====
run_cmd "HIVvif / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/HIVvif_busted_standard.json" hyphy busted --alignment data/21-empirical/HIVvif.nex --branches All || failures+=("HIVvif busted_standard")
run_cmd "HIVvif / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/HIVvif_busted_srv.json" hyphy busted --alignment data/21-empirical/HIVvif.nex --branches All --srv Yes --syn-rates 3 || failures+=("HIVvif busted_srv")
run_cmd "HIVvif / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/HIVvif_busted_multihit.json" hyphy busted --alignment data/21-empirical/HIVvif.nex --branches All --multiple-hits Double+Triple || failures+=("HIVvif busted_multihit")
run_cmd "HIVvif / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/HIVvif_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/HIVvif.nex --rates 1 --triple-islands No || failures+=("HIVvif fitmultimodel")

run_cmd "HIVvif / aBSREL" "$RESULTS_DIR/session2_branch_lineage/HIVvif_absrel.json" hyphy absrel --alignment data/21-empirical/HIVvif.nex --branches All || failures+=("HIVvif absrel")
run_cmd "HIVvif / FEL" "$RESULTS_DIR/session3_site_level/HIVvif_fel.json" hyphy fel --alignment data/21-empirical/HIVvif.nex --branches All --srv Yes || failures+=("HIVvif fel")
run_cmd "HIVvif / MEME" "$RESULTS_DIR/session3_site_level/HIVvif_meme.json" hyphy meme --alignment data/21-empirical/HIVvif.nex --branches All || failures+=("HIVvif meme")
run_cmd "HIVvif / SLAC" "$RESULTS_DIR/session3_site_level/HIVvif_slac.json" hyphy slac --alignment data/21-empirical/HIVvif.nex --branches All || failures+=("HIVvif slac")
# ===== HepatitisD =====
run_cmd "HepatitisD / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/HepatitisD_busted_standard.json" hyphy busted --alignment data/21-empirical/HepatitisD.nex --branches All || failures+=("HepatitisD busted_standard")
run_cmd "HepatitisD / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/HepatitisD_busted_srv.json" hyphy busted --alignment data/21-empirical/HepatitisD.nex --branches All --srv Yes --syn-rates 3 || failures+=("HepatitisD busted_srv")
run_cmd "HepatitisD / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/HepatitisD_busted_multihit.json" hyphy busted --alignment data/21-empirical/HepatitisD.nex --branches All --multiple-hits Double+Triple || failures+=("HepatitisD busted_multihit")
run_cmd "HepatitisD / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/HepatitisD_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/HepatitisD.nex --rates 1 --triple-islands No || failures+=("HepatitisD fitmultimodel")

run_cmd "HepatitisD / aBSREL" "$RESULTS_DIR/session2_branch_lineage/HepatitisD_absrel.json" hyphy absrel --alignment data/21-empirical/HepatitisD.nex --branches All || failures+=("HepatitisD absrel")
run_cmd "HepatitisD / FEL" "$RESULTS_DIR/session3_site_level/HepatitisD_fel.json" hyphy fel --alignment data/21-empirical/HepatitisD.nex --branches All --srv Yes || failures+=("HepatitisD fel")
run_cmd "HepatitisD / MEME" "$RESULTS_DIR/session3_site_level/HepatitisD_meme.json" hyphy meme --alignment data/21-empirical/HepatitisD.nex --branches All || failures+=("HepatitisD meme")
run_cmd "HepatitisD / SLAC" "$RESULTS_DIR/session3_site_level/HepatitisD_slac.json" hyphy slac --alignment data/21-empirical/HepatitisD.nex --branches All || failures+=("HepatitisD slac")
# ===== IAV_human_H1N1_HA =====
run_cmd "IAV_human_H1N1_HA / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/IAV_human_H1N1_HA_busted_standard.json" hyphy busted --alignment data/21-empirical/IAV-human-H1N1-HA.nex --branches All || failures+=("IAV_human_H1N1_HA busted_standard")
run_cmd "IAV_human_H1N1_HA / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/IAV_human_H1N1_HA_busted_srv.json" hyphy busted --alignment data/21-empirical/IAV-human-H1N1-HA.nex --branches All --srv Yes --syn-rates 3 || failures+=("IAV_human_H1N1_HA busted_srv")
run_cmd "IAV_human_H1N1_HA / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/IAV_human_H1N1_HA_busted_multihit.json" hyphy busted --alignment data/21-empirical/IAV-human-H1N1-HA.nex --branches All --multiple-hits Double+Triple || failures+=("IAV_human_H1N1_HA busted_multihit")
run_cmd "IAV_human_H1N1_HA / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/IAV_human_H1N1_HA_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/IAV-human-H1N1-HA.nex --rates 1 --triple-islands No || failures+=("IAV_human_H1N1_HA fitmultimodel")

run_cmd "IAV_human_H1N1_HA / aBSREL" "$RESULTS_DIR/session2_branch_lineage/IAV_human_H1N1_HA_absrel.json" hyphy absrel --alignment data/21-empirical/IAV-human-H1N1-HA.nex --branches All || failures+=("IAV_human_H1N1_HA absrel")
run_cmd "IAV_human_H1N1_HA / FEL" "$RESULTS_DIR/session3_site_level/IAV_human_H1N1_HA_fel.json" hyphy fel --alignment data/21-empirical/IAV-human-H1N1-HA.nex --branches All --srv Yes || failures+=("IAV_human_H1N1_HA fel")
run_cmd "IAV_human_H1N1_HA / MEME" "$RESULTS_DIR/session3_site_level/IAV_human_H1N1_HA_meme.json" hyphy meme --alignment data/21-empirical/IAV-human-H1N1-HA.nex --branches All || failures+=("IAV_human_H1N1_HA meme")
run_cmd "IAV_human_H1N1_HA / SLAC" "$RESULTS_DIR/session3_site_level/IAV_human_H1N1_HA_slac.json" hyphy slac --alignment data/21-empirical/IAV-human-H1N1-HA.nex --branches All || failures+=("IAV_human_H1N1_HA slac")
# ===== InfluenzaA =====
run_cmd "InfluenzaA / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/InfluenzaA_busted_standard.json" hyphy busted --alignment data/21-empirical/InfluenzaA.nex --branches All || failures+=("InfluenzaA busted_standard")
run_cmd "InfluenzaA / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/InfluenzaA_busted_srv.json" hyphy busted --alignment data/21-empirical/InfluenzaA.nex --branches All --srv Yes --syn-rates 3 || failures+=("InfluenzaA busted_srv")
run_cmd "InfluenzaA / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/InfluenzaA_busted_multihit.json" hyphy busted --alignment data/21-empirical/InfluenzaA.nex --branches All --multiple-hits Double+Triple || failures+=("InfluenzaA busted_multihit")
run_cmd "InfluenzaA / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/InfluenzaA_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/InfluenzaA.nex --rates 1 --triple-islands No || failures+=("InfluenzaA fitmultimodel")

run_cmd "InfluenzaA / aBSREL" "$RESULTS_DIR/session2_branch_lineage/InfluenzaA_absrel.json" hyphy absrel --alignment data/21-empirical/InfluenzaA.nex --branches All || failures+=("InfluenzaA absrel")
run_cmd "InfluenzaA / FEL" "$RESULTS_DIR/session3_site_level/InfluenzaA_fel.json" hyphy fel --alignment data/21-empirical/InfluenzaA.nex --branches All --srv Yes || failures+=("InfluenzaA fel")
run_cmd "InfluenzaA / MEME" "$RESULTS_DIR/session3_site_level/InfluenzaA_meme.json" hyphy meme --alignment data/21-empirical/InfluenzaA.nex --branches All || failures+=("InfluenzaA meme")
run_cmd "InfluenzaA / SLAC" "$RESULTS_DIR/session3_site_level/InfluenzaA_slac.json" hyphy slac --alignment data/21-empirical/InfluenzaA.nex --branches All || failures+=("InfluenzaA slac")
# ===== SARS_CoV_2_spike =====
run_cmd "SARS_CoV_2_spike / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/SARS_CoV_2_spike_busted_standard.json" hyphy busted --alignment data/21-empirical/SARS-CoV-2-spike.nex --branches All || failures+=("SARS_CoV_2_spike busted_standard")
run_cmd "SARS_CoV_2_spike / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/SARS_CoV_2_spike_busted_srv.json" hyphy busted --alignment data/21-empirical/SARS-CoV-2-spike.nex --branches All --srv Yes --syn-rates 3 || failures+=("SARS_CoV_2_spike busted_srv")
run_cmd "SARS_CoV_2_spike / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/SARS_CoV_2_spike_busted_multihit.json" hyphy busted --alignment data/21-empirical/SARS-CoV-2-spike.nex --branches All --multiple-hits Double+Triple || failures+=("SARS_CoV_2_spike busted_multihit")
run_cmd "SARS_CoV_2_spike / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/SARS_CoV_2_spike_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/SARS-CoV-2-spike.nex --rates 1 --triple-islands No || failures+=("SARS_CoV_2_spike fitmultimodel")

run_cmd "SARS_CoV_2_spike / aBSREL" "$RESULTS_DIR/session2_branch_lineage/SARS_CoV_2_spike_absrel.json" hyphy absrel --alignment data/21-empirical/SARS-CoV-2-spike.nex --branches All || failures+=("SARS_CoV_2_spike absrel")
run_cmd "SARS_CoV_2_spike / FEL" "$RESULTS_DIR/session3_site_level/SARS_CoV_2_spike_fel.json" hyphy fel --alignment data/21-empirical/SARS-CoV-2-spike.nex --branches All --srv Yes || failures+=("SARS_CoV_2_spike fel")
run_cmd "SARS_CoV_2_spike / MEME" "$RESULTS_DIR/session3_site_level/SARS_CoV_2_spike_meme.json" hyphy meme --alignment data/21-empirical/SARS-CoV-2-spike.nex --branches All || failures+=("SARS_CoV_2_spike meme")
run_cmd "SARS_CoV_2_spike / SLAC" "$RESULTS_DIR/session3_site_level/SARS_CoV_2_spike_slac.json" hyphy slac --alignment data/21-empirical/SARS-CoV-2-spike.nex --branches All || failures+=("SARS_CoV_2_spike slac")
# ===== adh =====
run_cmd "adh / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/adh_busted_standard.json" hyphy busted --alignment data/21-empirical/adh.nex --branches All || failures+=("adh busted_standard")
run_cmd "adh / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/adh_busted_srv.json" hyphy busted --alignment data/21-empirical/adh.nex --branches All --srv Yes --syn-rates 3 || failures+=("adh busted_srv")
run_cmd "adh / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/adh_busted_multihit.json" hyphy busted --alignment data/21-empirical/adh.nex --branches All --multiple-hits Double+Triple || failures+=("adh busted_multihit")
run_cmd "adh / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/adh_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/adh.nex --rates 1 --triple-islands No || failures+=("adh fitmultimodel")

run_cmd "adh / aBSREL" "$RESULTS_DIR/session2_branch_lineage/adh_absrel.json" hyphy absrel --alignment data/21-empirical/adh.nex --branches All || failures+=("adh absrel")
run_cmd "adh / FEL" "$RESULTS_DIR/session3_site_level/adh_fel.json" hyphy fel --alignment data/21-empirical/adh.nex --branches All --srv Yes || failures+=("adh fel")
run_cmd "adh / MEME" "$RESULTS_DIR/session3_site_level/adh_meme.json" hyphy meme --alignment data/21-empirical/adh.nex --branches All || failures+=("adh meme")
run_cmd "adh / SLAC" "$RESULTS_DIR/session3_site_level/adh_slac.json" hyphy slac --alignment data/21-empirical/adh.nex --branches All || failures+=("adh slac")
# ===== adora3 =====
run_cmd "adora3 / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/adora3_busted_standard.json" hyphy busted --alignment data/21-empirical/adora3.nex --branches All || failures+=("adora3 busted_standard")
run_cmd "adora3 / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/adora3_busted_srv.json" hyphy busted --alignment data/21-empirical/adora3.nex --branches All --srv Yes --syn-rates 3 || failures+=("adora3 busted_srv")
run_cmd "adora3 / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/adora3_busted_multihit.json" hyphy busted --alignment data/21-empirical/adora3.nex --branches All --multiple-hits Double+Triple || failures+=("adora3 busted_multihit")
run_cmd "adora3 / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/adora3_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/adora3.nex --rates 1 --triple-islands No || failures+=("adora3 fitmultimodel")

run_cmd "adora3 / aBSREL" "$RESULTS_DIR/session2_branch_lineage/adora3_absrel.json" hyphy absrel --alignment data/21-empirical/adora3.nex --branches All || failures+=("adora3 absrel")
run_cmd "adora3 / FEL" "$RESULTS_DIR/session3_site_level/adora3_fel.json" hyphy fel --alignment data/21-empirical/adora3.nex --branches All --srv Yes || failures+=("adora3 fel")
run_cmd "adora3 / MEME" "$RESULTS_DIR/session3_site_level/adora3_meme.json" hyphy meme --alignment data/21-empirical/adora3.nex --branches All || failures+=("adora3 meme")
run_cmd "adora3 / SLAC" "$RESULTS_DIR/session3_site_level/adora3_slac.json" hyphy slac --alignment data/21-empirical/adora3.nex --branches All || failures+=("adora3 slac")
# ===== bglobin =====
run_cmd "bglobin / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/bglobin_busted_standard.json" hyphy busted --alignment data/21-empirical/bglobin.nex --branches All || failures+=("bglobin busted_standard")
run_cmd "bglobin / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/bglobin_busted_srv.json" hyphy busted --alignment data/21-empirical/bglobin.nex --branches All --srv Yes --syn-rates 3 || failures+=("bglobin busted_srv")
run_cmd "bglobin / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/bglobin_busted_multihit.json" hyphy busted --alignment data/21-empirical/bglobin.nex --branches All --multiple-hits Double+Triple || failures+=("bglobin busted_multihit")
run_cmd "bglobin / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/bglobin_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/bglobin.nex --rates 1 --triple-islands No || failures+=("bglobin fitmultimodel")

run_cmd "bglobin / aBSREL" "$RESULTS_DIR/session2_branch_lineage/bglobin_absrel.json" hyphy absrel --alignment data/21-empirical/bglobin.nex --branches All || failures+=("bglobin absrel")
run_cmd "bglobin / FEL" "$RESULTS_DIR/session3_site_level/bglobin_fel.json" hyphy fel --alignment data/21-empirical/bglobin.nex --branches All --srv Yes || failures+=("bglobin fel")
run_cmd "bglobin / MEME" "$RESULTS_DIR/session3_site_level/bglobin_meme.json" hyphy meme --alignment data/21-empirical/bglobin.nex --branches All || failures+=("bglobin meme")
run_cmd "bglobin / SLAC" "$RESULTS_DIR/session3_site_level/bglobin_slac.json" hyphy slac --alignment data/21-empirical/bglobin.nex --branches All || failures+=("bglobin slac")
# ===== camelid =====
run_cmd "camelid / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/camelid_busted_standard.json" hyphy busted --alignment data/21-empirical/camelid.nex --branches All || failures+=("camelid busted_standard")
run_cmd "camelid / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/camelid_busted_srv.json" hyphy busted --alignment data/21-empirical/camelid.nex --branches All --srv Yes --syn-rates 3 || failures+=("camelid busted_srv")
run_cmd "camelid / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/camelid_busted_multihit.json" hyphy busted --alignment data/21-empirical/camelid.nex --branches All --multiple-hits Double+Triple || failures+=("camelid busted_multihit")
run_cmd "camelid / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/camelid_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/camelid.nex --rates 1 --triple-islands No || failures+=("camelid fitmultimodel")

run_cmd "camelid / aBSREL" "$RESULTS_DIR/session2_branch_lineage/camelid_absrel.json" hyphy absrel --alignment data/21-empirical/camelid.nex --branches All || failures+=("camelid absrel")
run_cmd "camelid / FEL" "$RESULTS_DIR/session3_site_level/camelid_fel.json" hyphy fel --alignment data/21-empirical/camelid.nex --branches All --srv Yes || failures+=("camelid fel")
run_cmd "camelid / MEME" "$RESULTS_DIR/session3_site_level/camelid_meme.json" hyphy meme --alignment data/21-empirical/camelid.nex --branches All || failures+=("camelid meme")
run_cmd "camelid / SLAC" "$RESULTS_DIR/session3_site_level/camelid_slac.json" hyphy slac --alignment data/21-empirical/camelid.nex --branches All || failures+=("camelid slac")
# ===== flavNS5 =====
run_cmd "flavNS5 / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/flavNS5_busted_standard.json" hyphy busted --alignment data/21-empirical/flavNS5.nex --branches All || failures+=("flavNS5 busted_standard")
run_cmd "flavNS5 / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/flavNS5_busted_srv.json" hyphy busted --alignment data/21-empirical/flavNS5.nex --branches All --srv Yes --syn-rates 3 || failures+=("flavNS5 busted_srv")
run_cmd "flavNS5 / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/flavNS5_busted_multihit.json" hyphy busted --alignment data/21-empirical/flavNS5.nex --branches All --multiple-hits Double+Triple || failures+=("flavNS5 busted_multihit")
run_cmd "flavNS5 / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/flavNS5_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/flavNS5.nex --rates 1 --triple-islands No || failures+=("flavNS5 fitmultimodel")

run_cmd "flavNS5 / aBSREL" "$RESULTS_DIR/session2_branch_lineage/flavNS5_absrel.json" hyphy absrel --alignment data/21-empirical/flavNS5.nex --branches All || failures+=("flavNS5 absrel")
run_cmd "flavNS5 / FEL" "$RESULTS_DIR/session3_site_level/flavNS5_fel.json" hyphy fel --alignment data/21-empirical/flavNS5.nex --branches All --srv Yes || failures+=("flavNS5 fel")
run_cmd "flavNS5 / MEME" "$RESULTS_DIR/session3_site_level/flavNS5_meme.json" hyphy meme --alignment data/21-empirical/flavNS5.nex --branches All || failures+=("flavNS5 meme")
run_cmd "flavNS5 / SLAC" "$RESULTS_DIR/session3_site_level/flavNS5_slac.json" hyphy slac --alignment data/21-empirical/flavNS5.nex --branches All || failures+=("flavNS5 slac")
# ===== lysin =====
run_cmd "lysin / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/lysin_busted_standard.json" hyphy busted --alignment data/21-empirical/lysin.nex --branches All || failures+=("lysin busted_standard")
run_cmd "lysin / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/lysin_busted_srv.json" hyphy busted --alignment data/21-empirical/lysin.nex --branches All --srv Yes --syn-rates 3 || failures+=("lysin busted_srv")
run_cmd "lysin / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/lysin_busted_multihit.json" hyphy busted --alignment data/21-empirical/lysin.nex --branches All --multiple-hits Double+Triple || failures+=("lysin busted_multihit")
run_cmd "lysin / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/lysin_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/lysin.nex --rates 1 --triple-islands No || failures+=("lysin fitmultimodel")

run_cmd "lysin / aBSREL" "$RESULTS_DIR/session2_branch_lineage/lysin_absrel.json" hyphy absrel --alignment data/21-empirical/lysin.nex --branches All || failures+=("lysin absrel")
run_cmd "lysin / FEL" "$RESULTS_DIR/session3_site_level/lysin_fel.json" hyphy fel --alignment data/21-empirical/lysin.nex --branches All --srv Yes || failures+=("lysin fel")
run_cmd "lysin / MEME" "$RESULTS_DIR/session3_site_level/lysin_meme.json" hyphy meme --alignment data/21-empirical/lysin.nex --branches All || failures+=("lysin meme")
run_cmd "lysin / SLAC" "$RESULTS_DIR/session3_site_level/lysin_slac.json" hyphy slac --alignment data/21-empirical/lysin.nex --branches All || failures+=("lysin slac")
# ===== lysozyme =====
run_cmd "lysozyme / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/lysozyme_busted_standard.json" hyphy busted --alignment data/21-empirical/lysozyme.nex --branches All || failures+=("lysozyme busted_standard")
run_cmd "lysozyme / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/lysozyme_busted_srv.json" hyphy busted --alignment data/21-empirical/lysozyme.nex --branches All --srv Yes --syn-rates 3 || failures+=("lysozyme busted_srv")
run_cmd "lysozyme / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/lysozyme_busted_multihit.json" hyphy busted --alignment data/21-empirical/lysozyme.nex --branches All --multiple-hits Double+Triple || failures+=("lysozyme busted_multihit")
run_cmd "lysozyme / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/lysozyme_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/lysozyme.nex --rates 1 --triple-islands No || failures+=("lysozyme fitmultimodel")

run_cmd "lysozyme / aBSREL" "$RESULTS_DIR/session2_branch_lineage/lysozyme_absrel.json" hyphy absrel --alignment data/21-empirical/lysozyme.nex --branches All || failures+=("lysozyme absrel")
run_cmd "lysozyme / FEL" "$RESULTS_DIR/session3_site_level/lysozyme_fel.json" hyphy fel --alignment data/21-empirical/lysozyme.nex --branches All --srv Yes || failures+=("lysozyme fel")
run_cmd "lysozyme / MEME" "$RESULTS_DIR/session3_site_level/lysozyme_meme.json" hyphy meme --alignment data/21-empirical/lysozyme.nex --branches All || failures+=("lysozyme meme")
run_cmd "lysozyme / SLAC" "$RESULTS_DIR/session3_site_level/lysozyme_slac.json" hyphy slac --alignment data/21-empirical/lysozyme.nex --branches All || failures+=("lysozyme slac")
# ===== mammalian_mtDNA =====
run_cmd "mammalian_mtDNA / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/mammalian_mtDNA_busted_standard.json" hyphy busted --code Vertebrate-mtDNA --alignment data/21-empirical/mammalian_mtDNA.mtnex --branches All || failures+=("mammalian_mtDNA busted_standard")
run_cmd "mammalian_mtDNA / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/mammalian_mtDNA_busted_srv.json" hyphy busted --code Vertebrate-mtDNA --alignment data/21-empirical/mammalian_mtDNA.mtnex --branches All --srv Yes --syn-rates 3 || failures+=("mammalian_mtDNA busted_srv")
run_cmd "mammalian_mtDNA / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/mammalian_mtDNA_busted_multihit.json" hyphy busted --code Vertebrate-mtDNA --alignment data/21-empirical/mammalian_mtDNA.mtnex --branches All --multiple-hits Double+Triple || failures+=("mammalian_mtDNA busted_multihit")
run_cmd "mammalian_mtDNA / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/mammalian_mtDNA_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --code Vertebrate-mtDNA --alignment data/21-empirical/mammalian_mtDNA.mtnex --rates 1 --triple-islands No || failures+=("mammalian_mtDNA fitmultimodel")

run_cmd "mammalian_mtDNA / aBSREL" "$RESULTS_DIR/session2_branch_lineage/mammalian_mtDNA_absrel.json" hyphy absrel --code Vertebrate-mtDNA --alignment data/21-empirical/mammalian_mtDNA.mtnex --branches All || failures+=("mammalian_mtDNA absrel")
run_cmd "mammalian_mtDNA / FEL" "$RESULTS_DIR/session3_site_level/mammalian_mtDNA_fel.json" hyphy fel --code Vertebrate-mtDNA --alignment data/21-empirical/mammalian_mtDNA.mtnex --branches All --srv Yes || failures+=("mammalian_mtDNA fel")
run_cmd "mammalian_mtDNA / MEME" "$RESULTS_DIR/session3_site_level/mammalian_mtDNA_meme.json" hyphy meme --code Vertebrate-mtDNA --alignment data/21-empirical/mammalian_mtDNA.mtnex --branches All || failures+=("mammalian_mtDNA meme")
run_cmd "mammalian_mtDNA / SLAC" "$RESULTS_DIR/session3_site_level/mammalian_mtDNA_slac.json" hyphy slac --code Vertebrate-mtDNA --alignment data/21-empirical/mammalian_mtDNA.mtnex --branches All || failures+=("mammalian_mtDNA slac")
# ===== rbcL =====
run_cmd "rbcL / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/rbcL_busted_standard.json" hyphy busted --alignment data/21-empirical/rbcL.nex --branches All || failures+=("rbcL busted_standard")
run_cmd "rbcL / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/rbcL_busted_srv.json" hyphy busted --alignment data/21-empirical/rbcL.nex --branches All --srv Yes --syn-rates 3 || failures+=("rbcL busted_srv")
run_cmd "rbcL / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/rbcL_busted_multihit.json" hyphy busted --alignment data/21-empirical/rbcL.nex --branches All --multiple-hits Double+Triple || failures+=("rbcL busted_multihit")
run_cmd "rbcL / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/rbcL_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/rbcL.nex --rates 1 --triple-islands No || failures+=("rbcL fitmultimodel")

run_cmd "rbcL / aBSREL" "$RESULTS_DIR/session2_branch_lineage/rbcL_absrel.json" hyphy absrel --alignment data/21-empirical/rbcL.nex --branches All || failures+=("rbcL absrel")
run_cmd "rbcL / FEL" "$RESULTS_DIR/session3_site_level/rbcL_fel.json" hyphy fel --alignment data/21-empirical/rbcL.nex --branches All --srv Yes || failures+=("rbcL fel")
run_cmd "rbcL / MEME" "$RESULTS_DIR/session3_site_level/rbcL_meme.json" hyphy meme --alignment data/21-empirical/rbcL.nex --branches All || failures+=("rbcL meme")
run_cmd "rbcL / SLAC" "$RESULTS_DIR/session3_site_level/rbcL_slac.json" hyphy slac --alignment data/21-empirical/rbcL.nex --branches All || failures+=("rbcL slac")
# ===== rbp3 =====
run_cmd "rbp3 / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/rbp3_busted_standard.json" hyphy busted --alignment data/21-empirical/rbp3.nex --branches All || failures+=("rbp3 busted_standard")
run_cmd "rbp3 / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/rbp3_busted_srv.json" hyphy busted --alignment data/21-empirical/rbp3.nex --branches All --srv Yes --syn-rates 3 || failures+=("rbp3 busted_srv")
run_cmd "rbp3 / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/rbp3_busted_multihit.json" hyphy busted --alignment data/21-empirical/rbp3.nex --branches All --multiple-hits Double+Triple || failures+=("rbp3 busted_multihit")
run_cmd "rbp3 / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/rbp3_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/rbp3.nex --rates 1 --triple-islands No || failures+=("rbp3 fitmultimodel")

run_cmd "rbp3 / aBSREL" "$RESULTS_DIR/session2_branch_lineage/rbp3_absrel.json" hyphy absrel --alignment data/21-empirical/rbp3.nex --branches All || failures+=("rbp3 absrel")
run_cmd "rbp3 / FEL" "$RESULTS_DIR/session3_site_level/rbp3_fel.json" hyphy fel --alignment data/21-empirical/rbp3.nex --branches All --srv Yes || failures+=("rbp3 fel")
run_cmd "rbp3 / MEME" "$RESULTS_DIR/session3_site_level/rbp3_meme.json" hyphy meme --alignment data/21-empirical/rbp3.nex --branches All || failures+=("rbp3 meme")
run_cmd "rbp3 / SLAC" "$RESULTS_DIR/session3_site_level/rbp3_slac.json" hyphy slac --alignment data/21-empirical/rbp3.nex --branches All || failures+=("rbp3 slac")
# ===== vwf =====
run_cmd "vwf / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/vwf_busted_standard.json" hyphy busted --alignment data/21-empirical/vwf.nex --branches All || failures+=("vwf busted_standard")
run_cmd "vwf / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/vwf_busted_srv.json" hyphy busted --alignment data/21-empirical/vwf.nex --branches All --srv Yes --syn-rates 3 || failures+=("vwf busted_srv")
run_cmd "vwf / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/vwf_busted_multihit.json" hyphy busted --alignment data/21-empirical/vwf.nex --branches All --multiple-hits Double+Triple || failures+=("vwf busted_multihit")
run_cmd "vwf / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/vwf_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/vwf.nex --rates 1 --triple-islands No || failures+=("vwf fitmultimodel")

run_cmd "vwf / aBSREL" "$RESULTS_DIR/session2_branch_lineage/vwf_absrel.json" hyphy absrel --alignment data/21-empirical/vwf.nex --branches All || failures+=("vwf absrel")
run_cmd "vwf / FEL" "$RESULTS_DIR/session3_site_level/vwf_fel.json" hyphy fel --alignment data/21-empirical/vwf.nex --branches All --srv Yes || failures+=("vwf fel")
run_cmd "vwf / MEME" "$RESULTS_DIR/session3_site_level/vwf_meme.json" hyphy meme --alignment data/21-empirical/vwf.nex --branches All || failures+=("vwf meme")
run_cmd "vwf / SLAC" "$RESULTS_DIR/session3_site_level/vwf_slac.json" hyphy slac --alignment data/21-empirical/vwf.nex --branches All || failures+=("vwf slac")
# ===== yokoyama_rh1_cds_mod_1_990 =====
run_cmd "yokoyama_rh1_cds_mod_1_990 / BUSTED standard" "$RESULTS_DIR/session1_gene_wide/yokoyama_rh1_cds_mod_1_990_busted_standard.json" hyphy busted --alignment data/21-empirical/yokoyama.rh1.cds.mod.1-990.nex --branches All || failures+=("yokoyama_rh1_cds_mod_1_990 busted_standard")
run_cmd "yokoyama_rh1_cds_mod_1_990 / BUSTED SRV" "$RESULTS_DIR/session1_gene_wide/yokoyama_rh1_cds_mod_1_990_busted_srv.json" hyphy busted --alignment data/21-empirical/yokoyama.rh1.cds.mod.1-990.nex --branches All --srv Yes --syn-rates 3 || failures+=("yokoyama_rh1_cds_mod_1_990 busted_srv")
run_cmd "yokoyama_rh1_cds_mod_1_990 / BUSTED multi-hit" "$RESULTS_DIR/session1_gene_wide/yokoyama_rh1_cds_mod_1_990_busted_multihit.json" hyphy busted --alignment data/21-empirical/yokoyama.rh1.cds.mod.1-990.nex --branches All --multiple-hits Double+Triple || failures+=("yokoyama_rh1_cds_mod_1_990 busted_multihit")
run_cmd "yokoyama_rh1_cds_mod_1_990 / FitMultiModel standard MG94/multi-hit" "$RESULTS_DIR/session1_gene_wide/yokoyama_rh1_cds_mod_1_990_fitmultimodel.json" hyphy "$FITMULTIMODEL_BF" --alignment data/21-empirical/yokoyama.rh1.cds.mod.1-990.nex --rates 1 --triple-islands No || failures+=("yokoyama_rh1_cds_mod_1_990 fitmultimodel")

run_cmd "yokoyama_rh1_cds_mod_1_990 / aBSREL" "$RESULTS_DIR/session2_branch_lineage/yokoyama_rh1_cds_mod_1_990_absrel.json" hyphy absrel --alignment data/21-empirical/yokoyama.rh1.cds.mod.1-990.nex --branches All || failures+=("yokoyama_rh1_cds_mod_1_990 absrel")
run_cmd "yokoyama_rh1_cds_mod_1_990 / FEL" "$RESULTS_DIR/session3_site_level/yokoyama_rh1_cds_mod_1_990_fel.json" hyphy fel --alignment data/21-empirical/yokoyama.rh1.cds.mod.1-990.nex --branches All --srv Yes || failures+=("yokoyama_rh1_cds_mod_1_990 fel")
run_cmd "yokoyama_rh1_cds_mod_1_990 / MEME" "$RESULTS_DIR/session3_site_level/yokoyama_rh1_cds_mod_1_990_meme.json" hyphy meme --alignment data/21-empirical/yokoyama.rh1.cds.mod.1-990.nex --branches All || failures+=("yokoyama_rh1_cds_mod_1_990 meme")
run_cmd "yokoyama_rh1_cds_mod_1_990 / SLAC" "$RESULTS_DIR/session3_site_level/yokoyama_rh1_cds_mod_1_990_slac.json" hyphy slac --alignment data/21-empirical/yokoyama.rh1.cds.mod.1-990.nex --branches All || failures+=("yokoyama_rh1_cds_mod_1_990 slac")
if [[ "$RUN_COLLECT" == "1" && "$DRY_RUN" != "1" ]]; then
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

if [[ "$DRY_RUN" == "1" ]]; then
  echo "Printed all empirical HyPhy commands without running them."
else
  echo "Completed all explicit empirical HyPhy commands."
fi
