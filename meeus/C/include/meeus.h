#ifndef _MEEUS_H
#define _MEEUS_H

/* errors */
typedef enum meeus_error_e
{
    M_NO_ERR = 0,
    M_INVALID_RANGE_ERR
} m_err_t;

/* math */
#define sind(x) sin((x)/180.0*M_PI)
#define cosd(x) cos((x)/180.0*M_PI)
#define tand(x) tan((x)/180.0*M_PI)

#define rad_to_deg(x) ((x)*180.0/M_PI)
#define deg_to_rad(x) ((x)*M_PI/180.0)

/* hours, minutes, seconds to seconds */
#define hms_to_s(h, m, s) ((h)*3600 + (m)*60 + (s))
/* hours, minutes, seconds to degrees */
#define hms_to_d(h, m, s) (((double)(((h)*3600.0 + (m)*60.0 + (s))))/240.0)
/* degrees, minutes, arcseconds to degrees */
#define dms_to_d(d, m, s) ((d) + ((double)(m))/60.0 + ((double)(s))/3600.0)
/* degrees, minutes, arcseconds to arcseconds */
#define dms_to_arcsec(d, m, s) ((d)*3600 + (m)*60 + (s))
/* degrees to arcseconds */
#define deg_to_arcsec(d) ((d)*3600)
/* arcseconds to degrees */
#define arcsec_to_deg(d) (((double)(d))/3600.0)
/* degrees to seconds of time */
#define deg_to_s(d) ((d)*240)
/* seconds of time to degrees */
#define s_to_deg(s) (((double)(s))/240.0)
/* arcseconds to seconds of time */
#define arcsec_to_s(a) (((double)(a))/15.0)
/* seconds of time to arcseconds */
#define s_to_arcsec(s) ((s)*15)

/* planets */
enum planet_e
{
    MERCURY = 0,
    VENUS,
    EARTH,
    MARS,
    JUPITER,
    SATURN,
    URANUS,
    NEPTUNE
};

/* Basic utilities */
double polynom (const double *coef, double v, int order);
double get_century_since_j2000 (double jd);
double rerange (double v, double mod);
void s_to_hms (double seconds, int *h, int *m, double *s);
double fround (double v, int n);
#define arcs_to_dms s_to_hms

/* datetime */
#define DT_SECS_PER_DAY 86400
m_err_t dt_date_to_jd (struct tm *date, double *jd);
m_err_t dt_jd_to_date (double jd, struct tm *date);
m_err_t dt_get_current_jd (int is_local, double *jd);
m_err_t dt_get_day_of_week (struct tm *date, int *dow);
m_err_t dt_get_day_of_year (struct tm *date, int *doy);

/* calendar */
m_err_t cal_get_easter (int year, int *month, int *day);
m_err_t cal_get_pesach (int year, int *jyear, int *month, int *day);
m_err_t cal_get_1_tishri (int year, int *jyear, int *month, int *day);
m_err_t cal_get_jewish_year_type (int jyear, int *is_leap, int *ndays);

/* dynamical time */
double dy_get_deltaT_seconds (double jde);
double dy_dt_to_ut (double jde);
double dy_ut_to_dt (double jd);
#define jd_to_jde dy_ut_to_dt
#define jde_to_jd dy_dt_to_ut

/* sidereal time */
m_err_t sid_get_mean_gw_sid_time (double jd, double *sid_t);
m_err_t sid_get_apparent_gw_sid_time (double jd, double *sid_t);

/* Coordinates */
void coo_equ_to_ecl (double alpha, double delta, double epsilon,
                     double *lambda, double *beta);
void
coo_ecl_to_equ (double lambda, double beta, double epsilon, double *alpha,
                double *delta);
void coo_equ_to_hor (double H, double delta, double phi, double *A,
                     double *h);
void
coo_hor_to_equ (double A, double h, double phi, double *H, double *delta);
m_err_t coo_get_local_hour_angle (double jd, double L, double alpha,
                                  double *hour_angle, int is_apparent);

/* refraction */
double ref_refraction_true_to_apparent (double h, int corrected);
double ref_refraction_apparent_to_true (double h0, int corrected);

/* ecliptic */
double ecl_nut_in_lon (double jde, int high_accuracy);
double ecl_nut_in_obl (double jde, int high_accuracy);
m_err_t ecl_mean_obl_ecliptic (double jde, double *obl, int high_accuracy);
m_err_t ecl_true_obl_ecliptic (double jde, double *obl, int high_accuracy);

/* equinox and solstice */
struct eqx_s
{
    int year;
    double mar_eqx;
    double jun_sol;
    double sep_eqx;
    double dec_sol;
};
void eqx_get_sol_eqx (struct eqx_s *eqx, int high_accuracy);

/* sun */
m_err_t sun_mean_geocentric_coord (double jde, double *alpha, double *delta,
                                   int high_accuracy);
m_err_t sun_apparent_geocentric_coord (double jde, double *alpha,
                                       double *delta, int high_accuracy);
void sun_mean_ecliptic_coord (double jde, double *lambda, double *beta,
                              double *R);
void sun_apparent_ecliptic_coord (double jde, double *lambda, double *beta,
                                  double *R);


/* equation of time */
m_err_t eqt_equation_of_time (double jde, double *eqt);

/* vsop87 */
void vso_vsop87d_coordinates (double jde, enum planet_e planet,
                              double *coord);
void vso_vsop87d_dyn_coordinates (double jde, enum planet_e planet,
                                  double *coord);

#endif
