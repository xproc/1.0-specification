all: build/langspec/Overview.html

build/langspec/Overview.html: langspec/langspec.xml
	mkdir -p build/langspec
	$(MAKE) -C schema
	$(MAKE) -C langspec
	cp langspec/langspec.html $@
	cd langspec && tar cf - graphics | (cd ../build/langspec; tar xf -)

clean:
	rm -rf build
	$(MAKE) -C schema clean
	$(MAKE) -C langspec clean
