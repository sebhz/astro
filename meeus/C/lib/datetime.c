/**
 * @file datetime.c
 * Meeus chapter 7.
 *
 * Function linked to manipulation of Julian days
 */
#include <stdio.h>
#include <time.h>
#include "meeus.h"

/**
 * @brief compares two struct tm dates
 *
 * @param[in] d1 first date to compare
 * @param[in] d2 second date to compare
 *
 * @return d1 and d2 comparison
 * @retval 0 d1 and d2 are equal
 * @retval >0 d1 is posterior to d2
 * @retval <0 d1 is anterior to d2
 */
int
dt_cmpdate (struct tm *d1, struct tm *d2)
{
    if (d1->tm_year == d2->tm_year)
        if (d1->tm_mon == d2->tm_mon)
            if (d1->tm_mday == d2->tm_mday)
                if (d1->tm_hour == d2->tm_hour)
                    if (d1->tm_min == d2->tm_min)
                        if (d1->tm_sec == d2->tm_sec)
                            return 0;
                        else
                            return d1->tm_sec - d2->tm_sec;
                    else
                        return d1->tm_min - d2->tm_min;
                else
                    return d1->tm_hour - d2->tm_hour;
            else
                return d1->tm_mday - d2->tm_mday;
        else
            return d1->tm_mon - d2->tm_mon;
    else
        return d1->tm_year - d2->tm_year;
}

/**
 * @brief check if a struct tm date is part of the Gregorian calendar.
 *
 * @param[in] date
 *
 * @return the date status
 * @retval 0 the date is part of the Julian calendar (before 1582 Nov. 15th)
 * @retval 1 the date is part of the Gregorian calendar (after 1582 Nov. 15th)
 */
int
dt_is_gregorian (struct tm *date)
{
    if (dt_cmpdate
        (date, &(struct tm) { 0, 0, 0, 15, 10, 1582 - 1900, 3, 0, 0 }) >= 0)
        return 1;
    return 0;
}

/**
 * @brief check if a year is a leap year
 *
 * Any year before 1582 is supposed to be in the Julian calendar.
 * Any year after 1582 is supposed to be in the Gregorian calendar.
 *
 * @param[in] year (YYYY format, e.g. 1515, 2021,...)
 *
 * @return the year status
 * @retval 0 the year is not a leap year
 * @retval 1 the year is a leap year
 */
int
dt_is_leap (int year)
{
    if ((year % 4) == 0) {
        if (year <= 1582)
            return 1;           /* Julian year - all multiple of 4 are leap */
        /* Gregorian year. Centuries are not leap except if divisible by 400 */
        else if (((year % 100) != 0) || ((year % 400) == 0))
            return 1;
    }
    return 0;
}

/**
 * @brief get the fractional day corresponding to a struct tm date
 *
 * example April 3, 18h is fractional day 3.75
 *
 * @param[in] date
 *
 * @return the fractional day corresponding to the input date
 */
double
dt_get_frac_day (struct tm *date)
{
    return (double) (date->tm_mday +
                     (3600.0 * date->tm_hour + 60.0 * date->tm_min +
                      (double) (date->tm_sec)) / DT_SECS_PER_DAY);
}

/**
 * @brief get the julian day corresponding to a date
 *
 * Any date before 1582 Nov 15 is supposed to be in the Julian calendar.
 * Any date after 1582 Nov 15 is supposed to be in the Gregorian calendar.
 *
 * @param[in] date
 * @param[out] jd the julian day
 *
 * @return error status of the function
 * @retval M_INVALID_RANGE_ERR the input date is before Jan 1st -4712 12:00:00 (negative Julian Day)
 * @retval M_NO_ERR the function executed correctly
 */
m_err_t
dt_date_to_jd (struct tm *date, double *jd)
{
    if (dt_cmpdate (date, &(struct tm) { 0, 0, 12, 1, 0, -4712 - 1900, 0, 0, 0 }) < 0) {        /* Negative julian year */
        return M_INVALID_RANGE_ERR;
    }

    int M = date->tm_mon + 1;
    int Y = 1900 + date->tm_year;
    int A, B;
    double D = dt_get_frac_day (date);

    if (M <= 2) {
        Y--;
        M += 12;
    }

    A = Y / 100;

    if (dt_is_gregorian (date)) {
        B = 2 - A + A / 4;
    }
    else {
        B = 0;
    }

    *jd = (int) (365.25 * (Y + 4716)) + (int) (30.6001 * (M + 1)) + D + B -
        1524.5;
    return M_NO_ERR;
}

/**
 * @brief get the day of the week corresponding to a date
 *
 * Any date before 1582 Nov 15 is supposed to be in the Julian calendar.
 * Any date after 1582 Nov 15 is supposed to be in the Gregorian calendar.
 *
 * @param[in] date
 * @param[out] dow the day of the week (Sunday:0, Monday:1, etc.)
 *
 * @return error status of the function
 * @retval M_INVALID_RANGE_ERR the input date is before Jan 1st -4712 12:00:00 (negative Julian Day)
 * @retval M_NO_ERR the function executed correctly
 */
m_err_t
dt_get_day_of_week (struct tm *date, int *dow)
{
    m_err_t err = M_NO_ERR;
    struct tm dt =
        { 0, 0, 0, date->tm_mday, date->tm_mon, date->tm_year, 0, 0, 0 };
    double jd = 0;
    err = dt_date_to_jd (&dt, &jd);
    *dow = ((int) (jd + 1.5)) % 7;
    return err;
}

/**
 * @brief get the day of the year week corresponding to a date
 *
 * Any date before 1582 Nov 15 is supposed to be in the Julian calendar.
 * Any date after 1582 Nov 15 is supposed to be in the Gregorian calendar.
 *
 * @param[in] date
 * @param[out] doy the day of the year (between 1 and 366)
 *
 * @return error status of the function
 * @retval M_NO_ERR the function executed correctly
 */
m_err_t
dt_get_day_of_year (struct tm *date, int *doy)
{
    int K;
    int M = date->tm_mon + 1;

    if (dt_is_leap (date->tm_year + 1900))
        K = 1;
    else
        K = 2;

    *doy = (int) (275 * M / 9) - K * (int) ((M + 9) / 12) + date->tm_mday -
        30;
    return M_NO_ERR;
}

/**
 * @brief get the date corresponding to a Julian Day
 *
 * @param[in] jd the julian day
 * @param[out] date
 *
 * @return error status of the function
 * @retval M_INVALID_RANGE_ERR the input JD is negative
 * @retval M_NO_ERR the function executed correctly
 */
m_err_t
dt_jd_to_date (double jd, struct tm *date)
{
    if (jd < 0)
        return M_INVALID_RANGE_ERR;

    double jdi = jd + 0.5;
    int Z = (int) jdi;
    double F = jdi - Z;
    int A, B, C, D, E, m;

    if (Z < 2299161)
        A = Z;
    else {
        int alpha = (int) ((Z - 1867216.25) / 36524.25);
        A = Z + 1 + alpha - alpha / 4;
    }

    B = A + 1524;
    C = (int) ((B - 122.1) / 365.25);
    D = (int) (365.25 * C);
    E = (int) ((B - D) / 30.6001);
    date->tm_mday = B - D - (int) (30.6001 * E);

    if (E < 14)
        m = E - 1;
    else
        m = E - 13;
    date->tm_mon = m - 1;

    if (m > 2)
        date->tm_year = C - 4716 - 1900;
    else
        date->tm_year = C - 4715 - 1900;

    int secs = (int) (F * DT_SECS_PER_DAY);
    date->tm_hour = secs / 3600;
    date->tm_min = (secs % 3600) / 60;
    date->tm_sec = secs % 60;
    date->tm_wday = (int) (jd + 1.5) % 7;
    return dt_get_day_of_year (date, &(date->tm_yday));
}

/**
 * @brief get the julian day corresponding to the current date
 *
 * Any date before 1582 Nov 15 is supposed to be in the Julian calendar.
 * Any date after 1582 Nov 15 is supposed to be in the Gregorian calendar.
 *
 * @param[in] is_local if 1, current date is the local date. If 0 it is the UTC date.
 * @param[out] jd the julian day
 *
 * @return error status of the function
 * @retval M_INVALID_RANGE_ERR the current date is before Jan 1st -4712 12:00:00 (negative Julian Day)
 * @retval M_NO_ERR the function executed correctly
 */
m_err_t
dt_get_current_jd (int is_local, double *jd)
{
    time_t cur_time;
    struct tm *date;

    time (&cur_time);
    if (!is_local)
        date = gmtime (&cur_time);
    else
        date = localtime (&cur_time);

    return dt_date_to_jd (date, jd);
}

/**
 * @brief set the wday field of a struct tm with the correct value
 *
 * Any date before 1582 Nov 15 is supposed to be in the Julian calendar.
 * Any date after 1582 Nov 15 is supposed to be in the Gregorian calendar.
 *
 * @param[inout] date
 *
 * @return error status of the function
 * @retval M_INVALID_RANGE_ERR the current date is before Jan 1st -4712 12:00:00 (negative Julian Day)
 * @retval M_NO_ERR the function executed correctly
 */
m_err_t
dt_set_day_of_week (struct tm *date)
{
    return dt_get_day_of_week (date, &(date->tm_wday));
}
