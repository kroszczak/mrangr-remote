#!/bin/sh

# Uruchamia serwer RStudio jako zadanie interaktywne

grant="pl0090-01"
DATA=$HOME/${grant}/project_data
CONTAINER=${DATA}/kacros_images/images/rstudio_latest.sif
SCRATCH=$HOME/${grant}/scratch/$USER

# Katalogi robocze kontenera
export TMPDIR=${SCRATCH}/rstudio-tmp
mkdir -p $TMPDIR/tmp/rstudio-server
mkdir -p $TMPDIR/var/lib
mkdir -p $TMPDIR/var/run

# Klucz
uuidgen > $TMPDIR/tmp/rstudio-server/secure-cookie-key
chmod 600 $TMPDIR/tmp/rstudio-server/secure-cookie-key

# Dane
mkdir -p $SCRATCH/Rproj

export SINGULARITYENV_PASSWORD=$(tr -cd [:alpha:] < /dev/random | head -c10)
echo
echo "user:" $USER && \
echo "password:" $SINGULARITYENV_PASSWORD && \
echo "SSH tunnel: ssh -N -L 8787:${SLURMD_NODENAME}:8787 ${USER}@eagle.man.poznan.pl" && \
echo

singularity exec \
          --bind=$TMPDIR/tmp:/tmp \
          --bind=$TMPDIR/var/lib:/var/lib/rstudio-server \
          --bind=$TMPDIR/var/run:/var/run/rstudio-server \
          --bind=$SCRATCH:$HOME \
  $CONTAINER rserver --www-port=8787 \
          --auth-none=0 \
          --auth-pam-helper-path=pam-helper \
          --server-user=${USER} \
          --auth-timeout-minutes=0 \
          --auth-stay-signed-in-days=30

printf 'rserver exited'