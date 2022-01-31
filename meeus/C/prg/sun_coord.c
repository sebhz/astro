#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "meeus.h"

void
get_sun_coord (double phi, double L)
{
    double jd, jde, H;
    double alpha, delta, A, h;

    dt_get_current_jd (0, &jd);
    jde = dy_ut_to_dt (jd);
    /* Get sun apparent coordinates. Low accuracy is more than enough */
    sun_apparent_geocentric_coord (jde, &alpha, &delta, 0);

    /* We now have the sun geocentric coordinates.
       Let's convert them to horizontal coordinates
       at the observer's latitude and longitude */
    coo_get_local_hour_angle (jd, L, alpha, &H, 1);
    coo_equ_to_hor (H, delta, phi, &A, &h);
    /* and correct altitude for the atmospheric refraction
       as we want to get the "measured" coordinates */
    h += ref_refraction_true_to_apparent (h, 1) / 60;
    printf ("α=%.2f, γ=%.2f\n", h, A);
}

int
main (int argc, char **argv)
{
    if (argc != 3) {
        fprintf (stderr, "Usage: %s latitude longitude\n", argv[0]);
        fprintf (stderr,
                 "latitude and longitude in degrees. Latitude positive towards east (contrary to the usage)\n");
        return -1;
    }
    get_sun_coord (strtod (argv[1], NULL), strtod (argv[2], NULL));
}
