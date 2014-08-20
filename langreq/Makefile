SAXON=saxon
TIDY=/usr/bin/tidy
CALABASH=calabash

TARGETS=xproc-v2-req.html

all: $(TARGETS)

,xproc-v2-req.xml: xproc-v2-req.xml
	$(CALABASH) -isource=$< -oresult=$@ \
                    ../style/validate.xpl schema=../schema/dbspec.rng

xproc-v2-req.html: ,xproc-v2-req.xml ../style/dbspec.xsl
	$(SAXON) $< ../style/dbspec.xsl $@
	$(TIDY) --doctype loose --output-xhtml true -q -utf8 -mn $@

clean:
	rm -f $(TARGETS) ,xproc-v2-req.xml
