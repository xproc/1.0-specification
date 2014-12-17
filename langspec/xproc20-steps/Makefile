empty :=
space := $(empty) $(empty)

CLASSPATH=$(subst  $(space),:,$(wildcard ../../lib/*.jar)):../../lib
SAXON=java -cp $(CLASSPATH) -jar ../../lib/saxon9he.jar
CALABASH=java -cp $(CLASSPATH) com.xmlcalabash.drivers.Main -c ../../.calabash

TARGETS=changelog.html Overview.html diff.html

all: $(TARGETS)

# ============================================================

Overview.html: ,steps.xml typed-pipeline-library.xml error-list.xml \
               ../../style/docbook.xsl ../../style/dbspec.xsl \
               ../../style/xprocns.xsl ../../style/rngsyntax.xsl
	@echo Format spec: $@
	@$(CALABASH) -isource=$< -oresult=$@ \
	            -pschemaext.schema=../../../../../schema/dbspec.rng \
                    -pxml.toc.filename=steps.toc.xml \
                    -potherspec=../xproc20/,xproc20.xml \
                    -potherprefix="../" \
	            -pothersuffix="" \
                    -potherlabel="XP" \
                    ../../style/formatspec.xpl style=xproc-specs.xsl

,steps.xml: steps.xml errors.xml error-codes.xml \
               serialization-options-for-escape-markup.xml \
               serialization-options.xml
	$(MAKE) -C examples
	@echo XInclude spec: $<
	@$(CALABASH) -isource=$< -oresult=$@ \
                    ../../style/validate.xpl \
                    schema="" schematron=""

# ============================================================

diff.html: Overview.html
	../../lib/make-diff.sh xproc20-steps

changelog.html: changelog.xml
	@echo Format changelog
	@$(CALABASH) -isource=$< -oresult=$@ \
                     ../../style/formatspec.xpl

error-list.xml: ,steps.xml
	@echo Extract error list: $@
	@$(SAXON) -s:$< -xsl:../../style/error-list.xsl -o:$@

pipeline-library.xml: ,steps.xml
	@echo Extract pipeline library: $@
	@$(SAXON) -s:$< -xsl:../../style/pipeline-library.xsl -o:$@

typed-pipeline-library.xml: ,steps.xml pipeline-library.xml
	@echo Extract typed pipeline library: $@
	@$(SAXON) -s:$< -xsl:../../style/typed-pipeline-library.xsl -o:$@

#	@$(MAKE) -C schemas

clean:
	rm -f $(TARGETS) ,steps.xml ,steps.xml
	rm -f pipeline-library.xml typed-pipeline-library.xml
	rm -f error-list.xml diff.html
	$(MAKE) -C examples clean
