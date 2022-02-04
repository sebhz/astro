/** @file sidereal.c
  * Meeus chapter 12. Sidereal time.
  */
#include <stdio.h>
#include <time.h>
#include <math.h>
#include "meeus.h"

/**
 * @brief  Get mean sidereal time at Greenwich
 *
 * Returns mean sidereal time at Greenwich for JD corresponding to 0h UT.
 * (e.g. JD decimal part must be 0.5).
 *
 * Implements Meeus formulas 12.2 and 12.3.
 *
 * @param[in] jd Julian day (Universal Time). Must end by .5.
 * @param[out] sid_t sidereal time at Greenwich for JD.
 *
 * @return Error status if the function
 * @retval M_INVALID_RANGE_ERR JD decimal part is not 0.5
 * @retval M_NO_ERR function ran properly
 */
static m_err_t
sid_get_mean_gw_sid_time_0ut (double jd, double *sid_t)
{
    double T = get_century_since_j2000 (jd);

    if ((jd - (int) jd) != 0.5)
        return M_INVALID_RANGE_ERR;

    /* Meeus 12.2 - valid for 0h UT only - in seconds of time */
    *sid_t = rerange (polynom ((const double[]) { hms_to_s (6, 41, 50.54841),
                               8640184.812866, 0.093104, -0.000062
                               }, T, 3), 86400);
    /* Meeus 12.3 - valid for 0h UT only - in degrees */
    /* *sid_t = polynom((const double[]){100.46061837, 36000.770053608, 0.000387933, -1/38710000}, T, 3); */
    return M_NO_ERR;
}

/**
 * @brief  Get mean sidereal time at Greenwich
 *
 * Returns mean sidereal time at Greenwich for any JD
 *
 * Implements Meeus formula 12.4.
 *
 * @param[in] jd Julian day (Universal Time).
 * @param[out] sid_t sidereal time at Greenwich for JD.
 *
 * @return Error status if the function
 * @retval M_ERR_OK function ran properly
 */
static m_err_t
sid_get_mean_gw_sid_time_anyut (double jd, double *sid_t)
{
    double T = get_century_since_j2000 (jd);
    /* Meeus 12.4 - valid for any jd - in degrees */
    double mst = rerange (280.46061837 + 360.98564736629 * (jd - 2451545.0) +
                          0.000387933 * T * T - 1 / 38710000 * T * T * T,
                          360);
    *sid_t = deg_to_s (mst);
    return M_NO_ERR;
}

/**
 * @brief  Get mean sidereal time at Greenwich
 *
 * Returns mean sidereal time at Greenwich for any JD
 *
 * @param[in] jd Julian day (Universal Time).
 * @param[out] sid_t sidereal time at Greenwich for JD.
 *
 * @return Error status if the function
 * @retval M_ERR_OK function ran properly
 */
m_err_t
sid_get_mean_gw_sid_time (double jd, double *sid_t)
{
    if ((jd - (int) jd) == 0.5)
        return sid_get_mean_gw_sid_time_0ut (jd, sid_t);
    else
        return sid_get_mean_gw_sid_time_anyut (jd, sid_t);
}

/**
 * @brief  Get apparent sidereal time at Greenwich
 *
 * Returns apparent sidereal time at Greenwich for any JD
 *
 * Apparent sidereal time is mean sidereal time corrected for
 * nutation (equation of the equinoxes).
 *
 * @param[in] jd Julian day (Universal Time).
 * @param[out] sid_t sidereal time at Greenwich for JD.
 *
 * @return Error status if the function
 * @retval M_ERR_OK function ran properly
 *
 * @see m_err_t ecl_true_obl_ecliptic (double jde, double *obl, int high_accuracy);
 */
m_err_t
sid_get_apparent_gw_sid_time (double jd, double *sid_t)
{
    double mean_t, err, epsilon;
    double jde = jd_to_jde (jd);        /* The difference between JD and JDE is probably insignificant here, but still... */
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
