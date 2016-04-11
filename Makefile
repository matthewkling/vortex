.PHONY: data clean

all: images/scatterplot.png paper/paper.pdf  slides/slides.pdf
		
paper/paper.pdf: paper/paper.Rnw
	cd paper; Rscript -e 'library(knitr); knit2pdf("paper.Rnw")' 

slides/slides.pdf: slides/slides.Rnw images/scatterplot.png
	cd slides; Rscript -e 'library(knitr); knit2pdf("slides.Rnw")'

images/scatterplot.png: code/scripts/scatterplot_script.R
	cd code/scripts; Rscript scatterplot_script.R

data:
	cd data && make download_all

clean:
	@echo Clean up
	cd paper; rm -f *.{aux,bbl,blg,log,tex,pdf,run.xml}
