#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "meeus.h"
#include "test.h"

int success = 1;

int
main (int argc, char **argv)
{
    double coord[3];
    /* VSOP87D  MERCURY     JD2451545.0  01/01/2000 12h TDB */
    printf ("VSOP87D - MERCURY on J2451545.0 - ");
    vso_vsop87d_dyn_coordinates (2451545.0, MERCURY, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.4293481036, -.0527573409, .4664714751 },
               10, 0);

    /* VSOP87D  MERCURY     JD2415020.0  31/12/1899 12h TDB */
    printf ("VSOP87D - MERCURY on J2415020.0 - ");
    vso_vsop87d_dyn_coordinates (2415020.0, MERCURY, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.4851161911, .0565906173, .4183426275 },
               10, 0);

    /* VSOP87D  MERCURY     JD2378495.0  30/12/1799 12h TDB */
    printf ("VSOP87D - MERCURY on J2378495.0 - ");
    vso_vsop87d_dyn_coordinates (2378495.0, MERCURY, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 2.0737894888, .1168184804, .3233909533 },
               10, 0);

    /* VSOP87D  MERCURY     JD2341970.0  29/12/1699 12h TDB */
    printf ("VSOP87D - MERCURY on J2341970.0 - ");
    vso_vsop87d_dyn_coordinates (2341970.0, MERCURY, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { .1910149587, -.0682441256, .3381563139 },
               10, 0);

    /* VSOP87D  MERCURY     JD2305445.0  29/12/1599 12h TDB */
    printf ("VSOP87D - MERCURY on J2305445.0 - ");
    vso_vsop87d_dyn_coordinates (2305445.0, MERCURY, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 5.1836421820, -.1170914848, .4326517759 },
               10, 0);

    /* VSOP87D  MERCURY     JD2268920.0  19/12/1499 12h TDB */
    printf ("VSOP87D - MERCURY on J2268920.0 - ");
    vso_vsop87d_dyn_coordinates (2268920.0, MERCURY, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.2636517903, -.0457048516, .4661523936 },
               10, 0);

    /* VSOP87D  MERCURY     JD2232395.0  19/12/1399 12h TDB */
    printf ("VSOP87D - MERCURY on J2232395.0 - ");
    vso_vsop87d_dyn_coordinates (2232395.0, MERCURY, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.3115600862, .0639722347, .4152385205 },
               10, 0);

    /* VSOP87D  MERCURY     JD2195870.0  19/12/1299 12h TDB */
    printf ("VSOP87D - MERCURY on J2195870.0 - ");
    vso_vsop87d_dyn_coordinates (2195870.0, MERCURY, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.8738888759, .1126774697, .3209366232 },
               10, 0);

    /* VSOP87D  MERCURY     JD2159345.0  19/12/1199 12h TDB */
    printf ("VSOP87D - MERCURY on J2159345.0 - ");
    vso_vsop87d_dyn_coordinates (2159345.0, MERCURY, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 6.2819826060, -.0768697084, .3414354250 },
               10, 0);

    /* VSOP87D  MERCURY     JD2122820.0  19/12/1099 12h TDB */
    printf ("VSOP87D - MERCURY on J2122820.0 - ");
    vso_vsop87d_dyn_coordinates (2122820.0, MERCURY, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 5.0128397764, -.1143275808, .4352063237 },
               10, 0);

    /* VSOP87D  VENUS       JD2451545.0  01/01/2000 12h TDB */
    printf ("VSOP87D - VENUS on J2451545.0 - ");
    vso_vsop87d_dyn_coordinates (2451545.0, VENUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.1870221833, .0569782849, .7202129253 },
               10, 0);

    /* VSOP87D  VENUS       JD2415020.0  31/12/1899 12h TDB */
    printf ("VSOP87D - VENUS on J2415020.0 - ");
    vso_vsop87d_dyn_coordinates (2415020.0, VENUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 5.9749622238, -.0591260014, .7274719359 },
               10, 0);

    /* VSOP87D  VENUS       JD2378495.0  30/12/1799 12h TDB */
    printf ("VSOP87D - VENUS on J2378495.0 - ");
    vso_vsop87d_dyn_coordinates (2378495.0, VENUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 2.5083656668, .0552309407, .7185473298 },
               10, 0);

    /* VSOP87D  VENUS       JD2341970.0  29/12/1699 12h TDB */
    printf ("VSOP87D - VENUS on J2341970.0 - ");
    vso_vsop87d_dyn_coordinates (2341970.0, VENUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 5.3115708036, -.0455979904, .7283407528 },
               10, 0);

    /* VSOP87D  VENUS       JD2305445.0  29/12/1599 12h TDB */
    printf ("VSOP87D - VENUS on J2305445.0 - ");
    vso_vsop87d_dyn_coordinates (2305445.0, VENUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.8291359617, .0311394084, .7186375037 },
               10, 0);

    /* VSOP87D  VENUS       JD2268920.0  19/12/1499 12h TDB */
    printf ("VSOP87D - VENUS on J2268920.0 - ");
    vso_vsop87d_dyn_coordinates (2268920.0, VENUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.6495448744, -.0145437542, .7273363753 },
               10, 0);

    /* VSOP87D  VENUS       JD2232395.0  19/12/1399 12h TDB */
    printf ("VSOP87D - VENUS on J2232395.0 - ");
    vso_vsop87d_dyn_coordinates (2232395.0, VENUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.1527504143, -.0054100666, .7205428514 },
               10, 0);

    /* VSOP87D  VENUS       JD2195870.0  19/12/1299 12h TDB */
    printf ("VSOP87D - VENUS on J2195870.0 - ");
    vso_vsop87d_dyn_coordinates (2195870.0, VENUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.9850309909, .0222342485, .7247441174 },
               10, 0);

    /* VSOP87D  VENUS       JD2159345.0  19/12/1199 12h TDB */
    printf ("VSOP87D - VENUS on J2159345.0 - ");
    vso_vsop87d_dyn_coordinates (2159345.0, VENUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { .4804699931, -.0395505250, .7235430458 },
               10, 0);

    /* VSOP87D  VENUS       JD2122820.0  19/12/1099 12h TDB */
    printf ("VSOP87D - VENUS on J2122820.0 - ");
    vso_vsop87d_dyn_coordinates (2122820.0, VENUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.3145399295, .0505016053, .7215819783 },
               10, 0);

    /* VSOP87D  EARTH       JD2451545.0  01/01/2000 12h TDB */
    printf ("VSOP87D - EARTH on J2451545.0 - ");
    vso_vsop87d_dyn_coordinates (2451545.0, EARTH, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.7519238681, -.0000039656, .9833276819 },
               10, 0);

    /* VSOP87D  EARTH       JD2415020.0  31/12/1899 12h TDB */
    printf ("VSOP87D - EARTH on J2415020.0 - ");
    vso_vsop87d_dyn_coordinates (2415020.0, EARTH, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.7391225563, -.0000005679, .9832689778 },
               10, 0);

    /* VSOP87D  EARTH       JD2378495.0  30/12/1799 12h TDB */
    printf ("VSOP87D - EARTH on J2378495.0 - ");
    vso_vsop87d_dyn_coordinates (2378495.0, EARTH, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.7262638916, .0000002083, .9832274321 },
               10, 0);

    /* VSOP87D  EARTH       JD2341970.0  29/12/1699 12h TDB */
    printf ("VSOP87D - EARTH on J2341970.0 - ");
    vso_vsop87d_dyn_coordinates (2341970.0, EARTH, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.7134419105, .0000025051, .9831498441 },
               10, 0);

    /* VSOP87D  EARTH       JD2305445.0  29/12/1599 12h TDB */
    printf ("VSOP87D - EARTH on J2305445.0 - ");
    vso_vsop87d_dyn_coordinates (2305445.0, EARTH, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.7006065938, -.0000016359, .9831254376 },
               10, 0);

    /* VSOP87D  EARTH       JD2268920.0  19/12/1499 12h TDB */
    printf ("VSOP87D - EARTH on J2268920.0 - ");
    vso_vsop87d_dyn_coordinates (2268920.0, EARTH, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.6877624960, -.0000020340, .9830816756 },
               10, 0);

    /* VSOP87D  EARTH       JD2232395.0  19/12/1399 12h TDB */
    printf ("VSOP87D - EARTH on J2232395.0 - ");
    vso_vsop87d_dyn_coordinates (2232395.0, EARTH, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.6750110961, .0000037879, .9830754409 },
               10, 0);

    /* VSOP87D  EARTH       JD2195870.0  19/12/1299 12h TDB */
    printf ("VSOP87D - EARTH on J2195870.0 - ");
    vso_vsop87d_dyn_coordinates (2195870.0, EARTH, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.6622048657, .0000015133, .9830942385 },
               10, 0);

    /* VSOP87D  EARTH       JD2159345.0  19/12/1199 12h TDB */
    printf ("VSOP87D - EARTH on J2159345.0 - ");
    vso_vsop87d_dyn_coordinates (2159345.0, EARTH, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.6495143197, -.0000013003, .9830440397 },
               10, 0);

    /* VSOP87D  EARTH       JD2122820.0  19/12/1099 12h TDB */
    printf ("VSOP87D - EARTH on J2122820.0 - ");
    vso_vsop87d_dyn_coordinates (2122820.0, EARTH, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.6367193623, -.0000031292, .9830331815 },
               10, 0);

    /* VSOP87D  MARS        JD2451545.0  01/01/2000 12h TDB */
    printf ("VSOP87D - MARS on J2451545.0 - ");
    vso_vsop87d_dyn_coordinates (2451545.0, MARS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 6.2735389983, -.0247779824, 1.3912076925 },
               10, 0);

    /* VSOP87D  MARS        JD2415020.0  31/12/1899 12h TDB */
    printf ("VSOP87D - MARS on J2415020.0 - ");
    vso_vsop87d_dyn_coordinates (2415020.0, MARS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.9942005211, -.0271965869, 1.4218777705 },
               10, 0);

    /* VSOP87D  MARS        JD2378495.0  30/12/1799 12h TDB */
    printf ("VSOP87D - MARS on J2378495.0 - ");
    vso_vsop87d_dyn_coordinates (2378495.0, MARS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.8711855478, .0034969939, 1.5615140011 },
               10, 0);

    /* VSOP87D  MARS        JD2341970.0  29/12/1699 12h TDB */
    printf ("VSOP87D - MARS on J2341970.0 - ");
    vso_vsop87d_dyn_coordinates (2341970.0, MARS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 2.9166648690, .0280268149, 1.6584697082 },
               10, 0);

    /* VSOP87D  MARS        JD2305445.0  29/12/1599 12h TDB */
    printf ("VSOP87D - MARS on J2305445.0 - ");
    vso_vsop87d_dyn_coordinates (2305445.0, MARS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 2.0058210394, .0300702181, 1.6371997207 },
               10, 0);

    /* VSOP87D  MARS        JD2268920.0  19/12/1499 12h TDB */
    printf ("VSOP87D - MARS on J2268920.0 - ");
    vso_vsop87d_dyn_coordinates (2268920.0, MARS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.0050966939, .0066676098, 1.5123622690 },
               10, 0);

    /* VSOP87D  MARS        JD2232395.0  19/12/1399 12h TDB */
    printf ("VSOP87D - MARS on J2232395.0 - ");
    vso_vsop87d_dyn_coordinates (2232395.0, MARS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 6.0979760762, -.0266794243, 1.3925964529 },
               10, 0);

    /* VSOP87D  MARS        JD2195870.0  19/12/1299 12h TDB */
    printf ("VSOP87D - MARS on J2195870.0 - ");
    vso_vsop87d_dyn_coordinates (2195870.0, MARS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.8193924948, -.0255031923, 1.4208707215 },
               10, 0);

    /* VSOP87D  MARS        JD2159345.0  19/12/1199 12h TDB */
    printf ("VSOP87D - MARS on J2159345.0 - ");
    vso_vsop87d_dyn_coordinates (2159345.0, MARS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.6939294875, .0065885509, 1.5593802008 },
               10, 0);

    /* VSOP87D  MARS        JD2122820.0  19/12/1099 12h TDB */
    printf ("VSOP87D - MARS on J2122820.0 - ");
    vso_vsop87d_dyn_coordinates (2122820.0, MARS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 2.7367104344, .0295522719, 1.6571002307 },
               10, 0);

    /* VSOP87D  JUPITER     JD2451545.0  01/01/2000 12h TDB */
    printf ("VSOP87D - JUPITER on J2451545.0 - ");
    vso_vsop87d_dyn_coordinates (2451545.0, JUPITER, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { .6334614186, -.0205001039, 4.9653813154 },
               10, 0);

    /* VSOP87D  JUPITER     JD2415020.0  31/12/1899 12h TDB */
    printf ("VSOP87D - JUPITER on J2415020.0 - ");
    vso_vsop87d_dyn_coordinates (2415020.0, JUPITER, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.0927527024, .0161446618, 5.3850276671 },
               10, 0);

    /* VSOP87D  JUPITER     JD2378495.0  30/12/1799 12h TDB */
    printf ("VSOP87D - JUPITER on J2378495.0 - ");
    vso_vsop87d_dyn_coordinates (2378495.0, JUPITER, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.5255696771, -.0043606936, 5.1318457604 },
               10, 0);

    /* VSOP87D  JUPITER     JD2341970.0  29/12/1699 12h TDB */
    printf ("VSOP87D - JUPITER on J2341970.0 - ");
    vso_vsop87d_dyn_coordinates (2341970.0, JUPITER, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.8888943125, -.0011098085, 5.1888133656 },
               10, 0);

    /* VSOP87D  JUPITER     JD2305445.0  29/12/1599 12h TDB */
    printf ("VSOP87D - JUPITER on J2305445.0 - ");
    vso_vsop87d_dyn_coordinates (2305445.0, JUPITER, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 2.3348832684, .0140523907, 5.3439455032 },
               10, 0);

    /* VSOP87D  JUPITER     JD2268920.0  19/12/1499 12h TDB */
    printf ("VSOP87D - JUPITER on J2268920.0 - ");
    vso_vsop87d_dyn_coordinates (2268920.0, JUPITER, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 5.7527666852, -.0188346311, 5.0018007395 },
               10, 0);

    /* VSOP87D  JUPITER     JD2232395.0  19/12/1399 12h TDB */
    printf ("VSOP87D - JUPITER on J2232395.0 - ");
    vso_vsop87d_dyn_coordinates (2232395.0, JUPITER, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.0889515350, .0231157947, 5.4491570191 },
               10, 0);

    /* VSOP87D  JUPITER     JD2195870.0  19/12/1299 12h TDB */
    printf ("VSOP87D - JUPITER on J2195870.0 - ");
    vso_vsop87d_dyn_coordinates (2195870.0, JUPITER, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { .3776503430, -.0222448936, 4.9715071036 },
               10, 0);

    /* VSOP87D  JUPITER     JD2159345.0  19/12/1199 12h TDB */
    printf ("VSOP87D - JUPITER on J2159345.0 - ");
    vso_vsop87d_dyn_coordinates (2159345.0, JUPITER, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.8455069137, .0185554473, 5.3896206945 },
               10, 0);

    /* VSOP87D  JUPITER     JD2122820.0  19/12/1099 12h TDB */
    printf ("VSOP87D - JUPITER on J2122820.0 - ");
    vso_vsop87d_dyn_coordinates (2122820.0, JUPITER, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.2695066546, -.0075335740, 5.1193587362 },
               10, 0);

    /* VSOP87D  SATURN      JD2451545.0  01/01/2000 12h TDB */
    printf ("VSOP87D - SATURN on J2451545.0 - ");
    vso_vsop87d_dyn_coordinates (2451545.0, SATURN, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { .7980038761, -.0401984149, 9.1838483715 },
               10, 0);

    /* VSOP87D  SATURN      JD2415020.0  31/12/1899 12h TDB */
    printf ("VSOP87D - SATURN on J2415020.0 - ");
    vso_vsop87d_dyn_coordinates (2415020.0, SATURN, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.6512836347, .0192701409, 10.0668531997 },
               10, 0);

    /* VSOP87D  SATURN      JD2378495.0  30/12/1799 12h TDB */
    printf ("VSOP87D - SATURN on J2378495.0 - ");
    vso_vsop87d_dyn_coordinates (2378495.0, SATURN, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 2.1956677359, .0104156566, 9.1043068639 },
               10, 0);

    /* VSOP87D  SATURN      JD2341970.0  29/12/1699 12h TDB */
    printf ("VSOP87D - SATURN on J2341970.0 - ");
    vso_vsop87d_dyn_coordinates (2341970.0, SATURN, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 5.8113963637, -.0291472787, 9.7629994924 },
               10, 0);

    /* VSOP87D  SATURN      JD2305445.0  29/12/1599 12h TDB */
    printf ("VSOP87D - SATURN on J2305445.0 - ");
    vso_vsop87d_dyn_coordinates (2305445.0, SATURN, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.5217555199, .0437035058, 9.7571035629 },
               10, 0);

    /* VSOP87D  SATURN      JD2268920.0  19/12/1499 12h TDB */
    printf ("VSOP87D - SATURN on J2268920.0 - ");
    vso_vsop87d_dyn_coordinates (2268920.0, SATURN, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { .8594235308, -.0379350088, 9.0669212839 },
               10, 0);

    /* VSOP87D  SATURN      JD2232395.0  19/12/1399 12h TDB */
    printf ("VSOP87D - SATURN on J2232395.0 - ");
    vso_vsop87d_dyn_coordinates (2232395.0, SATURN, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.6913199264, .0146771898, 10.1065692994 },
               10, 0);

    /* VSOP87D  SATURN      JD2195870.0  19/12/1299 12h TDB */
    printf ("VSOP87D - SATURN on J2195870.0 - ");
    vso_vsop87d_dyn_coordinates (2195870.0, SATURN, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 2.2948875823, .0178533697, 9.1857599537 },
               10, 0);

    /* VSOP87D  SATURN      JD2159345.0  19/12/1199 12h TDB */
    printf ("VSOP87D - SATURN on J2159345.0 - ");
    vso_vsop87d_dyn_coordinates (2159345.0, SATURN, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 5.8660241564, -.0333866503, 9.5927173940 },
               10, 0);

    /* VSOP87D  SATURN      JD2122820.0  19/12/1099 12h TDB */
    printf ("VSOP87D - SATURN on J2122820.0 - ");
    vso_vsop87d_dyn_coordinates (2122820.0, SATURN, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.5570108069, .0435371139, 9.8669939498 },
               10, 0);

    /* VSOP87D  URANUS      JD2451545.0  01/01/2000 12h TDB */
    printf ("VSOP87D - URANUS on J2451545.0 - ");
    vso_vsop87d_dyn_coordinates (2451545.0, URANUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 5.5225485803, -.0119527838,
               19.9240482667
               }, 10, 0);

    /* VSOP87D  URANUS      JD2415020.0  31/12/1899 12h TDB */
    printf ("VSOP87D - URANUS on J2415020.0 - ");
    vso_vsop87d_dyn_coordinates (2415020.0, URANUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.3397761173, .0011570307, 18.9927163620 },
               10, 0);

    /* VSOP87D  URANUS      JD2378495.0  30/12/1799 12h TDB */
    printf ("VSOP87D - URANUS on J2378495.0 - ");
    vso_vsop87d_dyn_coordinates (2378495.0, URANUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.0388348558, .0132392955, 18.2991154397 },
               10, 0);

    /* VSOP87D  URANUS      JD2341970.0  29/12/1699 12h TDB */
    printf ("VSOP87D - URANUS on J2341970.0 - ");
    vso_vsop87d_dyn_coordinates (2341970.0, URANUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.7242204720, .0059836565, 18.7966208854 },
               10, 0);

    /* VSOP87D  URANUS      JD2305445.0  29/12/1599 12h TDB */
    printf ("VSOP87D - URANUS on J2305445.0 - ");
    vso_vsop87d_dyn_coordinates (2305445.0, URANUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { .5223325214, -.0089983885, 19.7819882707 },
               10, 0);

    /* VSOP87D  URANUS      JD2268920.0  19/12/1499 12h TDB */
    printf ("VSOP87D - URANUS on J2268920.0 - ");
    vso_vsop87d_dyn_coordinates (2268920.0, URANUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 5.6817615582, -.0129257254,
               20.0300462993
               }, 10, 0);

    /* VSOP87D  URANUS      JD2232395.0  19/12/1399 12h TDB */
    printf ("VSOP87D - URANUS on J2232395.0 - ");
    vso_vsop87d_dyn_coordinates (2232395.0, URANUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.5254482963, -.0019303340,
               19.2694311058
               }, 10, 0);

    /* VSOP87D  URANUS      JD2195870.0  19/12/1299 12h TDB */
    printf ("VSOP87D - URANUS on J2195870.0 - ");
    vso_vsop87d_dyn_coordinates (2195870.0, URANUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.2557221720, .0120919639, 18.3948228639 },
               10, 0);

    /* VSOP87D  URANUS      JD2159345.0  19/12/1199 12h TDB */
    printf ("VSOP87D - URANUS on J2159345.0 - ");
    vso_vsop87d_dyn_coordinates (2159345.0, URANUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.9333853935, .0088045918, 18.5841501334 },
               10, 0);

    /* VSOP87D  URANUS      JD2122820.0  19/12/1099 12h TDB */
    printf ("VSOP87D - URANUS on J2122820.0 - ");
    vso_vsop87d_dyn_coordinates (2122820.0, URANUS, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { .7007226224, -.0065610611, 19.5612078271 },
               10, 0);

    /* VSOP87D  NEPTUNE     JD2451545.0  01/01/2000 12h TDB */
    printf ("VSOP87D - NEPTUNE on J2451545.0 - ");
    vso_vsop87d_dyn_coordinates (2451545.0, NEPTUNE, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 5.3045629252, .0042236789, 30.1205328392 },
               10, 0);

    /* VSOP87D  NEPTUNE     JD2415020.0  31/12/1899 12h TDB */
    printf ("VSOP87D - NEPTUNE on J2415020.0 - ");
    vso_vsop87d_dyn_coordinates (2415020.0, NEPTUNE, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.4956195225, -.0219610030,
               29.8710345051
               }, 10, 0);

    /* VSOP87D  NEPTUNE     JD2378495.0  30/12/1799 12h TDB */
    printf ("VSOP87D - NEPTUNE on J2378495.0 - ");
    vso_vsop87d_dyn_coordinates (2378495.0, NEPTUNE, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.9290537977, .0310692112, 30.3209192288 },
               10, 0);

    /* VSOP87D  NEPTUNE     JD2341970.0  29/12/1699 12h TDB */
    printf ("VSOP87D - NEPTUNE on J2341970.0 - ");
    vso_vsop87d_dyn_coordinates (2341970.0, NEPTUNE, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { .0815199679, -.0260752533, 29.8685860491 },
               10, 0);

    /* VSOP87D  NEPTUNE     JD2305445.0  29/12/1599 12h TDB */
    printf ("VSOP87D - NEPTUNE on J2305445.0 - ");
    vso_vsop87d_dyn_coordinates (2305445.0, NEPTUNE, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 2.5537079778, .0102374010, 30.1360158724 },
               10, 0);

    /* VSOP87D  NEPTUNE     JD2268920.0  19/12/1499 12h TDB */
    printf ("VSOP87D - NEPTUNE on J2268920.0 - ");
    vso_vsop87d_dyn_coordinates (2268920.0, NEPTUNE, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 4.9678695785, .0116907777, 30.1785350169 },
               10, 0);

    /* VSOP87D  NEPTUNE     JD2232395.0  19/12/1399 12h TDB */
    printf ("VSOP87D - NEPTUNE on J2232395.0 - ");
    vso_vsop87d_dyn_coordinates (2232395.0, NEPTUNE, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 1.1523661584, -.0273547725,
               29.8326055236
               }, 10, 0);

    /* VSOP87D  NEPTUNE     JD2195870.0  19/12/1299 12h TDB */
    printf ("VSOP87D - NEPTUNE on J2195870.0 - ");
    vso_vsop87d_dyn_coordinates (2195870.0, NEPTUNE, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 3.5930943433, .0316878975, 30.3109114960 },
               10, 0);

    /* VSOP87D  NEPTUNE     JD2159345.0  19/12/1199 12h TDB */
    printf ("VSOP87D - NEPTUNE on J2159345.0 - ");
    vso_vsop87d_dyn_coordinates (2159345.0, NEPTUNE, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 6.0203596580, -.0215169842,
               29.9065506848
               }, 10, 0);

    /* VSOP87D  NEPTUNE     JD2122820.0  19/12/1099 12h TDB */
    printf ("VSOP87D - NEPTUNE on J2122820.0 - ");
    vso_vsop87d_dyn_coordinates (2122820.0, NEPTUNE, coord);
    coord[0] = rerange (coord[0], 2 * M_PI);
    res_coord (coord, (double[]) { 2.2124988267, .0027498093, 30.0653693610 },
               10, 0);


    printf ("-----------------\nTEST STATUS: %s\n",
            success ? "PASS" : "FAIL");
    return 0;
}
