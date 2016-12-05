
R:
	Rscript -e 'require(knitr); knit("${presName}.Rmd")'

pdf:
	pandoc ${presName}.md --slide-level 2 -t beamer -o ${presName}.tex
	pdflatex ${presName}.tex
	-xdg-open ${presName}.pdf

tex:
	pandoc --slide-level 2 -t beamer ${presName}.md -o ${presName}.tex

pdfdirect:
	pandoc --slide-level 2 -t beamer ${presName}.md -o ${presName}.pdf
	-xdg-open ${presName}.pdf
	# pandoc --toc --slide-level 2 -V theme:Frankfurt -t beamer ${presName}.md -o ${presName}.pdf
