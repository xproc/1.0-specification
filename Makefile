all: build/langspec/Overview.html

build/langspec/Overview.html: langspec/langspec.html
	cp langspec/langspec.html $@
	cd langspec && tar cf - graphics | (cd ../build/langspec; tar xf -)
	cp langspec/ns-p/xproc.html build/langspec/ns/
	cp langspec/ns-c/xproc-step.html build/langspec/ns/
	cp langspec/ns-err/xproc-error.html build/langspec/ns/

langspec/langspec.html: langspec/langspec.xml
	mkdir -p build/langspec build/langspec/ns
	$(MAKE) -C schema
	$(MAKE) -C langspec

clean:
	rm -rf build
	$(MAKE) -C schema clean
	$(MAKE) -C langspec clean
