#include <stdio.h>
#include <math.h>
#include <time.h>
#include "meeus.h"

extern int success;

double
truncate (double v, int n)
{
    long m = pow (10, n);
    return trunc (v * m) / m;
}

void
res (double v1, double v2, int n_decimals, int fail_ok)
{
    double t1 = fround (v1, n_decimals);
    double t2 = fround (v2, n_decimals);
    if (t1 != t2) {
        printf ("FAIL %s (got %.*f - expected %.*f)\n",
                fail_ok ? "(expected)" : "", 10, v1, n_decimals, t2);
        if (!fail_ok)
            success = 0;
        return;
    }
    printf ("PASS\n");
}

void
res_coord (double *v1, double *v2, int n_decimals, int fail_ok)
{
    double t1, t2;
    for (int i = 0; i < 3; i++) {
        t1 = fround (v1[i], n_decimals);
        t2 = fround (v2[i], n_decimals);
        if (t1 != t2) {
            printf
                ("FAIL %s (got (%.10f, %.10f, %.10f) - expected (%.*f, %.*f, %.*f) (%d digits))\n",
                 fail_ok ? "expected" : "", v1[0], v1[1], v1[2], n_decimals,
                 v2[0], n_decimals, v2[1], n_decimals, v2[2], n_decimals);
            if (!fail_ok)
                success = 0;
            return;
        }
    }
    printf ("PASS\n");
}
