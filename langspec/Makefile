SAXON=saxon
TIDY=/usr/bin/tidy
CALABASH=calabash

TARGETS=langspec.html error-list.xml \
        pipeline-library.xml typed-pipeline-library.xml

all: $(TARGETS)

langspec.html: ,langspec.xml typed-pipeline-library.xml \
               ../style/docbook.xsl ../style/dbspec.xsl \
               ../style/xprocns.xsl ../style/rngsyntax.xsl
	$(SAXON) $< ../style/dbspec.xsl $@
	$(TIDY) --doctype loose --output-xhtml true -q -utf8 -mn $@

,langspec.xml: langspec.xml
	$(MAKE) -C examples
	$(CALABASH) -isource=$< -oresult=$@ \
                    ../style/validate.xpl schema=../schema/dbspec.rng

error-list.xml: ,langspec.xml
	$(SAXON) $< ../style/error-list.xsl $@

pipeline-library.xml: ,langspec.xml
	$(SAXON) $< ../style/pipeline-library.xsl $@

typed-pipeline-library.xml: ,langspec.xml
	$(SAXON) $< ../style/typed-pipeline-library.xsl $@
	$(MAKE) -C schemas

clean:
	rm -f $(TARGETS) ,langspec.xml
	$(MAKE) -C schemas clean
	$(MAKE) -C examples clean
