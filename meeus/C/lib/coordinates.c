/**
 * @file coordinates.c
 * Meeus chapter 13. Transformation of coordinate.
 */
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "meeus.h"

/* alpha - right ascension
   delta - declination
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

/**
 * @brief   Convert equatorial to ecliptical coordinates
 *
 * Implements Meeus formulas 13.1 and 13.2.
 *
 * @param[in] alpha body right ascension
 * @param[in] delta body declination
 * @param[in] epsilon obliquity of the ecliptic
 *
 * @param[out] lambda ecliptical longitude, measured from the vernal equinox. Positive.
 * @param[out] beta ecliptical latitude, positive towards the ecliptical north pole.
 *
 * All parameters are in degrees. Returned values are in degrees
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

/**
 * @brief   Convert ecliptical to equatorial coordinates
 *
 * Implements Meeus formulas 13.3 and 13.4.
 *
 * @param[in] lambda ecliptical longitude, measured from the vernal equinox. Positive.
 * @param[in] beta ecliptical latitude, positive towards the ecliptical north pole.
 * @param[in] epsilon obliquity of the ecliptic
 *
 * @param[out] alpha body right ascension
 * @param[out] delta body declination
 *
 * All parameters are in degrees. Returned values are in degrees
 */

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

/**
 * @brief   Convert equatorial to horizontal coordinates
 *
 * Implements Meeus formulas 13.5 and 13.6.
 *
 * @param[in] H local hour angle of the body, measured westward from south
 * @param[in] delta body declination
 * @param[in] phi observer latitude (*negative* toward east).
 *
 * @param[out] A azimuth
 * @param[out] h altitude of the body
 *
 * All parameters are in degrees. Returned values are in degrees
 */

void
coo_equ_to_hor (double H, double delta, double phi, double *A, double *h)
{
    *A = rad_to_deg (atan2
                     (sind (H),
                      cosd (H) * sind (phi) - tand (delta) * cosd (phi)));
    *h = rad_to_deg (asin
                     (sind (phi) * sind (delta) +
                      cosd (phi) * cosd (delta) * cosd (H)));
}

/**
 * @brief   Convert horizontal to equatorial coordinates
 *
 * @param[in] A azimuth
 * @param[in] h altitude of the body
 * @param[in] phi observer latitude (*negative* toward east).
 *
 * @param[out] H local hour angle of the body
 * @param[out] delta body declination
 *
 *
 * All parameters are in degrees. Returned values are in degrees
 */

void
coo_hor_to_equ (double A, double h, double phi, double *H, double *delta)
{
    *H = rad_to_deg (atan2
                     (sind (A),
                      cosd (A) * sind (phi) + tand (h) * cosd (phi)));
    *delta = rad_to_deg (asin
                         (sind (phi) * sind (h) -
                          cosd (phi) * cosd (h) * cosd (A)));
}

/**
 * @brief   Return local hour angle of a body
 *
 * Returns the local hour angle of a body from its right ascension and
 * the observer longitude.
 *
 * @param[in] jd the dynamic (UT) julian day of the observation
 * @param[in] L longitude of the observer, negative towards east
 * @param[in] alpha body right ascension
 * @param[in] is_apparent set this parameter to 1 if alpha is apparent (e.g. affected by nutation)
 *
 * @param[out] hour_angle local hour angle of the body, measured westward from south
 *
 * @return return error code
 * @retval M_NO_ERR The function was successfully executed
 *
 * All angle parameters are in degrees. Returned values are in degrees
 */
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
