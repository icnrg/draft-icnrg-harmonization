NAME = draft-icnrg-harmonization
REVISION = 00

PANDOC = pandoc

SOURCES = $(wildcard *.md)

all: build $(NAME)-$(REVISION).txt $(NAME)-$(REVISION).html

build:
	mkdir build

view:
	open $(NAME)-$(REVISION).html

build/template.xml: template.xml
	sed -e "s/@@REVISION@@/$(REVISION)/g" template.xml > build/template.xml

build/%.xml: %.md build/template.xml
	pandoc -t docbook -s $< | xsltproc --nonet transform.xsl - > $@

$(NAME)-$(REVISION).txt: $(addprefix build/,$(SOURCES:.md=.xml))
	xml2rfc -o $@ --text build/template.xml

$(NAME)-$(REVISION).html: $(addprefix build/,$(SOURCES:.md=.xml))
	xml2rfc -o $@ --html build/template.xml

clean:
	rm -Rf build $(NAME)-$(REVISION).*

