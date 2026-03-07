#!/bin/bash
#SBATCH --job-name=container
#SBATCH --time=0-02:00
#SBATCH --signal=USR2
#SBATCH --mem=16gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kacros1@st.amu.edu.pl

# Import kontenera rstudio z Docker Hub i konwersja do formatu Singularity (.sif).
# Obraz jest budowany automatycznie przez GitHub Actions (linux/amd64).

grant="pl0090-01"

DATA=$HOME/${grant}/project_data
IMAGES=${DATA}/kacros_images/images

# Cache i tmp na partycji grantowej (home ma za małą quotę)
export SINGULARITY_CACHEDIR=${DATA}/kacros_images/cache
export SINGULARITY_TMPDIR=${DATA}/kacros_images/tmp
export TMPDIR=${SINGULARITY_TMPDIR}

mkdir -p "$SINGULARITY_CACHEDIR"
mkdir -p "$SINGULARITY_TMPDIR"
mkdir -p "$IMAGES"

cd "$IMAGES"

echo "[$(date)] Pobieranie obrazu z Docker Hub..."
singularity pull --force --name rstudio_latest.sif docker://kroszczark/mrangr-server-agent:latest
echo "[$(date)] Gotowe."

ls -lh "$IMAGES"

# Smoke test
echo "[$(date)] Weryfikacja obrazu..."
singularity exec rstudio_latest.sif Rscript -e 'library(terra); cat("terra OK, wersja:", as.character(packageVersion("terra")), "\n")'
singularity exec rstudio_latest.sif conda --version

# Sprzątanie cache (opcjonalnie — zakomentuj jeśli chcesz zachować cache)
rm -rf "$SINGULARITY_CACHEDIR"
rm -rf "$SINGULARITY_TMPDIR"