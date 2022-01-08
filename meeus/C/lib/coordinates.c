#include <stdio.h>
#include <math.h>
#include <time.h>
#include "meeus.h"

/* alpha - right ascension
   delta - decllination
   lambda - ecliptical (celestial) longitude - measured from the vernal equinox
   beta - ecliptical (celestical) latitude - positive towards north
   A - azimuth - measured westward from the south
   h - altitude - positive above the horizon
   epsilon - obliquity of the ecliptic
   H - local hour angle - measured westward from south
   phi - observer latitude
   L - observer longitude

   all quantities in degrees (except H).
*/
void
coo_equ_to_ecl (double alpha, double delta, double epsilon, double *lambda,
                double *beta)
{
    *lambda =
        rad_to_deg (atan2
                    (sind (alpha) * cosd (epsilon) +
                     tand (delta) * sind (epsilon), cosd (alpha)));
    *beta =
        rad_to_deg (asin
                    (sind (delta) * cosd (epsilon) -
                     cosd (delta) * sind (epsilon) * sind (alpha)));
}

void
coo_ecl_to_equ (double lambda, double beta, double epsilon, double *alpha,
                double *delta)
{
    *alpha =
        rad_to_deg (atan2
                    (sind (lambda) * cosd (epsilon) -
                     tand (beta) * sind (epsilon), cosd (lambda)));
    *delta =
        rad_to_deg (asin
                    (sind (beta) * cosd (epsilon) +
                     cosd (beta) * sind (epsilon) * sind (lambda)));
}

void
coo_ecl_to_hor (double H, double delta, double phi, double *A, double *h)
{
    *A = rad_to_deg (atan2
                     (sind (H),
                      cosd (H) * sind (phi) - tand (delta) * cosd (phi)));
    *h = rad_to_deg (asin
                     (sind (phi) * sind (delta) +
                      cosd (phi) * cosd (delta) * cosd (H)));
}

void
coo_hor_to_ecl (double A, double h, double phi, double *H, double *delta)
{
    *H = rad_to_deg (atan2
                     (sind (A),
                      cosd (A) * sind (phi) + tand (h) * cosd (phi)));
    *delta = rad_to_deg (asin
                         (sind (phi) * sind (h) -
                          cosd (phi) * cosd (h) * cosd (A)));
}

/* Return local hour angle of body at right ascension alpha,
   at observer longitude L, in degrees.
   If alpha is apparent (affected by nutation) is_apparent parameter must be set */
m_err_t
coo_get_local_hour_angle (double jd, double L, double alpha,
                          double *hour_angle, int is_apparent)
{
    double sid_t, err;
    if (is_apparent) {
        err = sid_get_apparent_gw_sid_time (jd, &sid_t);
        if (err)
            return err;
        *hour_angle = rerange (s_to_deg (sid_t) - L - alpha, 360);
    }
    else {
        err = sid_get_mean_gw_sid_time (jd, &sid_t);
        if (err)
            return err;
        *hour_angle = rerange (s_to_deg (sid_t) - L - alpha, 360);
    }
    return M_NO_ERR;
}
