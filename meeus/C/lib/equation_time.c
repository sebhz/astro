#include <stdio.h>
#include <math.h>
#include <time.h>
#include "meeus.h"

m_err_t
eqt_equation_of_time (double jde, double *eqt)
{
    double tau = get_century_since_j2000 (jde) / 10;
    double L0 = polynom ((double[]) { 280.4664567, 360007.6982779, 0.03032028,
                         1.0 / 49931, -1.0 / 15300, -1.0 / 2000000
                         }, tau, 5);
    double alpha, delta, epsilon;
    m_err_t err;
    err = sun_apparent_geocentric_coord (jde, &alpha, &delta, 1);
    if (err)
        return err;

    double deltaPsi = ecl_nut_in_lon (jde, 1);
    err = ecl_true_obl_ecliptic (jde, &epsilon, 1);
    *eqt = rerange (L0 - 0.00597183 - alpha +
                    deltaPsi / 3600.0 * cosd (epsilon / 3600.0), 360);
    return M_NO_ERR;
}
