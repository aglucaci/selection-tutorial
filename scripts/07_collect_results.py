#!/usr/bin/env python3
"""Collect HyPhy JSON outputs into workshop CSV tables and figures."""

from __future__ import annotations

from pathlib import Path
import json
import math
from typing import Any

import matplotlib.pyplot as plt
import pandas as pd


RESULTS = Path("results")
TABLES = Path("tables")
FIGURES = Path("figures")
TRUTH = Path("data/simulated/simulated_truth.json")


def load_json(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def nested_find(obj: Any, keys: tuple[str, ...]) -> Any | None:
    if isinstance(obj, dict):
        for key in keys:
            if key in obj:
                return obj[key]
        for value in obj.values():
            found = nested_find(value, keys)
            if found is not None:
                return found
    elif isinstance(obj, list):
        for value in obj:
            found = nested_find(value, keys)
            if found is not None:
                return found
    return None


def scalar(value: Any) -> float | str | None:
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        return float(value)
    if isinstance(value, str):
        try:
            return float(value)
        except ValueError:
            return value
    return None


def method_from_name(path: Path) -> str:
    name = path.stem.lower()
    for method in ("busted", "absrel", "relax", "fel", "meme", "fubar"):
        if method in name:
            return method.upper()
    return path.stem


def collect_summary(paths: list[Path], session: str) -> pd.DataFrame:
    rows = []
    for path in paths:
        data = load_json(path)
        test_results = data.get("test results", {})
        rows.append(
            {
                "session": session,
                "file": str(path),
                "method": method_from_name(path),
                "p_value": scalar(nested_find(test_results, ("p-value", "P-value", "p value"))),
                "lrt": scalar(nested_find(test_results, ("LRT", "likelihood ratio test", "LR"))),
                "k": scalar(nested_find(test_results, ("relaxation or intensification parameter", "K"))),
            }
        )
    return pd.DataFrame(rows)


def extract_mle_headers(data: dict[str, Any]) -> list[str]:
    headers = data.get("MLE", {}).get("headers", [])
    return [h[0] if isinstance(h, list) and h else str(h) for h in headers]


def extract_site_table(path: Path) -> pd.DataFrame:
    data = load_json(path)
    content = data.get("MLE", {}).get("content", {})
    if not isinstance(content, dict) or not content:
        return pd.DataFrame()

    headers = extract_mle_headers(data)
    rows = []
    for partition, table in content.items():
        if not isinstance(table, list):
            continue
        for idx, values in enumerate(table, start=1):
            row = {"file": str(path), "method": method_from_name(path), "partition": partition, "site": idx}
            if isinstance(values, list):
                for col, value in zip(headers, values):
                    row[col] = value
            rows.append(row)
    return pd.DataFrame(rows)


def best_pvalue_column(df: pd.DataFrame) -> str | None:
    candidates = [col for col in df.columns if "p-value" in col.lower() or "p value" in col.lower()]
    return candidates[0] if candidates else None


def ensure_dirs() -> None:
    TABLES.mkdir(exist_ok=True)
    FIGURES.mkdir(exist_ok=True)


def plot_summary(df: pd.DataFrame, output: Path, title: str) -> None:
    plot_df = df.dropna(subset=["p_value"]).copy()
    if plot_df.empty:
        return
    plot_df["minus_log10_p"] = plot_df["p_value"].astype(float).map(
        lambda p: -math.log10(max(p, 1e-300))
    )
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.bar(plot_df["method"] + "\n" + plot_df["file"].map(lambda p: Path(p).stem), plot_df["minus_log10_p"])
    ax.axhline(-math.log10(0.05), color="firebrick", linestyle="--", linewidth=1)
    ax.set_ylabel("-log10 p-value")
    ax.set_title(title)
    ax.tick_params(axis="x", labelrotation=30)
    fig.tight_layout()
    fig.savefig(output, dpi=180)
    plt.close(fig)


def plot_site_calls(df: pd.DataFrame, output_prefix: str) -> None:
    if df.empty:
        return
    for method, method_df in df.groupby("method"):
        p_col = best_pvalue_column(method_df)
        if not p_col:
            continue
        plot_df = method_df[["site", p_col]].dropna().copy()
        if plot_df.empty:
            continue
        plot_df[p_col] = pd.to_numeric(plot_df[p_col], errors="coerce")
        plot_df = plot_df.dropna()
        if plot_df.empty:
            continue
        plot_df["minus_log10_p"] = plot_df[p_col].map(lambda p: -math.log10(max(p, 1e-300)))
        fig, ax = plt.subplots(figsize=(8, 3.5))
        ax.scatter(plot_df["site"], plot_df["minus_log10_p"], s=18)
        ax.axhline(-math.log10(0.05), color="firebrick", linestyle="--", linewidth=1)
        ax.set_xlabel("Codon site")
        ax.set_ylabel("-log10 p-value")
        ax.set_title(f"{method} site-level evidence")
        fig.tight_layout()
        fig.savefig(FIGURES / f"{output_prefix}_{method.lower()}.png", dpi=180)
        plt.close(fig)


def plot_truth_blocks() -> None:
    if not TRUTH.exists():
        return
    truth = load_json(TRUTH)
    blocks = pd.DataFrame(truth.get("blocks", []))
    if blocks.empty:
        return
    fig, ax = plt.subplots(figsize=(8, 2.8))
    colors = {"purifying": "#4c78a8", "neutral_like": "#72b7b2", "positive_enriched": "#e45756"}
    for _, row in blocks.iterrows():
        width = row["end_codon"] - row["start_codon"] + 1
        ax.barh(0, width, left=row["start_codon"], color=colors.get(row["name"], "#999999"), height=0.45)
        ax.text(row["start_codon"] + width / 2, 0, f"{row['name']}\nomega={row['omega']}", ha="center", va="center", fontsize=8)
    ax.set_xlabel("Codon site")
    ax.set_yticks([])
    ax.set_title("Simulated truth blocks")
    fig.tight_layout()
    fig.savefig(FIGURES / "session4_simulation_truth_blocks.png", dpi=180)
    plt.close(fig)


def plot_simulated_truth_vs_detected(df: pd.DataFrame) -> None:
    if df.empty or not TRUTH.exists():
        return
    truth = load_json(TRUTH)
    blocks = pd.DataFrame(truth.get("blocks", []))
    if blocks.empty:
        return

    fig, ax = plt.subplots(figsize=(9, 4))
    color_cycle = {"FEL": "#4c78a8", "MEME": "#e45756", "FUBAR": "#72b7b2"}
    for method, method_df in df.groupby("method"):
        p_col = best_pvalue_column(method_df)
        if not p_col:
            continue
        plot_df = method_df[["site", p_col]].dropna().copy()
        plot_df[p_col] = pd.to_numeric(plot_df[p_col], errors="coerce")
        plot_df = plot_df.dropna()
        if plot_df.empty:
            continue
        plot_df["minus_log10_p"] = plot_df[p_col].map(lambda p: -math.log10(max(p, 1e-300)))
        ax.scatter(
            plot_df["site"],
            plot_df["minus_log10_p"],
            s=18,
            alpha=0.8,
            label=method,
            color=color_cycle.get(method, None),
        )

    ymax = max(ax.get_ylim()[1], -math.log10(0.05) + 0.5)
    for _, row in blocks.iterrows():
        if row["omega"] > 1:
            ax.axvspan(row["start_codon"], row["end_codon"], color="#e45756", alpha=0.12)
        ax.text(
            (row["start_codon"] + row["end_codon"]) / 2,
            ymax * 0.95,
            f"{row['name']}\nomega={row['omega']}",
            ha="center",
            va="top",
            fontsize=8,
        )

    ax.axhline(-math.log10(0.05), color="firebrick", linestyle="--", linewidth=1)
    ax.set_xlabel("Codon site")
    ax.set_ylabel("-log10 p-value")
    ax.set_title("Simulated truth versus detected site-level evidence")
    if ax.get_legend_handles_labels()[0]:
        ax.legend(frameon=False)
    fig.tight_layout()
    fig.savefig(FIGURES / "session4_simulated_truth_vs_detected.png", dpi=180)
    plt.close(fig)


def main() -> None:
    ensure_dirs()

    session1_paths = sorted((RESULTS / "session1_gene_wide").glob("*.json"))
    session3_paths = sorted((RESULTS / "session3_branch_lineage").glob("*.json"))
    session4_paths = sorted((RESULTS / "session4_simulated").glob("*.json"))
    session2_paths = sorted((RESULTS / "session2_site_level").glob("*.json"))

    for paths, session, table_name, figure_name, title in [
        (session1_paths, "session1_gene_wide", "session1_gene_wide_summary_long.csv", "session1_gene_wide_pvalues.png", "Session 1 gene-wide tests"),
        (session3_paths, "session3_branch_lineage", "session3_branch_lineage_summary_long.csv", "session3_branch_lineage_pvalues.png", "Session 3 branch and lineage tests"),
        (session4_paths, "session4_simulated", "session4_simulated_summary_long.csv", "session4_simulated_pvalues.png", "Session 4 simulated tests"),
    ]:
        if paths:
            summary = collect_summary(paths, session)
            summary.to_csv(TABLES / table_name, index=False)
            plot_summary(summary, FIGURES / figure_name, title)

    site_tables = [extract_site_table(path) for path in session2_paths + session4_paths]
    site_tables = [df for df in site_tables if not df.empty]
    if site_tables:
        sites = pd.concat(site_tables, ignore_index=True)
        sites.to_csv(TABLES / "session2_site_level_tables.csv", index=False)
        sim_sites = sites[sites["file"].str.contains("session4_simulated")]
        if not sim_sites.empty:
            sim_sites.to_csv(TABLES / "session4_simulated_site_level_tables.csv", index=False)
        plot_site_calls(sites[sites["file"].str.contains("session2_site_level")], "session2_site_level")
        plot_site_calls(sim_sites, "session4_simulated_site_level")
        plot_simulated_truth_vs_detected(sim_sites)

    plot_truth_blocks()
    print(f"Wrote tables to {TABLES}")
    print(f"Wrote figures to {FIGURES}")


if __name__ == "__main__":
    main()
