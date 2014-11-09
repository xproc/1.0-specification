empty :=
space := $(empty) $(empty)

CLASSPATH=$(subst  $(space),:,$(wildcard ../lib/*.jar)):../lib
SAXON=java -cp $(CLASSPATH) -jar ../lib/saxon9he.jar
CALABASH=java -cp $(CLASSPATH) com.xmlcalabash.drivers.Main -c ../.calabash

all:
	$(MAKE) -C xproc20 ,xproc20.xml
	$(MAKE) -C xproc20-steps ,steps.xml typed-pipeline-library.xml
	$(MAKE) -C schemas
	$(MAKE) -C xproc20
	$(MAKE) -C xproc20-steps
	$(MAKE) -C ns-p
	$(MAKE) -C ns-c
	$(MAKE) -C ns-err

clean:
	$(MAKE) -C xproc20 clean
	$(MAKE) -C xproc20-steps clean
	$(MAKE) -C schemas clean
	$(MAKE) -C ns-c clean
	$(MAKE) -C ns-err clean
	$(MAKE) -C ns-p clean
