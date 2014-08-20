SAXON=saxon
TIDY=/usr/bin/tidy
CALABASH=calabash

TARGETS=xproc-error.html error-list.xml

all: $(TARGETS)

xproc-error.html: ,xproc-error.xml
	$(SAXON) $< ../../style/dbspec.xsl $@
	$(TIDY) --doctype loose --output-xhtml true -q -utf8 -mn $@

# Cannot validate schema=../../schema/dbspec.rng
# Fix it so that it validates!
,xproc-error.xml: xproc-error.xml error-list.xml \
               ../../style/docbook.xsl ../../style/dbspec.xsl \
               ../../style/xprocns.xsl ../../style/rngsyntax.xsl
	@echo FIXME: make this validate
	$(CALABASH) -isource=$< -oresult=$@ \
                    ../../style/validate.xpl

error-list.xml: ../,langspec.xml ../../style/error-list.xsl
	$(SAXON) $< ../../style/error-list.xsl $@

clean:
	rm -f $(TARGETS) ,xproc-error.xml
