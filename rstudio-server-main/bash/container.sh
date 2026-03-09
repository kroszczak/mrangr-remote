#!/bin/bash
#SBATCH --job-name=container
#SBATCH --time=0-02:00
#SBATCH --signal=USR2
#SBATCH --mem=16gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kacros1@st.amu.edu.pl

# Import kontenera rstudio z Docker Hub i budowa sandbox (folder) Singularity.
# Obraz Docker jest budowany automatycznie przez GitHub Actions (linux/amd64).
#
# UWAGA: Używamy --sandbox zamiast .sif, ponieważ Singularity CE na Eagle
# tworzy squashfs z kompresją zstd, której jądro Linux na Eagle nie obsługuje.

grant="pl0090-01"

DATA=$HOME/${grant}/project_data
IMAGES=${DATA}/kacros_images/images
SANDBOX=${IMAGES}/rstudio_sandbox

# Cache i tmp na partycji grantowej (home ma za małą quotę)
export SINGULARITY_CACHEDIR=${DATA}/kacros_images/cache
export SINGULARITY_TMPDIR=${DATA}/kacros_images/tmp
export TMPDIR=${SINGULARITY_TMPDIR}

mkdir -p "$SINGULARITY_CACHEDIR"
mkdir -p "$SINGULARITY_TMPDIR"
mkdir -p "$IMAGES"

echo "[$(date)] Pobieranie obrazu z Docker Hub (sandbox)..."
singularity build --sandbox --force "$SANDBOX" docker://kroszczark/mrangr-server-agent:latest
echo "[$(date)] Gotowe."

ls -lhd "$SANDBOX"

# Smoke test
echo "[$(date)] Weryfikacja obrazu..."
singularity exec "$SANDBOX" Rscript -e 'library(terra); cat("terra OK, wersja:", as.character(packageVersion("terra")), "\n")'
singularity exec "$SANDBOX" conda --version
echo "[$(date)] Weryfikacja zakończona."

# Sprzątanie cache
rm -rf "$SINGULARITY_CACHEDIR"
rm -rf "$SINGULARITY_TMPDIR"