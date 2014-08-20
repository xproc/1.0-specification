empty :=
space := $(empty) $(empty)

CLASSPATH=$(subst  $(space),:,$(wildcard ../lib/*.jar))
TRANG=java -cp $(CLASSPATH) com.thaiopensource.relaxng.translate.Driver

.SUFFIXES: .rng .rnc

SRCS=$(wildcard *.rnc)
OBJS=${SRCS:.rnc=.rng}

all: $(OBJS)

.rnc.rng:
	$(TRANG) $< $@

clean:
	rm -f *.rng
