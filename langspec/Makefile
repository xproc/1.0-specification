empty :=
space := $(empty) $(empty)

CLASSPATH=$(subst  $(space),:,$(wildcard ../lib/*.jar))
SAXON=java -cp $(CLASSPATH) -jar ../lib/saxon9he.jar
CALABASH=java -cp $(CLASSPATH) com.xmlcalabash.drivers.Main

TARGETS=langspec.html error-list.xml \
        pipeline-library.xml typed-pipeline-library.xml

all: $(TARGETS)
	$(MAKE) -C ns-p
	$(MAKE) -C ns-c
	$(MAKE) -C ns-err

langspec.html: ,langspec.xml typed-pipeline-library.xml \
               ../style/docbook.xsl ../style/dbspec.xsl \
               ../style/xprocns.xsl ../style/rngsyntax.xsl
	$(CALABASH) -isource=$< -oresult=$@ ../style/formatspec.xpl

,langspec.xml: langspec.xml
	$(MAKE) -C examples
	$(CALABASH) -isource=$< -oresult=$@ \
                    ../style/validate.xpl schema=../schema/dbspec.rng

error-list.xml: ,langspec.xml
	$(SAXON) -s:$< -xsl:../style/error-list.xsl -o:$@

pipeline-library.xml: ,langspec.xml
	$(SAXON) -s:$< -xsl:../style/pipeline-library.xsl -o:$@

typed-pipeline-library.xml: ,langspec.xml
	$(SAXON) -s:$< -xsl:../style/typed-pipeline-library.xsl -o:$@
	$(MAKE) -C schemas

clean:
	rm -f $(TARGETS) ,langspec.xml
	$(MAKE) -C schemas clean
	$(MAKE) -C examples clean
	$(MAKE) -C ns-c clean
	$(MAKE) -C ns-err clean
	$(MAKE) -C ns-p clean
