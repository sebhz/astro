/**
 * @file kepler.c
 * Meeus chapter 30. Kepler's equation
 */
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "meeus.h"

/**
 * @brief Solves Kepler's equation
 *
 * Implements Sinnott's algorithm
 *
 * @param[in] M mean anomaly expressed in degrees
 * @param[in] e eccentricity of orbit
 *
 * @return eccentric anomaly expressed in degrees
 */
double
kep_get_eccentric_anomaly (double M, double e)
{
    double Mp = deg_to_rad (rerange (M, 360.0)), M1;
    int F = 1;

    if (Mp > M_PI) {
        F = -1;
        Mp = 2 * M_PI - Mp;
    }
    double E0 = M_PI / 2;
    double D = M_PI / 4;
    for (int j = 0; j <= 3.32 * 12; j++) {
        M1 = E0 - e * sin (E0);
        E0 = E0 + copysign (D, Mp - M1);
        D /= 2;
    }
    return rad_to_deg (E0 * F);
}
