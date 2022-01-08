INCLUDE = ../../include/vsop87.h
VALID = ../../prg/validate_vsop87d.c

.PHONY: all inc val clean

all: $(INCLUDE) $(VALID)

inc: $(INCLUDE)

val: $(VALID)

$(INCLUDE):
	./create_vsop87_include.py > $@

$(VALID):
	./create_vsop87_test.py > $@

clean:
	rm -fr $(INCLUDE) $(VALID)
