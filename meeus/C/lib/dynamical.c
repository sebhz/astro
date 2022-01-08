#include <stdio.h>
#include <time.h>
#include "meeus.h"

/* Those are taken from https://eclipse.gsfc.nasa.gov/5MCSE/5MCSE-Text11.pdf
   section 2.7. It came from Meeus and Espenak ! */
/* No specific check performed on JDE - the further away in time the less
   accurate */
double
dy_get_deltaT_seconds (double jde)
{
    struct tm td;

    dt_jd_to_date (jde, &td);
    int year = td.tm_year + 1900;
    double y = year + ((double) td.tm_mon + 1 - 0.5) / 12;      /* 0 <= tm_mon <= 11 */
    double u, t;

    if (year < -500) {
        u = (y - 1820) / 100.0;
        return -20 + 32 * u * u;
    }
    if (year < 500) {
        u = y / 100.0;
        return polynom ((double[]) { 10583.6, -1014.41, 33.78311,
                        -5.952053, -0.1798452, 0.022174192, 0.0090316521
                        }, u,
                        6);
    }
    if (year < 1600) {
        u = (y - 1000) / 100;
        return polynom ((double[]) { 1574.2, -556.01, 71.23472, 0.319781,
                        -0.8503463, -0.005050998, 0.0083572073
                        }, u, 6);
    }
    if (year < 1700) {
        t = y - 1600;
        return polynom ((double[]) { 120, -0.9808, -0.01532, 1.0 / 7129.0 },
                        t, 3);
    }
    if (year < 1800) {
        t = y - 1700;
        return polynom ((double[]) { 8.83, 0.1603, -0.0059285, 0.00013336,
                        -1.0 / 1174000.0
                        }, t, 4);
    }
    if (year < 1860) {
        t = y - 1800;
        return polynom ((double[]) { 13.72, -0.332447, 0.0068612, 0.0041116,
                        -0.00037436, 0.0000121272, -0.0000001699,
                        0.000000000875
                        }, t, 7);
    }
    if (year < 1900) {
        t = y - 1860;
        return polynom ((double[]) { 7.62, 0.5737, -0.251754, 0.01680668,
                        -0.0004473624, 1.0 / 233174.0
                        }, t, 5);
    }
    if (year < 1920) {
        t = y - 1900;
        return polynom ((double[]) { -2.79, 1.494119, -0.0598939, 0.0061966,
                        -0.000197
                        }, t, 4);
    }
    if (year < 1941) {
        t = y - 1920;
        return polynom ((double[]) { 21.2, 0.84493, -0.0761, 0.0020936 }, t,
                        3);
    }
    if (year < 1961) {
        t = y - 1950;
        return polynom ((double[]) { 29.07, 0.407, -1.0 / 233.0,
                        1.0 / 2547.0
                        }, t, 3);
    }
    if (year < 1986) {
        t = y - 1975;
        return polynom ((double[]) { 45.45, 1.067, -1.0 / 260.0,
                        -1.0 / 718.0
                        }, t, 3);
    }
    if (year < 2005) {
        t = y - 2000;
        return polynom ((double[]) { 63.86, 0.3345, 0.060374, 0.0017275,
                        0.000651814, 0.00002373599
                        }, t, 5);
    }
    if (year < 2050) {
        t = y - 2000;
        return polynom ((double[]) { 62.92, 0.32217, 0.005589 }, t, 2);
    }
    u = (y - 1820) / 100.0;
    if (year < 2150)
        return -20 + 32 * u * u - 0.5628 * (2150 - y);
    else
        return -20 + 32 * u * u;
}

double
dy_dt_to_ut (double jde)
{
    return jde - dy_get_deltaT_seconds (jde) / DT_SECS_PER_DAY;
}

double
dy_ut_to_dt (double jd)
{
    return jd + dy_get_deltaT_seconds (jd) / DT_SECS_PER_DAY;
}
