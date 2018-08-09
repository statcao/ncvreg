all: src/*.Rmd css/main.css
	knitall -k --only-newer src/*.Rmd
	sed -i '/chunk fake/d' *.md
	rm -f img/*-fake-*
	jekyll b

clean:
	mv README.md README.bak
	rm *.md
	rm img/*
	mv README.bak README.md
