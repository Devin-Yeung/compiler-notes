BUILD=./build

dcn-notes: dcn-notes.tex
	pdflatex $^ -quiet -output-directory=$(BUILD)

debug: dcn-notes.tex
	pdflatex $^ -output-directory=$(BUILD)

catch-bug:
	watchexec \
	-r \
	-c \
	-e tex,cls,sty \
	make debug

watch:
	watchexec \
	-r \
	-c \
	-e tex,cls,sty \
	make dcn-notes

