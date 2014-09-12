empty :=
space := $(empty) $(empty)

CLASSPATH=$(subst  $(space),:,$(wildcard ../../lib/*.jar)):../../lib
SAXON=java -cp $(CLASSPATH) -jar ../../lib/saxon9he.jar
CALABASH=java -cp $(CLASSPATH) com.xmlcalabash.drivers.Main

TARGETS=xproc.html ns-xproc-p-incl.xml

all: $(TARGETS)

xproc.html: ,xproc.xml
	$(SAXON) -s:$< -xsl:../../style/dbspec.xsl -o:$@

,xproc.xml: xproc.xml ns-xproc-p-incl.xml \
               ../../style/docbook.xsl ../../style/dbspec.xsl \
               ../../style/xprocns.xsl ../../style/rngsyntax.xsl
	$(CALABASH) -isource=$< -oresult=$@ \
                    ../../style/validate.xpl schema=../../schema/dbspec.rng

ns-xproc-p-incl.xml: ../,langspec.xml ../../style/ns-extract.xsl
	$(SAXON) -s:$< -xsl:../../style/ns-extract.xsl -o:$@

clean:
	rm -f $(TARGETS) ,xproc.xml

