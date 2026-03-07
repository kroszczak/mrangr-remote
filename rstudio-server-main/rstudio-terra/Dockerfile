
# Obraz bazowy
FROM rocker/rstudio:latest

# Przełączenie na roota (do instalacji pakietów)
USER root

# Aktualizacja APT i instalacja systemowych zależności dla pakietu 'terra'
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libgdal-dev \
        libproj-dev \
        libgeos-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalacja 'sudo' i dodanie użytkownika 'rstudio' do grupy 'sudo'
# RUN apt-get update && apt-get install -y sudo && usermod -aG sudo rstudio

