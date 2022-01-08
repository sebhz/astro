# VSOP87

The files under the raw directory are Bretagnon and Francou VSOP87 data files, retrieved
from ftp://cdsarc.u-strasbg.fr/pub/cats/VI/81.

Those files are processed by the `create_vsop87_include.py` script to generate the C header files
used by the `lib/vsop87.c` routines.
The `create_vsop87_test.py` script creates a C test file from the vsop87.chk file.

