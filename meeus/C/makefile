MEEUS_OBJ = lib/datetime.o \
            lib/calendar.o \
            lib/dynamical.o \
            lib/sidereal.o \
            lib/ecliptic.o \
            lib/coordinates.o \
            lib/refraction.o \
	        lib/sun.o \
	        lib/equinox.o \
	        lib/equation_time.o \
	        lib/util.o \
	        lib/vsop87.o
MEEUS_INC = include/meeus.h include/vsop87.h
MEEUS_LIB = lib/libmeeus.a

TEST_OBJ = lib/test.o
TEST_INC = include/test.h

CFLAGS += -Wall -Iinclude
LDLIBS += -lm

PRG = prg/validate_meeus prg/validate_vsop87d prg/sun_coord prg/biorythm

.PHONY : clean indent doc

all: $(PRG)

$(MEEUS_OBJ): $(MEEUS_INC)

$(MEEUS_LIB): $(MEEUS_OBJ)
	ar r $@ $(MEEUS_OBJ) 

$(TEST_OBJ): $(TEST_INC) $(MEEUS_INC)

prg/validate_meeus: prg/validate_meeus.o $(MEEUS_LIB) $(TEST_OBJ)

prg/validate_vsop87d: prg/validate_vsop87d.o $(MEEUS_LIB) $(TEST_OBJ)

prg/sun_coord: prg/sun_coord.o $(MEEUS_LIB)

prg/biorythm: prg/biorythm.o $(MEEUS_LIB)

indent:
	indent -braces-on-if-lines --no-tabs --indent-level4 prg/*.c lib/*.c include/meeus.h include/test.h

doc:
	doxygen

clean:
	rm -fr $(PRG) $(MEEUS_LIB) prg/*.o lib/*.o prg/*~ lib/*~ include/*~
