/**
 * @file refraction.c
 * Meeus chapter 16. Atmospheric refraction.
 */
#include <stdio.h>
#include <time.h>
#include <math.h>
#include "meeus.h"

/**
 * @brief refraction from airless
 *
 * Get the refraction to be added to the true (=airless, calculated)
 * altitude of a celestial body, to get its apparent altitude.
 *
 * Implements Meeus formula 16.4.
 *
 * @param[in] h true altitude in degrees
 * @param[in] corrected if 1, correct refraction to be exactly 0 at zenith.
 *
 * @return refraction in minutes of arc.
 */
double
ref_refraction_true_to_apparent (double h, int corrected)
{
    /* Meeus 16.4 */
    double R = 1.02 / (tand (h + 10.3 / (h + 5.11)));
    if (corrected)              /* corrected so that refraction is 0 at zenith */
        return R + 0.0019279;
    return R;
}

/**
 * @brief refraction from measured
 *
 * Get the refraction to be substracted from the apparent (=seen, measured)
 * altitude of a celestial body, to get its true altitude.
 *
 * Implements Meeus formula 16.3.
 *
 * @param[in] h0 apparent altitude in degrees
 * @param[in] corrected if 1, correct refraction to be exactly 0 at zenith.
 *
 * @return refraction in minutes of arc.
 */ double
ref_refraction_apparent_to_true (double h0, int corrected)
{
    /* Meeus 16.3 */
    double R = 1.0 / (tand (h0 + 7.31 / (h0 + 4.4)));
    if (corrected)              /* corrected so that refraction is 0 at zenith */
        return R + 0.0013515;
    return R;
#if 0
    /* Bennet's correction to 16.3 - still not correct for zenith */
    double R = 1.0 / (tand (h0 + 7.31 / (h0 + 4.4)));
    R -= -0.06 * sind (14.7 * R / 60.0 + 13);
    return R;
#endif
}
