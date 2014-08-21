STYLES=$(wildcard style/*.xsl)

spec: build/langspec/Overview.html

all: spec build/langreq/Overview.html

build/langspec/Overview.html: langspec/langspec.html
	cp langspec/langspec.html $@
	cp langspec/,langspec.xml langspec/langspec.xml
	cd langspec && tar cf - graphics | (cd ../build/langspec; tar xf -)
	cp langspec/ns-p/xproc.html build/langspec/ns/
	cp langspec/ns-c/xproc-step.html build/langspec/ns/
	cp langspec/ns-err/xproc-error.html build/langspec/ns/
	cp style/xproc.css build/langspec/
	cp style/xproc.css build/langspec/ns/
	curl -s -o build/langspec/base.css http://www.w3.org/StyleSheets/TR/base.css


langspec/langspec.html: langspec/langspec.xml $(STYLES)
	mkdir -p build/langspec build/langspec/ns
	$(MAKE) -C schema
	$(MAKE) -C langspec

build/langreq/Overview.html: langreq/xproc-v2-req.html
	cp langreq/xproc-v2-req.html $@

langreq/xproc-v2-req.html: langreq/xproc-v2-req.xml
	mkdir -p build/langreq
	$(MAKE) -C schema
	$(MAKE) -C langreq

clean:
	rm -rf build
	$(MAKE) -C schema clean
	$(MAKE) -C langspec clean
	$(MAKE) -C langreq clean
