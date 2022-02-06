/**
 * @file sun.c
 * Meeus chapter 25. Geocentric coordinates of the Sun.
 */
#include <stdio.h>
#include <math.h>
#include "time.h"
#include "meeus.h"

static double aberration_coef_0[][3] = {
    {118.568, 87.5287, 359993.7286},
    {2.476, 85.0561, 719987.4571},
    {1.376, 27.8502, 4452671.1152},
    {0.119, 73.1375, 450368.8564},
    {0.114, 337.2264, 329644.6718},
    {0.086, 222.54, 659289.3436},
    {0.078, 162.8136, 9224659.7915},
    {0.054, 82.5823, 1079981.1857},
    {0.052, 171.5189, 225184.4282},
    {0.034, 30.3214, 4092677.3866},
    {0.033, 119.8105, 337181.4711},
    {0.023, 247.5418, 299295.6151},
    {0.023, 325.1526, 315559.556},
    {0.021, 155.1241, 675553.2846}
};

static double aberration_coef_1[][3] = {
    {7.311, 333.4515, 359993.7286},
    {0.305, 330.9814, 719987.4571},
    {0.01, 328.5170, 1079981.1857}
};

static double aberration_coef_2[][3] = {
    {0.309, 241.4518, 359993.7286},
    {0.021, 205.0482, 719987.4571},
    {0.004, 297.861, 4452671.1152}
};

static double aberration_coef_3[][3] = {
    {0.01, 154.7066, 359993.7286}
};

/**
 * @brief Helper function to retrieve the necessary parameters
 *               for Sun calculation
 *
 * @param[in] jde Julian Day Ephemeris (Dynamical time)
 * @param[out] O sun true longitude in degrees
 * @param[out] nu sun true anomaly in degrees
 * @param[out] R sun radius vector in AU
 */
static void
sun_get_param (double jde, double *O, double *nu, double *R)
{
    double T = get_century_since_j2000 (jde);

    /* Geometric mean longitude of the sun - referred to the mean equinox
       of the day */
    double L0 =
        polynom ((double[]) { 280.46646, 36000.76983, 0.0003032 }, T, 2);
    /* Mean anomaly of the sun */
    double M =
        polynom ((double[]) { 357.52911, 35999.05029, -0.0001537 }, T, 2);
    /* Eccentricity of the Earth orbit */
    double e =
        polynom ((double[]) { 0.016708634, -0.000042037, -0.0000001267 }, T,
                 2);
    /* Center of the sun */
    double C = polynom ((double[]) { 1.914602, -0.004817, -0.000014 }, T,
                        2) * sind (M) + (0.019993 -
                                         0.000101 * T) * sind (2 * M) +
        0.000289 * sind (3 * M);
    /* Sun true longitude */
    *O = L0 + C;
    /* Sun true anomaly */
    *nu = M + C;
    /* Sun radius vector */
    *R = (1.000001018 * (1 - e * e)) / (1 + e * cosd (*nu));
}

/**
 * @brief Get sun aberration correction
 *
 * Implements Meeus formulas 25.10 and 25.11.
 *
 * @param[in] jde Julian Day Ephemeris (Dynamical time)
 * @param[in] R Sun radius vector in AU
 * @param[in] accuracy If M_HIGH_ACC, use high accuracy method. If M_LOW_ACC, use low accuracy method
 *
 * @return aberration correction in arcseconds.
 */
static double
sun_get_aberration_correction (double jde, double R, m_acc_t accuracy)
{
    double tau = get_century_since_j2000 (jde) / 10;
    double deltaLambda = 3548.193;

    if (accuracy == M_LOW_ACC) {       /* Meeus 25.10 */
        return -20.4898 / R;
    }

    /* Meeus 25.11 */
    for (int i = 0;
         i < (sizeof aberration_coef_0) / (sizeof aberration_coef_0[0]);
         i++) {
        double *coef = aberration_coef_0[i];
        deltaLambda += coef[0] * sind (coef[1] + coef[2] * tau);
    }
    for (int i = 0;
         i < (sizeof aberration_coef_1) / (sizeof aberration_coef_1[0]);
         i++) {
        double *coef = aberration_coef_1[i];
        deltaLambda += coef[0] * tau * sind (coef[1] + coef[2] * tau);
    }
    for (int i = 0;
         i < (sizeof aberration_coef_2) / (sizeof aberration_coef_2[0]);
         i++) {
        double *coef = aberration_coef_2[i];
        deltaLambda += coef[0] * tau * tau * sind (coef[1] + coef[2] * tau);
    }
    for (int i = 0;
         i < (sizeof aberration_coef_3) / (sizeof aberration_coef_3[0]);
         i++) {
        double *coef = aberration_coef_3[i];
        deltaLambda +=
            coef[0] * tau * tau * tau * sind (coef[1] + coef[2] * tau);
    }
    return -0.005775518 * R * deltaLambda;
}

/**
 * @brief Get sun mean ecliptic geocentric coordinates
 *
 * This uses the high accuracy method, with VSOP87. Coordinates are returned in the FK5 reference.
 *
 * @param[in] jde Julian Day Ephemeris (Dynamical time)
 * @param[out] lambda Sun ecliptic longitude in degrees
 * @param[out] beta Sun ecliptic latitude in degrees
 * @param[out] R Sun radius vector in AU
 *
 */
void
sun_mean_ecliptic_coord (double jde, double *lambda, double *beta, double *R)
{
    double coord[3];

    vso_vsop87d_coordinates (jde, EARTH, coord);
    *lambda = rerange (coord[0] + 180, 360.0);
    *beta = -coord[1];
    *R = coord[2];
#if 0
    /* Meeus 25.9. Correction for Dynamical to FK5 reference.
       Not required since the correction is already applied in vso_vsop87d_coordinates() */
    double T = get_century_since_j2000 (jde);
    double lambdaprime = *lambda - 1.397 * T - 0.00031 * T * T;
    *lambda -= 0.09033 / 3600.0;
    *beta += 0.03916 * (cosd (lambdaprime) - sind (lambdaprime)) / 3600.0;
#endif
}

/**
 * @brief Get sun apparent ecliptic geocentric coordinates
 *
 * This uses the high accuracy method, with VSOP87. Coordinates are returned in the FK5 reference.
 *
 * @param[in] jde Julian Day Ephemeris (Dynamical time)
 * @param[out] lambda Sun ecliptic longitude in degrees
 * @param[out] beta Sun ecliptic latitude in degrees
 * @param[out] R Sun radius vector in AU
 *
 */
void
sun_apparent_ecliptic_coord (double jde, double *lambda, double *beta,
                             double *R)
{
    double correction;
    sun_mean_ecliptic_coord (jde, lambda, beta, R);
    /* Correct for nutation */
    correction = ecl_nut_in_lon (jde, 1);
    /* Correct for aberration */
    correction += sun_get_aberration_correction (jde, *R, 1);

    *lambda += correction / 3600.0;
}

/**
 * @brief Get Sun mean equatorial coordinates
 *
 * @param[in] jde Julian Day Ephemeris (Dynamical time)
 * @param[out] alpha Sun right ascension in degrees
 * @param[out] delta Sun declination in degrees
 * @param[in] accuracy If M_HIGH_ACC, use high accuracy method. If M_LOW_ACC, use low accuracy method
 *
 * @return status of the function
 * @retval M_INVALID_RANGE_ERR jde is negative
 * @retval M_NO_ERR function completed successfully
 */
m_err_t
sun_mean_equatorial_coord (double jde, double *alpha, double *delta,
                           m_acc_t accuracy)
{
    double O, nu, R, epsilon;
    m_err_t err;

    err = ecl_mean_obl_ecliptic (jde, &epsilon, 1);
    if (err)
        return err;
    epsilon = arcsec_to_deg (epsilon);
    if (accuracy == M_LOW_ACC) {
        sun_get_param (jde, &O, &nu, &R);
        *alpha =
            rerange (rad_to_deg (atan2 (cosd (epsilon) * sind (O), cosd (O))),
                     360);
        *delta = rad_to_deg (asin (sind (epsilon) * sind (O)));
        return M_NO_ERR;
    }
    double lambda, beta;
    sun_mean_ecliptic_coord (jde, &lambda, &beta, &R);
    /* Then convert to equatorial coordinates */
    coo_ecl_to_equ (lambda, beta, epsilon, alpha, delta);
    return M_NO_ERR;
}

/**
 * @brief Get Sun apparent equatorial coordinates
 *
 * This uses the high accuracy method, with VSOP87. Coordinates are returned in the FK5 reference.
 *
 * @param[in] jde Julian Day Ephemeris (Dynamical time)
 * @param[out] alpha Sun right ascension in degrees
 * @param[out] delta Sun declination in degrees
 * @param[in] accuracy If M_HIGH_ACC, use high accuracy method. If M_LOW_ACC, use low accuracy method
 *
 * @return status of the function
 * @retval M_INVALID_RANGE_ERR jde is negative
 * @retval M_NO_ERR function completed successfully
 */
m_err_t
sun_apparent_equatorial_coord (double jde, double *alpha, double *delta,
                               m_acc_t accuracy)
{
    double O, nu, R, epsilon, T, omega, lambda, beta;
    m_err_t err;

    err = ecl_mean_obl_ecliptic (jde, &epsilon, 1);
    if (err)
        return err;
    epsilon = arcsec_to_deg (epsilon);

    if (accuracy == M_LOW_ACC) {
        sun_get_param (jde, &O, &nu, &R);
        T = get_century_since_j2000 (jde);
        omega = 125.04 - 1934.136 * T;
        lambda = O - 0.00569 - 0.00478 * sind (omega);

        epsilon += 0.00256 * cosd (omega);

        *alpha =
            rerange (rad_to_deg
                     (atan2 (cosd (epsilon) * sind (lambda), cosd (lambda))),
                     360);
        *delta = rad_to_deg (asin (sind (epsilon) * sind (lambda)));
        return M_NO_ERR;
    }

    sun_apparent_ecliptic_coord (jde, &lambda, &beta, &R);
    coo_ecl_to_equ (lambda, beta, epsilon, alpha, delta);
    *alpha = rerange (*alpha, 360.0);
    return M_NO_ERR;
}
