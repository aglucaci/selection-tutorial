#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${COLAB_RELEASE_TAG:-}" ]]; then
  echo "Detected Google Colab runtime."
else
  echo "This script is intended for Google Colab, but it can also run on Ubuntu-like systems."
fi

APT_GET="apt-get"
MAMBA_ROOT="${MAMBA_ROOT:-/content/micromamba}"
HYPHY_ENV="${HYPHY_ENV:-/content/hyphy-env}"
export PATH="$MAMBA_ROOT/bin:$PATH"

if command -v sudo >/dev/null 2>&1; then
  APT_PREFIX=(sudo)
else
  APT_PREFIX=()
fi

install_hyphy_with_micromamba() {
  echo "Installing HyPhy from Bioconda with micromamba..."
  if ! command -v micromamba >/dev/null 2>&1; then
    mkdir -p "$MAMBA_ROOT/bin"
    curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest \
      | tar -xj -C "$MAMBA_ROOT/bin" --strip-components=1 bin/micromamba
  fi

  micromamba create -y -p "$HYPHY_ENV" -c conda-forge -c bioconda hyphy
  ln -sf "$HYPHY_ENV/bin/hyphy" /usr/local/bin/hyphy
}

if command -v "$APT_GET" >/dev/null 2>&1; then
  echo "Installing command-line helpers with apt..."
  "${APT_PREFIX[@]}" "$APT_GET" update
  "${APT_PREFIX[@]}" "$APT_GET" install -y unzip curl bzip2

  if "$APT_GET" -qq --print-uris install hyphy >/dev/null 2>&1; then
    echo "Installing HyPhy with apt..."
    "${APT_PREFIX[@]}" "$APT_GET" install -y hyphy
  else
    install_hyphy_with_micromamba
  fi
else
  echo "apt-get not found; using micromamba for HyPhy."
  install_hyphy_with_micromamba
fi

echo "Installing Python packages with pip..."
python -m pip install -q --upgrade pip
python -m pip install -q pandas matplotlib seaborn biopython pyvolve pyyaml

echo
echo "Versions:"
python --version
hyphy --version || true
echo
echo "Colab setup complete."
