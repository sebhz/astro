#include <stdio.h>
#include <time.h>
#include <math.h>
#include "meeus.h"

double
sid_get_mean_gw_sid_time_0ut (double jd)
{
    double T = get_century_since_j2000 (jd);

    /* Meeus 12.2 - valid for 0h UT only - in seconds of time */
    return rerange (polynom ((const double[]) { hms_to_s (6, 41, 50.54841),
                             8640184.812866, 0.093104, -0.000062
                             }, T, 3), 86400);
    /* Meeus 12.3 - valid for 0h UT only - in degrees */
    /* return polynom((const double[]){100.46061837, 36000.770053608, 0.000387933, -1/38710000}, T, 3); */
}

double
sid_get_mean_gw_sid_time_anyut (double jd)
{
    double T = get_century_since_j2000 (jd);
    /* Meeus 12.4 - valid for any jd - in degrees */
    return rerange (280.46061837 + 360.98564736629 * (jd - 2451545.0) +
                    0.000387933 * T * T - 1 / 38710000 * T * T * T, 360);
}

/* Return mean sidereal time @Greenwich in seconds of time */
m_err_t
sid_get_mean_gw_sid_time (double jd, double *sid_t)
{
    if ((jd - (int) jd) == 0.5)
        *sid_t = sid_get_mean_gw_sid_time_0ut (jd);
    else
        *sid_t = deg_to_s (sid_get_mean_gw_sid_time_anyut (jd));
    return M_NO_ERR;
}

/* Return apparent sidereal time @Greenwich in seconds of time */
m_err_t
sid_get_apparent_gw_sid_time (double jd, double *sid_t)
{
    double mean_t, err, epsilon;
    double jde = jd_to_jde (jd);
    double delta_psi = ecl_nut_in_lon (jde, 1); /* nutation in longitude computed from JDE */

    err = sid_get_mean_gw_sid_time (jd, &mean_t);
    if (err)
        return err;
    err = ecl_true_obl_ecliptic (jde, &epsilon, 1);     /* nutation in obliquity computed from JDE */
    if (err)
        return err;

    /* delta_psi is in arcseconds, epsilon is in arcseconds, correction in seconds of time */
    double correction = delta_psi * cosd (epsilon / 3600) / 15;
    *sid_t = mean_t + correction;
    return M_NO_ERR;
}
