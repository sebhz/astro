#include <stdio.h>
#include <time.h>
#include <math.h>
#include "meeus.h"

/* Get refraction to be added to the true (=airless, calculated)
   altitude, to get the apparent altitude.
   Refraction is returned in minutes of arc.
   h is true altitude in degrees */
double
ref_refraction_true_to_apparent (double h, int corrected)
{
    /* Meeus 16.4 */
    double R = 1.02 / (tand (h + 10.3 / (h + 5.11)));
    if (corrected)              /* corrected so that refraction is 0 at zenith */
        return R + 0.0019279;
    return R;
}

/* Get refraction to be substracted to the apparent (=seen, measured)
   altitude, to get the true altitude.
   Refraction is returned in minutes of arc.
   h0 is apparent altitude in degrees */
double
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
