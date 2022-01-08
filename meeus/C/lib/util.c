#include <stdio.h>
#include <math.h>

double
polynom (const double *coef, double v, int order)
{
    double res = 0;
    for (int i = order; i >= 0; i--) {
        res = res * v + coef[i];
    }
    return res;
}

double
get_century_since_j2000 (double jd)
{
    return (jd - 2451545) / 36525.0;
}

double
rerange (double v, double mod)
{
    double res = fmod (v, mod);
    if (res < 0) {
        res += mod;
    }
    return res;
}

void
s_to_hms (double seconds, int *h, int *m, double *s)
{
    *h = (int) (seconds / 3600.0);
    *m = (int) ((fmod (seconds, 3600)) / 60.0);
    *s = fmod (seconds, 60.0);
}

double
fround (double v, int n)
{
    long m = pow (10, n);
    return trunc (round (v * m)) / m;
}
