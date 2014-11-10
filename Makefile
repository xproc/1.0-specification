STYLES=$(wildcard style/*.xsl)

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
	curl -s -o build/langspec/xproc20/base.css http://www.w3.org/StyleSheets/TR/base.css
	cp langspec/xproc20/Overview.html build/langspec/xproc20/
	cp langspec/xproc20/,xproc20.xml  build/langspec/xproc20/xproc20.xml
	cp langspec/xproc20/changelog.xml build/langspec/xproc20/
	cp langspec/xproc20/changelog.html build/langspec/xproc20/
	cp langspec/xproc20/.htaccess build/langspec/xproc20/
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
	cp langspec/xproc20-steps/Overview.html build/langspec/xproc20-steps/
	cp langspec/xproc20-steps/,steps.xml  build/langspec/xproc20-steps/xproc20-steps.xml
	cp langspec/xproc20-steps/changelog.xml build/langspec/xproc20-steps/
	cp langspec/xproc20-steps/changelog.html build/langspec/xproc20-steps/
	cp langspec/xproc20-steps/.htaccess build/langspec/xproc20-steps/
	cp style/xproc.css build/langspec/xproc20-steps/
	cp js/prism.js build/langspec/xproc20-steps/
	@echo ==================================================
	cp build/langspec/xproc20/base.css build/langspec/ns-p/
	cp langspec/ns-p/Overview.html build/langspec/ns-p/
	cp langspec/ns-p/,xproc.xml  build/langspec/ns-p/ns-p.xml
	cp langspec/xproc20/.htaccess build/langspec/ns-p/
	cp style/xproc.css build/langspec/ns-p/
	cp js/prism.js build/langspec/ns-p/
	@echo ==================================================
	cp build/langspec/xproc20/base.css build/langspec/ns-c/
	cp langspec/ns-c/Overview.html build/langspec/ns-c/
	cp langspec/ns-c/,xproc-step.xml  build/langspec/ns-c/ns-c.xml
	cp langspec/xproc20/.htaccess build/langspec/ns-c/
	cp style/xproc.css build/langspec/ns-c/
	cp js/prism.js build/langspec/ns-c/
	@echo ==================================================
	cp build/langspec/xproc20/base.css build/langspec/ns-err/
	cp langspec/ns-err/Overview.html build/langspec/ns-err/
	cp langspec/ns-err/,xproc-error.xml  build/langspec/ns-err/ns-err.xml
	cp langspec/xproc20/.htaccess build/langspec/ns-err/
	cp style/xproc.css build/langspec/ns-err/
	cp js/prism.js build/langspec/ns-err/

spec: build/langspec/Overview.html

req: build/langreq/Overview.html


build/xproc20/Overview.html: langspec/xproc20.html
	cp langspec/xproc20.html build/xproc20/
	mv build/xproc20/xproc20.html $@
	cp langspec/,xproc20.xml build/xproc20/xproc20.xml
	cp langspec/changelog.xml build/xproc20/
	cd langspec && tar cf - graphics | (cd ../build/xproc20; tar xf -)
	cp langspec/ns-p/xproc.html build/xproc20/ns/
	cp langspec/ns-c/xproc-step.html build/xproc20/ns/
	cp langspec/ns-err/xproc-error.html build/xproc20/ns/
	cp style/xproc.css build/xproc20/
	cp style/xproc.css build/xproc20/ns/
	cp js/prism.js build/xproc20/
	cp js/prism.js build/xproc20/ns/
	curl -s -o build/xproc20/base.css http://www.w3.org/StyleSheets/TR/base.css
	cp build/xproc20/base.css build/xproc20/ns/
	cp langspec/ns-p/xproc.html build/xproc20/ns/
	cp langspec/ns-p/,xproc.xml build/xproc20/ns/xproc.xml
	cp langspec/ns-c/xproc-step.html build/xproc20/ns/
	cp langspec/ns-c/,xproc-step.xml build/xproc20/ns/xproc-step.xml
	cp langspec/ns-err/xproc-error.html build/xproc20/ns/
	cp langspec/ns-err/,xproc-error.xml build/xproc20/ns/xproc-error.xml
	cp langspec/schemas/xproc.rng build/xproc20/schemas/
	cp langspec/schemas/xproc.rnc build/xproc20/schemas/
	cp langspec/schemas/xproc.xsd build/xproc20/schemas/
	cp langspec/schemas/xproc.dtd build/xproc20/schemas/

build/langspec/Overview.html: langspec/langspec.html
	cp langspec/*.html build/langspec/
	mv build/langspec/langspec.html $@
	cp langspec/,langspec.xml build/langspec/langspec.xml
	cp langspec/changelog.xml build/langspec/
	cd langspec && tar cf - graphics | (cd ../build/langspec; tar xf -)
	cp langspec/ns-p/xproc.html build/langspec/ns/
	cp langspec/ns-c/xproc-step.html build/langspec/ns/
	cp langspec/ns-err/xproc-error.html build/langspec/ns/
	cp style/xproc.css build/langspec/
	cp style/xproc.css build/langspec/ns/
	cp js/prism.js build/langspec/
	cp js/prism.js build/langspec/ns/
	curl -s -o build/langspec/base.css http://www.w3.org/StyleSheets/TR/base.css
	cp build/langspec/base.css build/langspec/ns/
	cp langspec/ns-p/xproc.html build/langspec/ns/
	cp langspec/ns-p/,xproc.xml build/langspec/ns/xproc.xml
	cp langspec/ns-c/xproc-step.html build/langspec/ns/
	cp langspec/ns-c/,xproc-step.xml build/langspec/ns/xproc-step.xml
	cp langspec/ns-err/xproc-error.html build/langspec/ns/
	cp langspec/ns-err/,xproc-error.xml build/langspec/ns/xproc-error.xml
	cp langspec/schemas/xproc.rng build/langspec/schemas/
	cp langspec/schemas/xproc.rnc build/langspec/schemas/
	cp langspec/schemas/xproc.xsd build/langspec/schemas/
	cp langspec/schemas/xproc.dtd build/langspec/schemas/

build/langreq/Overview.html: langreq/xproc-v2-req.html
	cp langreq/*.html build/langreq/
	mv build/langreq/xproc-v2-req.html $@
	cp langreq/,xproc-v2-req.xml build/langreq/xproc-v2-req.xml
	cp style/xproc.css build/langreq/
	curl -s -o build/langreq/base.css http://www.w3.org/StyleSheets/TR/base.css

LANGSPECSRC=langspec/conformance.xml langspec/error-codes.xml \
            langspec/glossary.xml langspec/langspec.xml \
            langspec/language-summary.xml langspec/mediatype.xml \
            langspec/namespace-fixup.xml langspec/parallel.xml \
            langspec/references.xml \
            langspec/serialization-options-for-escape-markup.xml \
            langspec/serialization-options.xml langspec/standard-components.xml

langspec/xproc20.html: $(LANGSPECSRC) $(STYLES)
	mkdir -p build/xproc20 build/xproc20/schemas build/xproc20/ns
	$(MAKE) -C schema
	$(MAKE) -C langspec

langspec/langspec.html: $(LANGSPECSRC) $(STYLES)
	mkdir -p build/langspec build/langspec/schemas build/langspec/ns
	$(MAKE) -C schema
	$(MAKE) -C langspec

langreq/xproc-v2-req.html: langreq/xproc-v2-req.xml $(STYLES)
	mkdir -p build/langreq
	$(MAKE) -C schema
	$(MAKE) -C langreq

clean:
	rm -rf build
	$(MAKE) -C schema clean
	$(MAKE) -C langspec clean
	$(MAKE) -C langreq clean
