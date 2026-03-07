FROM rocker/rstudio:latest

LABEL maintainer="kroszczark"
LABEL description="RStudio Server + terra + Miniconda (amd64, for PCSS Eagle/Altair)"

# Systemowe zależności dla pakietu R 'terra'
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libproj-dev \
        libgdal-dev \
        libgeos-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Pakiet R 'terra'
RUN Rscript -e 'install.packages("terra", repos="https://cran.r-project.org")'

# Miniconda
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda clean -afy
ENV PATH="/opt/conda/bin:${PATH}"

# Smoke test — upewniamy się, że terra i conda działają
RUN Rscript -e 'library(terra); cat("terra", as.character(packageVersion("terra")), "\n")' && \
    conda --version