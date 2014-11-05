STYLES=$(wildcard style/*.xsl)

spec: build/langspec/Overview.html

req: build/langreq/Overview.html

all: spec req

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
