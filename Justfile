set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    just pdf

pdf file="main":
    ./build-pdf.sh "{{file}}"

clean:
    latexmk -C
