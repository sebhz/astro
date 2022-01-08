#include <stdio.h>
#include <math.h>
#include <time.h>
#include "meeus.h"
#include "vsop87.h"

/* Base implementation of the procedure described in the 
   VSOP87 readme and Meeus book.
   Results are returned in radians, referred to the mean
   dynamical ecliptic and equinox */
void
vso_vsop87d_dyn_coordinates (double jde, enum planet_e planet, double *coord)
{
    struct vsop_planetary_components *vsop =
        vsop87d_planetary_components[planet];
    double tau = get_century_since_j2000 (jde) / 10;
    double tmp_c;
    double power_tau;
    int term_start = 0, term_index = 0;

    for (int c = 0; c < 3; c++) {       /* For each coordinate */
        coord[c] = 0;
        power_tau = 1.0;
        for (int serie = 0; serie < vsop->num_series[c]; serie++) {     /* For each serie for by coordinate */
            tmp_c = 0;
            for (term_index = 0; term_index < vsop->terms_per_series[c][serie]; term_index++) { /* For each triplet in the serie */
                double *term = vsop->coefs + ((term_start + term_index) * 3);
                tmp_c += term[0] * cos (term[1] + term[2] * tau);
            }
            term_start += vsop->terms_per_series[c][serie];
            coord[c] += tmp_c * power_tau;
            power_tau *= tau;
        }
    }
}

/* Corrected implementation described in Meeus 32.3.
   Results are returned in degrees and referred to the
   FK5 system */
void
vso_vsop87d_coordinates (double jde, enum planet_e planet, double *coord)
{
    vso_vsop87d_dyn_coordinates (jde, planet, coord);

    double L = rad_to_deg (coord[0]);
    double B = rad_to_deg (coord[1]);

    /* Need to correct coordinate to put it in FK5 system */
    double T = get_century_since_j2000 (jde);
    /* Lprime in degrees */
    double Lprime = L - 1.397 * T - 0.00031 * T * T;

    /* Meeus 32.3 */
    coord[0] =
        rerange (L +
                 arcsec_to_deg (-0.09033 +
                                0.03916 * (cosd (Lprime) +
                                           sind (Lprime)) * tan (coord[1])),
                 360.0);
    coord[1] = B + arcsec_to_deg (0.03916 * (cosd (Lprime) - sind (Lprime)));
}
