/**
 * @file equinox.c
 * Meeus chapter 27. Equinoxes and solstices.
 */
#include <stdio.h>
#include <time.h>
#include <math.h>
#include "meeus.h"

/**
 * @brief Meeus table 27.c
 */
static double eqx_coef[][3] = {
    {485, 324.96, 1934.136},
    {203, 337.23, 32964.467},
    {199, 342.08, 20.186},
    {182, 27.85, 445267.112},
    {156, 73.14, 45036.886},
    {136, 171.52, 22518.443},
    {77, 222.54, 65928.934},
    {74, 296.72, 3034.906},
    {70, 243.58, 9037.513},
    {58, 119.81, 33718.147},
    {52, 297.17, 150.678},
    {50, 21.02, 2281.226},
    {45, 247.54, 29929.562},
    {44, 325.15, 31555.956},
    {29, 60.93, 4443.417},
    {18, 155.12, 67555.328},
    {17, 288.79, 4562.452},
    {16, 198.04, 62894.029},
    {14, 199.76, 31436.921},
    {12, 95.39, 14577.848},
    {12, 287.11, 31931.756},
    {12, 320.81, 34777.259},
    {9, 227.73, 1222.114},
    {8, 15.45, 16859.074}
};

/**
 * @brief Return mean equinoxes and solstices for a given year
 *
 * @param[inout] eqx structure containing year as well as equinox and solstices
 */
static void
eqx_get_mean_sol_eqx (struct eqx_s *eqx)
{
    double Y;
    if (eqx->year < 1000) {
        Y = ((double) eqx->year) / 1000.0;
        eqx->mar_eqx =
            polynom ((double[]) { 1721139.29189, 365242.13740, 0.06134,
                     0.00111, -0.00071
                     }, Y, 4);
        eqx->jun_sol =
            polynom ((double[]) { 1721233.25301, 365241.72562, -0.05323,
                     0.00907, 0.00025
                     }, Y, 4);
        eqx->sep_eqx =
            polynom ((double[]) { 1721325.70455, 365242.49558, -0.11677,
                     -0.00297, 0.00074
                     }, Y, 4);
        eqx->dec_sol =
            polynom ((double[]) { 1721414.39987, 365252.88257, -0.00769,
                     -0.00933, -0.00006
                     }, Y, 4);
        return;
    }
    Y = (double) (eqx->year - 2000.0) / 1000.0;
    eqx->mar_eqx =
        polynom ((double[]) { 2451623.80984, 365242.37404, 0.05169, -0.00411,
                 -0.00057
                 }, Y, 4);
    eqx->jun_sol =
        polynom ((double[]) { 2451716.56767, 365241.62603, 0.00325, 0.00888,
                 -0.0003
                 }, Y, 4);
    eqx->sep_eqx =
        polynom ((double[]) { 2451810.21715, 365242.01767, -0.11575, 0.00337,
                 0.00078
                 }, Y, 4);
    eqx->dec_sol =
        polynom ((double[]) { 2451900.05952, 365242.74049, -0.06223, -0.00823,
                 0.00032
                 }, Y, 4);
}

/**
 * @brief Return corrected jde from a mean equinox or solstice jde
 *
 * This is a low accuracy correction
 *
 * @param[in] jde0 mean jde of equinox or solstice
 * @return corrected jde
 */
static double
eqx_correct_equinox (double jde0)
{
    double T = get_century_since_j2000 (jde0);
    double W = 35999.373 * T - 2.47;
    double deltaLambda = 1 + 0.0334 * cosd (W) + 0.0007 * cosd (2 * W);
    double S = 0;

    for (int i = 0; i < (sizeof eqx_coef) / (sizeof *eqx_coef); i++) {
        double *C = eqx_coef[i];
        S += C[0] * cosd (C[1] + C[2] * T);
    }
    return jde0 + 0.00001 * S / deltaLambda;
}

/**
 * @brief Return corrected jde from a mean equinox or solstice jde
 *
 * This is a high accuracy correction
 *
 * @param[in] jde0 mean jde of equinox or solstice
 * @param[in] k O for March equinox, 1 for Jun solstice, 2 for September Equinox, 3 for December solstice
 * @return corrected jde
 */
static double
eqx_iterate_equinox (double jde0, int k)
{
    double lambda = 0, beta, R;
    double jde_i = jde0;
    double correction;

    /* TODO: implement a timeout */
    /* We loop until we have a 0.5 seconds precision */
    do {
        sun_apparent_ecliptic_coord (jde_i, &lambda, &beta, &R);
        correction = 58 * sind (k * 90 - lambda);
        jde_i += correction;
    } while (correction > 1.0 / DT_SECS_PER_DAY / 2);

    return jde_i;
}

/**
 * @brief Compute equinoxes and solstice for a given year
 *
 * @param[inout] eqx structure containing year as well as equinox and solstices
 * @param[in] high_accuracy If 1 use high accuracy method. Else use low accuracy
 */
void
eqx_get_sol_eqx (struct eqx_s *eqx, int high_accuracy)
{
    eqx_get_mean_sol_eqx (eqx);

    if (!high_accuracy) {
        eqx->mar_eqx = eqx_correct_equinox (eqx->mar_eqx);
        eqx->jun_sol = eqx_correct_equinox (eqx->jun_sol);
        eqx->sep_eqx = eqx_correct_equinox (eqx->sep_eqx);
        eqx->dec_sol = eqx_correct_equinox (eqx->dec_sol);
    }
    else {
        eqx->mar_eqx = eqx_iterate_equinox (eqx->mar_eqx, 0);
        eqx->jun_sol = eqx_iterate_equinox (eqx->jun_sol, 1);
        eqx->sep_eqx = eqx_iterate_equinox (eqx->sep_eqx, 2);
        eqx->dec_sol = eqx_iterate_equinox (eqx->dec_sol, 3);
    }
}
