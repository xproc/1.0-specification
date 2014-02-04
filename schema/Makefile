TRANG=trang

.SUFFIXES: .rng .rnc

SRCS=$(wildcard *.rnc)
OBJS=${SRCS:.rnc=.rng}

all: $(OBJS)

.rnc.rng:
	$(TRANG) $< $@

clean:
	rm -f *.rng
