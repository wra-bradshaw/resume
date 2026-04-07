set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    just pdf

pdf:
    ./build-pdf.sh

clean:
    latexmk -C
