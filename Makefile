STYLES=$(wildcard style/*.xsl)
STAGETYPE=WD
STAGEROOT=/tmp/xproc20
STAGEDATE=19670616
STAGEXPROC=$(STAGEROOT)/$(STAGETYPE)-xproc20-$(STAGEDATE)
STAGESTEPS=$(STAGEROOT)/$(STAGETYPE)-xproc20-steps-$(STAGEDATE)

all: xproc20 req

xproc20:
	$(MAKE) -C schema
	$(MAKE) -C langspec
	mkdir -p build/langspec/xproc20
	mkdir -p build/langspec/xproc20/schemas
	mkdir -p build/langspec/xproc20-steps
	mkdir -p build/langspec/ns-p
	mkdir -p build/langspec/ns-c
	mkdir -p build/langspec/ns-err
	cp style/base.css build/langspec/xproc20/base.css
	cp langspec/xproc20/Overview.html build/langspec/xproc20/index.html
	cp langspec/xproc20/,xproc20.xml  build/langspec/xproc20/xproc20.xml
	if [ -f langspec/xproc20/diff.html ]; then cp langspec/xproc20/diff.html build/langspec/xproc20/; fi
	cp langspec/xproc20/changelog.xml build/langspec/xproc20/
	cp langspec/xproc20/changelog.html build/langspec/xproc20/
	cd langspec/xproc20 && tar cf - graphics \
           | (cd ../../build/langspec/xproc20; tar xf -)
	cp style/xproc.css build/langspec/xproc20/
	cp js/prism.js build/langspec/xproc20/
	cp langspec/schemas/xproc.rng build/langspec/xproc20/schemas/
	cp langspec/schemas/steps.rng build/langspec/xproc20/schemas/
	cp langspec/schemas/xproc.rnc build/langspec/xproc20/schemas/
	cp langspec/schemas/steps.rnc build/langspec/xproc20/schemas/
	cp langspec/schemas/xproc.xsd build/langspec/xproc20/schemas/
	cp langspec/schemas/xproc.dtd build/langspec/xproc20/schemas/
	@echo ==================================================
	cp build/langspec/xproc20/base.css build/langspec/xproc20-steps/
	cp langspec/xproc20-steps/Overview.html build/langspec/xproc20-steps/index.html
	cp langspec/xproc20-steps/,steps.xml  build/langspec/xproc20-steps/xproc20-steps.xml
	if [ -f langspec/xproc20-steps/diff.html ]; then cp langspec/xproc20-steps/diff.html build/langspec/xproc20-steps/; fi
	cp langspec/xproc20-steps/changelog.xml build/langspec/xproc20-steps/
	cp langspec/xproc20-steps/changelog.html build/langspec/xproc20-steps/
	cp style/xproc.css build/langspec/xproc20-steps/
	cp js/prism.js build/langspec/xproc20-steps/
	@echo ==================================================
	cp build/langspec/xproc20/base.css build/langspec/ns-p/
	cp langspec/ns-p/Overview.html build/langspec/ns-p/index.html
	cp langspec/ns-p/,xproc.xml  build/langspec/ns-p/ns-p.xml
	cp style/xproc.css build/langspec/ns-p/
	cp js/prism.js build/langspec/ns-p/
	@echo ==================================================
	cp build/langspec/xproc20/base.css build/langspec/ns-c/
	cp langspec/ns-c/Overview.html build/langspec/ns-c/index.html
	cp langspec/ns-c/,xproc-step.xml  build/langspec/ns-c/ns-c.xml
	cp style/xproc.css build/langspec/ns-c/
	cp js/prism.js build/langspec/ns-c/
	@echo ==================================================
	cp build/langspec/xproc20/base.css build/langspec/ns-err/
	cp langspec/ns-err/Overview.html build/langspec/ns-err/index.html
	cp langspec/ns-err/,xproc-error.xml  build/langspec/ns-err/ns-err.xml
	cp style/xproc.css build/langspec/ns-err/
	cp js/prism.js build/langspec/ns-err/

stage-xproc20: xproc20
	mkdir -p $(STAGEXPROC) $(STAGESTEPS)
	rsync -ar build/langspec/xproc20/ $(STAGEXPROC)/
	rsync -ar build/langspec/xproc20-steps/ $(STAGESTEPS)/
	echo "<!DOCTYPE html>" > $(STAGEXPROC)/Overview.html
	echo "<!DOCTYPE html>" > $(STAGESTEPS)/Overview.html
	cat $(STAGEXPROC)/index.html >> $(STAGEXPROC)/Overview.html
	cat $(STAGESTEPS)/index.html >> $(STAGESTEPS)/Overview.html
	rm -f $(STAGEXPROC)/index.html $(STAGESTEPS)/index.html

req:
	mkdir -p build/langreq
	$(MAKE) -C schema
	$(MAKE) -C langreq
	cp langreq/*.html build/langreq/
	mv build/langreq/xproc-v2-req.html build/langreq/index.html
	cp langreq/,xproc-v2-req.xml build/langreq/xproc-v2-req.xml
	cp style/base.css build/langreq/base.css
	cp style/xproc.css build/langreq/
	cp js/prism.js build/langreq/

clean:
	rm -rf build
	$(MAKE) -C schema clean
	$(MAKE) -C langspec clean
	$(MAKE) -C langreq clean
