all: build/langspec/Overview.html

build/langspec/Overview.html: langspec/langspec.html
	cp langspec/langspec.html $@
	cd langspec && tar cf - graphics | (cd ../build/langspec; tar xf -)

langspec/langspec.html: langspec/langspec.xml
	mkdir -p build/langspec
	$(MAKE) -C schema
	$(MAKE) -C langspec

clean:
	rm -rf build
	$(MAKE) -C schema clean
	$(MAKE) -C langspec clean
