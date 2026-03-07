# **RStudio Server na Eagle/Altair**

## Obraz Docker

Obraz `kroszczark/mrangr-server-agent` jest budowany automatycznie przez **GitHub Actions** dla architektury `linux/amd64` (Intel 64-bit, zgodnej z PCSS Eagle/Altair).

**Zawartość obrazu:**
- `rocker/rstudio:latest` — RStudio Server + R (najnowsza wersja)
- pakiet R `terra` + zależności systemowe (`libgdal`, `libproj`, `libgeos`)
- Miniconda (`conda`)

**Automatyczna aktualizacja:**
- Obraz jest przebudowywany **co poniedziałek o 04:00 UTC** (nowe wersje R, terra, zależności systemowych)
- Każdy push do `main` który zmienia `Dockerfile` również triggeruje build
- Można też wymusić ręczny build z poziomu GitHub → Actions → "Run workflow"

**Tagowanie obrazów:**
- `latest` — zawsze najnowszy build
- `YYYY-MM-DD` — tag z datą buildu
- krótki SHA commita

### Ogólna procedura

1.  Eagle: pobranie kontenera (`container.sh`)
2.  Eagle: uruchomienie serwera RStudio (`rserver.sh` lub `rserver_int.sh`)
3.  Lokalny Mac: tunel SSH
4.  Przeglądarka: połączenie z serwerem przez `http://localhost:8787`

# Skrypty

## **`container.sh`**

Pobiera obraz Docker z Docker Hub i konwertuje do formatu Singularity (`.sif`).
Cache i pliki tymczasowe są zapisywane na partycji grantowej (nie w `$HOME`, który ma małą quotę).

Uruchamiać w trybie wsadowym:

```         
ssh k_roszczak@eagle.man.poznan.pl
cd bash
sbatch container.sh
```

**Uwagi**

1.  Pierwsze wykonanie skryptu zajmuje ok. 10-15 minut (pobieranie ~1 GB obrazu).
2.  Kolejne wywołania nadpiszą istniejący plik `rstudio_latest.sif` nową wersją.
3.  Skrypt automatycznie weryfikuje obraz po pobraniu (smoke test: `terra` + `conda`).

## `rserver.sh`

Uruchamia serwer RStudio jako zadanie wsadowe.

```         
ssh k_roszczak@eagle.man.poznan.pl
cd bash
sbatch rserver.sh
```

W katalogu, z którego został odpalony skrypt zostanie utworzony plik tekstowy z rozszerzeniem `.out`, w którym są dalsze instrukcje.

W skrócie, trzeba:

1.  zostawić działający terminal SSH (obsługujący serwer),
2.  z lokalnego komputera otworzyć nowy terminal i utworzyć tunel SSH:
    ```
    ssh -N -L 8787:<NAZWA_WEZLA>:8787 k_roszczak@eagle.man.poznan.pl
    ```
    (gotowe polecenie z konkretną nazwą węzła jest w pliku `.out`),
3.  otworzyć w przeglądarce [`http://localhost:8787`](http://localhost:8787),
4.  wpisać nazwę użytkownika i hasło z pliku `.out`.

Sprzątanie polega na zamknięciu RStudio w przeglądarce i zamknięciu zadania na Eagle poleceniem:

```         
scancel -f <numer_zadania>
```

## `rserver_int.sh`

Uruchamia serwer RStudio jako zadanie interaktywne.

```         
ssh k_roszczak@eagle.man.poznan.pl
srun --mem=16gb --pty /bin/bash
```

lub np.:

```         
srun -n1 -c2 --mem=32gb --pty /bin/bash     # jeden węzeł, 2 procesory, 32GB RAM
```

potem:

```         
cd bash
sh rserver_int.sh
```

Po postawieniu serwera, na ekranie są wyświetlane: losowe hasło do RStudio i polecenie SSH do przekierowania portów.
Po skończonej zabawie trzeba zamknąć zadanie na Eaglu poleceniem `scancel`.

### **Uwagi ogólne**

1.  Jeżeli skrypty były edytowane pod OS innym niż Linux, to przed wysłaniem na serwer muszą być przekonwertowane w terminalu: `dos2unix <skrypt>` lub `mac2unix <skrypt>`.
2.  Przed pierwszym uruchomieniem, każdemu skryptowi należy nadać atrybut wykonywalności: `chmod +x <skrypt>`.
3.  Nie buduj obrazu Docker lokalnie na Mac M1 — obraz budowany przez QEMU emulację `amd64` na ARM generuje `.sif` z niekompatybilnym squashfs. Zawsze używaj GitHub Actions lub natywnego buildera `amd64`.

### Literatura

[PCSS Podręcznik użytkownika](https://wiki.man.poznan.pl/kdm/Podr%C4%99cznik_u%C5%BCytkownika)

[Singularity](https://docs.sylabs.io/guides/latest/user-guide/)

[Apptainer](https://apptainer.org/docs/user/latest/)

[rocker](https://rocker-project.org/use/singularity.html)

[rocker-versioned](https://github.com/rocker-org/rocker-versioned2)
