set windows-shell := ["powershell.exe", "-c"]
set shell := ["bash", "-c"]

set dotenv-load # load env variable from .env

FILE := "compiler-notes"
OUTDIR := env_var_or_default('OUTDIR', "build")
DEBUG := env_var_or_default('DEBUG', "false")
PDFLATEX_EXTRA_ARGS := ""

@all:
	echo "Compiling TeX Files..."
	just pdflatex {{ PDFLATEX_EXTRA_ARGS }}
	just pdflatex {{ PDFLATEX_EXTRA_ARGS }}
	just bibtex
	just pdflatex {{ PDFLATEX_EXTRA_ARGS }}
	echo "Compilation SUCCESS"

@lite:
	echo "Compiling TeX Files..."
	just pdflatex {{ PDFLATEX_EXTRA_ARGS }}
	echo "Compilation SUCCESS"

[windows]
clean:
	Get-ChildItem -Path {{ OUTDIR }} -Include \
	*.zip,*.aux,*.log,*.out,*.toc,*synctex.gz,*.bbl,*.blg \
	-Recurse | ForEach-Object {Remove-Item $_.FullName}

[unix]
clean:
	#!/usr/bin/env bash
	extensions=(".zip" ".aux" ".log" ".out" ".toc" "synctex.gz" ".bbl" ".blg")
	for ext in "${extensions[@]}"; do
		find {{ OUTDIR }} -name "*$ext" -delete
	done

watch task:
	watchexec           \
	-c                  \
	-r                  \
	-e tex,cls,sty,bib  \
	--no-vcs-ignore     \
	--no-project-ignore \
	just {{ task }}

[unix]
cmp old new:
	git-latexdiff --new {{ new }} --old {{ old }}

[windows]
cmp old new:
	scripts/bin/git-latexdiff.exe --new {{ new }} --old {{ old }}

[unix]
[private]
pdflatex *args:
	if {{ DEBUG }}; then \
	pdflatex -synctex=1 -output-directory={{ OUTDIR }} {{ args }} {{ FILE }}.tex; \
	fi
	@pdflatex -interaction=nonstopmode -synctex=1 -output-directory={{ OUTDIR }} {{ args }} {{ FILE }}.tex > /dev/null; \

[unix]
[private]
@bibtex *args:
	bibtex {{ OUTDIR }}/{{ FILE }} > /dev/null

[windows]
[private]
@pdflatex *args:
	if (${{ DEBUG }}) { pdflatex -synctex=1 -output-directory={{ OUTDIR }} {{ args }} {{ FILE }}.tex } \
	else { pdflatex -interaction=nonstopmode -synctex=1 -output-directory={{ OUTDIR }} {{ args }} {{ FILE }}.tex | out-null }

[windows]
[private]
@bibtex *args:
	bibtex {{ OUTDIR }}/{{ FILE }} | out-null

zip:
	lasagna --parent --output {{ OUTDIR }}/{{FILE}}.zip
