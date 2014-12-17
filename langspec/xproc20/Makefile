empty :=
space := $(empty) $(empty)

CLASSPATH=$(subst  $(space),:,$(wildcard ../../lib/*.jar)):../../lib
SAXON=java -cp $(CLASSPATH) -jar ../../lib/saxon9he.jar
CALABASH=java -cp $(CLASSPATH) com.xmlcalabash.drivers.Main -c ../../.calabash

TARGETS=changelog.html Overview.html diff.html

all: $(TARGETS)

# ============================================================

Overview.html: ,xproc20.xml error-list.xml \
               ../../style/docbook.xsl ../../style/dbspec.xsl \
               ../../style/xprocns.xsl ../../style/rngsyntax.xsl
	@echo Format spec: $@
	@$(CALABASH) -isource=$< -oresult=$@ \
	            -pschemaext.schema=../../../../../schema/dbspec.rng \
                    -pxml.toc.filename=xproc20.toc.xml \
                    -potherspec=../xproc20-steps/,steps.xml \
                    -potherprefix="http://www.w3.org/TR/" \
	            -pothersuffix="/" \
                    -potherlabel="XPS" \
                    ../../style/formatspec.xpl style=xproc-specs.xsl

# N.B. ,,xproc20.xml has a bogus glossary, you must re-validate (which
#      re-XIncludes) the sources to create ,xproc20.xml
,xproc20.xml: xproc20.xml conformance.xml error-codes.xml glossary.xml \
              language-summary.xml mediatype.xml namespace-fixup.xml \
              parallel.xml references.xml
	@echo Validate spec: $<
	@$(CALABASH) -isource=$< -oresult=$@ \
                    ../../style/validate.xpl \
                    schema=../../schema/dbspec.rng \
                    schematron=../../schema/docbook.sch

,,xproc20.xml: xproc20.xml conformance.xml error-codes.xml \
               language-summary.xml mediatype.xml namespace-fixup.xml \
               parallel.xml references.xml
	$(MAKE) -C examples
	@echo XInclude spec: $<
	@$(CALABASH) -isource=$< -oresult=$@ \
                    ../../style/validate.xpl \
                    schema=../../schema/dbspec.rng \
                    schematron=../../schema/docbook.sch

# ============================================================

diff.html: Overview.html
	../../lib/make-diff.sh xproc20

changelog.html: changelog.xml
	@echo Format changelog
	@$(CALABASH) -isource=$< -oresult=$@ ../../style/formatspec.xpl

glossary.xml: ,,xproc20.xml ../../style/makeglossary.xsl
	@echo Making glossary
	@$(SAXON) -s:$< -xsl:../../style/makeglossary.xsl -o:$@

error-list.xml: ,xproc20.xml
	@echo Extract error list: $@
	@$(SAXON) -s:$< -xsl:../../style/error-list.xsl -o:$@

clean:
	rm -f $(TARGETS) ,xproc20.xml ,,xproc20.xml glossary.xml
	rm -f diff.html error-list.xml
	$(MAKE) -C examples clean
