SAXON=saxon
TIDY=/usr/bin/tidy
CALABASH=calabash

TARGETS=xproc-step.html ns-xproc-c-incl.xml

all: $(TARGETS)

xproc-step.html: ,xproc-step.xml
	$(SAXON) $< ../../style/dbspec.xsl $@
	$(TIDY) --doctype loose --output-xhtml true -q -utf8 -mn $@

,xproc-step.xml: xproc-step.xml ns-xproc-c-incl.xml \
               ../../style/docbook.xsl ../../style/dbspec.xsl \
               ../../style/xprocns.xsl ../../style/rngsyntax.xsl
	$(CALABASH) -isource=$< -oresult=$@ \
                    ../../style/validate.xpl schema=../../schema/dbspec.rng

ns-xproc-c-incl.xml: ../,langspec.xml ../../style/ns-extract.xsl
	$(SAXON) $< ../../style/ns-extract.xsl $@ prefix=c:

clean:
	rm -f $(TARGETS) ,xproc-step.xml
