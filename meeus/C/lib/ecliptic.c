#include <stdio.h>
#include <time.h>
#include <math.h>
#include "meeus.h"

/*
  [Meeus-1998: table 22.A]

    D, M, M1, F, omega, psiK, psiT, epsK, epsT
*/
static double nut_tab[][9] = {
    {0, 0, 0, 0, 1, -171996, -174.2, 92025, 8.9},
    {-2, 0, 0, 2, 2, -13187, -1.6, 5736, -3.1},
    {0, 0, 0, 2, 2, -2274, -0.2, 977, -0.5},
    {0, 0, 0, 0, 2, 2062, 0.2, -895, 0.5},
    {0, 1, 0, 0, 0, 1426, -3.4, 54, -0.1},
    {0, 0, 1, 0, 0, 712, 0.1, -7, 0},
    {-2, 1, 0, 2, 2, -517, 1.2, 224, -0.6},
    {0, 0, 0, 2, 1, -386, -0.4, 200, 0},
    {0, 0, 1, 2, 2, -301, 0, 129, -0.1},
    {-2, -1, 0, 2, 2, 217, -0.5, -95, 0.3},
    {-2, 0, 1, 0, 0, -158, 0, 0, 0},
    {-2, 0, 0, 2, 1, 129, 0.1, -70, 0},
    {0, 0, -1, 2, 2, 123, 0, -53, 0},
    {2, 0, 0, 0, 0, 63, 0, 0, 0},
    {0, 0, 1, 0, 1, 63, 0.1, -33, 0},
    {2, 0, -1, 2, 2, -59, 0, 26, 0},
    {0, 0, -1, 0, 1, -58, -0.1, 32, 0},
    {0, 0, 1, 2, 1, -51, 0, 27, 0},
    {-2, 0, 2, 0, 0, 48, 0, 0, 0},
    {0, 0, -2, 2, 1, 46, 0, -24, 0},
    {2, 0, 0, 2, 2, -38, 0, 16, 0},
    {0, 0, 2, 2, 2, -31, 0, 13, 0},
    {0, 0, 2, 0, 0, 29, 0, 0, 0},
    {-2, 0, 1, 2, 2, 29, 0, -12, 0},
    {0, 0, 0, 2, 0, 26, 0, 0, 0},
    {-2, 0, 0, 2, 0, -22, 0, 0, 0},
    {0, 0, -1, 2, 1, 21, 0, -10, 0},
    {0, 2, 0, 0, 0, 17, -0.1, 0, 0},
    {2, 0, -1, 0, 1, 16, 0, -8, 0},
    {-2, 2, 0, 2, 2, -16, 0.1, 7, 0},
    {0, 1, 0, 0, 1, -15, 0, 9, 0},
    {-2, 0, 1, 0, 1, -13, 0, 7, 0},
    {0, -1, 0, 0, 1, -12, 0, 6, 0},
    {0, 0, 2, -2, 0, 11, 0, 0, 0},
    {2, 0, -1, 2, 1, -10, 0, 5, 0},
    {2, 0, 1, 2, 2, -8, 0, 3, 0},
    {0, 1, 0, 2, 2, 7, 0, -3, 0},
    {-2, 1, 1, 0, 0, -7, 0, 0, 0},
    {0, -1, 0, 2, 2, -7, 0, 3, 0},
    {2, 0, 0, 2, 1, -7, 0, 3, 0},
    {2, 0, 1, 0, 0, 6, 0, 0, 0},
    {-2, 0, 2, 2, 2, 6, 0, -3, 0},
    {-2, 0, 1, 2, 1, 6, 0, -3, 0},
    {2, 0, -2, 0, 1, -6, 0, 3, 0},
    {2, 0, 0, 0, 1, -6, 0, 3, 0},
    {0, -1, 1, 0, 0, 5, 0, 0, 0},
    {-2, -1, 0, 2, 1, -5, 0, 3, 0},
    {-2, 0, 0, 0, 1, -5, 0, 3, 0},
    {0, 0, 2, 2, 1, -5, 0, 3, 0},
    {-2, 0, 2, 0, 1, 4, 0, 0, 0},
    {-2, 1, 0, 2, 1, 4, 0, 0, 0},
    {0, 0, 1, -2, 0, 4, 0, 0, 0},
    {-1, 0, 1, 0, 0, -4, 0, 0, 0},
    {-2, 1, 0, 0, 0, -4, 0, 0, 0},
    {1, 0, 0, 0, 0, -4, 0, 0, 0},
    {0, 0, 1, 2, 0, 3, 0, 0, 0},
    {0, 0, -2, 2, 2, -3, 0, 0, 0},
    {-1, -1, 1, 0, 0, -3, 0, 0, 0},
    {0, 1, 1, 0, 0, -3, 0, 0, 0},
    {0, -1, 1, 2, 2, -3, 0, 0, 0},
    {2, -1, -1, 2, 2, -3, 0, 0, 0},
    {0, 0, 3, 2, 2, -3, 0, 0, 0},
    {2, -1, 0, 2, 2, -3, 0, 0, 0}
};

void
nut_get_params (double T, double *parm)
{
    /* D - mean elongation of the Moon from the Sun */
    *(parm) = polynom ((const double[]) { 297.85036, 445267.11148, -0.0019142,
                       1.0 / 189474
                       }, T, 3);
    /* M - mean anomaly of the Sun from the Earth */
    *(parm + 1) = polynom ((const double[]) { 357.52772, 35999.05034,
                           -0.0001603, -1.0 / 300000
                           }, T, 3);
    /* M' - mean anomaly of the Moon */
    *(parm + 2) =
        polynom ((const double[]) { 134.96298, 477198.867398, 0.0086972,
                 1.0 / 56250
                 }, T, 3);
    /* F - Moon's argument of latitude */
    *(parm + 3) =
        polynom ((const double[]) { 93.27191, 483202.017538, -0.0036825,
                 1.0 / 327270
                 }, T, 3);
    /* Omega - Longitude of the Moon's ascending node mean orbit on the 
       ecliptic. Measured from the mean equinox of the date */
    *(parm + 4) =
        polynom ((const double[]) { 125.04452, -1934.136261, +0.0020708,
                 1.0 / 450000
                 }, T, 3);
}

/* Return nutation in longitude, expressed in arcseconds */
double
ecl_nut_in_lon (double jde, int high_accuracy)
{
    double T = get_century_since_j2000 (jde);
    double parm[5];
    double mult, arg;
    double nut = 0.0;

    nut_get_params (T, parm);
    if (high_accuracy) {        /* precise down to 0.001 arcsecond */
        for (int i = 0; i < (sizeof nut_tab) / (sizeof *nut_tab); i++) {
            double *coefs = nut_tab[i];
            arg = 0;
            for (int j = 0; j < (sizeof parm) / (sizeof *parm); j++) {
                arg += parm[j] * coefs[j];
            }
            mult = coefs[5] + coefs[6] * T;
            nut += mult * sind (arg);
        }
        return nut / 10000;
    }

    /* Mean longitude of the Sun */
    double L = 280.4665 + 36000.7698 * T;
    /* Mean longitude of the Moon */
    double Lprime = 218.3165 + 481267.8813 * T;
    /* Accurate to 0.5 arcsecond */
    return -17.20 * sind (parm[4]) - 1.32 * sind (2 * L) -
        0.23 * sind (2 * Lprime) + 0.21 * sind (2 * parm[4]);
}

/* Return nutation in obliquity, expressed in arcseconds */
double
ecl_nut_in_obl (double jde, int high_accuracy)
{
    double T = get_century_since_j2000 (jde);
    double parm[5];
    double mult, arg;
    double nut = 0.0;

    nut_get_params (T, parm);
    if (high_accuracy) {        /* Accurate to 0.001 arcseconds */
        for (int i = 0; i < (sizeof nut_tab) / (sizeof *nut_tab); i++) {
            double *coefs = nut_tab[i];
            arg = 0;
            for (int j = 0; j < (sizeof parm) / (sizeof *parm); j++) {
                arg += parm[j] * coefs[j];
            }
            mult = coefs[7] + coefs[8] * T;
            nut += mult * cosd (arg);
        }
        return nut / 10000;
    }
    /* Mean longitude of the Sun */
    double L = 280.4665 + 36000.7698 * T;
    /* Mean longitude of the Moon */
    double Lprime = 218.3165 + 481267.8813 * T;
    /* Accurate to 0.1 arcsecond */
    return 9.20 * cosd (parm[4]) + 0.57 * cosd (2 * L) +
        0.10 * cosd (2 * Lprime) - 0.09 * cosd (2 * parm[4]);
}

/* Return the mean obliquity of the ecliptic in arcseconds */
m_err_t
ecl_mean_obl_ecliptic (double jde, double *obl, int high_accuracy)
{
    double T = get_century_since_j2000 (jde);

    if (high_accuracy) {
        if (fabs (T) > 100)
            return M_INVALID_RANGE_ERR;
        /* Laskar formula - precise down to about 0.01 arcs between 1000AD and 3000AD */
        *obl = polynom ((const double[]) { 84381.448, -4680.93, -1.55,
                        1999.25, -51.38, -249.67, -39.05, 7.12, 27.87, 5.79,
                        2.45
                        }, T / 100, 10);
    }
    /* Precise down to about one second over 2000 years */
    *obl = polynom ((const double[]) { 84381.448, -46.8150, -0.00059,
                    0.001813
                    }, T, 3);
    return M_NO_ERR;
}

/* Return the true obliquity of the ecliptic in arcseconds */
m_err_t
ecl_true_obl_ecliptic (double jde, double *obl, int high_accuracy)
{
    m_err_t err = ecl_mean_obl_ecliptic (jde, obl, high_accuracy);
    if (err)
        return err;
    *obl += ecl_nut_in_obl (jde, high_accuracy);
    return M_NO_ERR;
}
