include ../../buildtools/Makefile.incl

param.xsl: param.xml ../common/mkparam.xsl
	../../buildtools/saxon -8b $^ $@

clean:
	$(RM) param.xsl
