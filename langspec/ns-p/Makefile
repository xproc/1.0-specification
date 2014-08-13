SAXON=saxon
TIDY=/usr/bin/tidy
CALABASH=calabash
STEPREPO=../../../steps

TARGETS=xproc.html ns-xproc-p-incl.xml ns-tmpl-p-incl.xml

all: $(TARGETS)

xproc.html: ,xproc.xml
	$(SAXON) $< ../../style/dbspec.xsl $@
	$(TIDY) --doctype loose --output-xhtml true -q -utf8 -mn $@

,xproc.xml: xproc.xml ns-xproc-p-incl.xml ns-tmpl-p-incl.xml \
               ../../style/docbook.xsl ../../style/dbspec.xsl \
               ../../style/xprocns.xsl ../../style/rngsyntax.xsl
	$(CALABASH) -isource=$< -oresult=$@ \
                    ../../style/validate.xpl schema=../../schema/dbspec.rng

ns-xproc-p-incl.xml: ../,langspec.xml ../../style/ns-extract.xsl
	$(SAXON) $< ../../style/ns-extract.xsl $@

ns-tmpl-p-incl.xml: $(STEPREPO)/template/,template.xml ../../style/ns-extract.xsl
	$(SAXON) $< ../../style/ns-extract.xsl $@

clean:
	rm -f $(TARGETS) ,xproc.xml

