name=semesterProject

all: $(name).tex $(wildcard *.bib) $(wildcard *.tex)
	rm -f $(name).pdf
	latexmk -pdf $(name).tex

clean:
	latexmk -c

