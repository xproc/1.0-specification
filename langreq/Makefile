empty :=
space := $(empty) $(empty)

CLASSPATH=$(subst  $(space),:,$(wildcard ../lib/*.jar)):../lib
SAXON=java -cp $(CLASSPATH) -jar ../lib/saxon9he.jar
CALABASH=java -cp $(CLASSPATH) com.xmlcalabash.drivers.Main -c ../.calabash

TARGETS=xproc-v2-req.html

all: $(TARGETS)

,xproc-v2-req.xml: xproc-v2-req.xml
	$(CALABASH) -isource=$< -oresult=$@ \
                    ../style/validate.xpl schema=../schema/dbspec.rng

xproc-v2-req.html: ,xproc-v2-req.xml ../style/dbspec.xsl
	$(CALABASH) -isource=$< -oresult=$@ \
	            -pschemaext.schema=../../../../../schema/dbspec.rng \
                    ../style/formatspec.xpl

clean:
	rm -f $(TARGETS) ,xproc-v2-req.xml
