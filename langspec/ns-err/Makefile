empty :=
space := $(empty) $(empty)

CLASSPATH=$(subst  $(space),:,$(wildcard ../../lib/*.jar))
SAXON=java -cp $(CLASSPATH) -jar ../../lib/saxon9he.jar
CALABASH=java -cp $(CLASSPATH) com.xmlcalabash.drivers.Main

TARGETS=xproc-error.html error-list.xml

all: $(TARGETS)

xproc-error.html: ,xproc-error.xml
	$(SAXON) -s:$< -xsl:../../style/dbspec.xsl -o:$@

# Cannot validate schema=../../schema/dbspec.rng
# Fix it so that it validates!
,xproc-error.xml: xproc-error.xml error-list.xml \
               ../../style/docbook.xsl ../../style/dbspec.xsl \
               ../../style/xprocns.xsl ../../style/rngsyntax.xsl
	@echo FIXME: make this validate
	$(CALABASH) -isource=$< -oresult=$@ \
                    ../../style/validate.xpl

error-list.xml: ../,langspec.xml ../../style/error-list.xsl
	$(SAXON) -s:$< -xsl:../../style/error-list.xsl -o:$@

clean:
	rm -f $(TARGETS) ,xproc-error.xml
