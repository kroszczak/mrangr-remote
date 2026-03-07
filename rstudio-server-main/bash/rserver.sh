#!/bin/bash
#SBATCH --job-name=rstudio
#SBATCH --time=5-24
#SBATCH --signal=USR2
#SBATCH --mem=32gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kacros1@st.amu.edu.pl

# --nodes=1
# --ntasks-per-node=2

export SINGULARITYENV_PASSWORD=$(tr -cd [:alpha:] < /dev/random | head -c10)

cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command:

   ssh -N -L 8787:${SLURMD_NODENAME}:8787 ${USER}@eagle.man.poznan.pl

   and point your web browser to http://localhost:8787

2. log in to RStudio Server using the following credentials:

   user: ${USER}
   password: ${SINGULARITYENV_PASSWORD}

When done using RStudio Server, terminate the job by:

1. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
2. Issue the following command on the login node:

      scancel -f ${SLURM_JOB_ID}
END


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

# Biblioteki R
# export R_LIBS_USER=${SCRATCH}/R-LIBS/rocker-rstudio
# mkdir -p ${R_LIBS_USER}

# Dane
mkdir -p $SCRATCH/Rproj


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
          
  
printf 'rserver exited' 1>&2