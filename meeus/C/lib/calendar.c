/**
 * @file calendar.c
 * Meeus chapters 8 and 9.
 *
 * Various functions linked to calendars (Christian, Jewish and Moslem)
 */
#include <stdio.h>
#include <time.h>
#include "meeus.h"

/**
 * @brief   Get the month and day of Christian Easter sunday
 *
 * @param[in] year       year in the Julian or Gregorian calendar.
 * @param[out] month  the month of Easter for the given year (1-> Jan, 12-> Dec)
 * @param[out] day    the day of Easter sunday in the Easter month (from 1 to 31)
 *
 * @return error code
 * @retval M_NO_ERR The function was successfully executed
 */
m_err_t
cal_get_easter (int year, int *month, int *day)
{
    if (year > 1582) {
        int a = year % 19;
        int b = year / 100;
        int c = year % 100;
        int d = b / 4;
        int e = b % 4;
        int f = (b + 8) / 25;
        int g = (b - f + 1) / 3;
        int h = (19 * a + b - d - g + 15) % 30;
        int i = c / 4;
        int k = c % 4;
        int l = (32 + 2 * e + 2 * i - h - k) % 7;
        int m = (a + 11 * h + 22 * l) / 451;
        int o = h + l - 7 * m + 114;
        *month = o / 31;
        *day = (o % 31) + 1;
    }
    else {
        int a = year % 4;
        int b = year % 7;
        int c = year % 19;
        int d = (19 * c + 15) % 30;
        int e = (2 * a + 4 * b - d + 34) % 7;
        int h = d + e + 114;
        *month = h / 31;
        *day = (h % 31) + 1;
    }
    return M_NO_ERR;
}

/**
 * @brief   Get the month and day of Jewish Pesach
 *
 * @param[in] year       year in the Christian calendar (Julian if <= 1582, else Gregorian).
 * @param[out] jyear  the jewish year of this Pesach
 * @param[out] month  the month of Pesach for the given year (1-> Jan, 12-> Dec)
 * @param[out] day    the day of Pesach for the month (from 1 to 31)
 *
 * @return function status
 * @retval M_NO_ERR The function was successfully executed
 */
m_err_t
cal_get_pesach (int year, int *jyear, int *month, int *day)
{
    int D, M;

    int X = year;
    int A = X + 3760;
    int C = X / 100;
    int S = 0;
    if (X > 1582)               /* Gregorian date */
        S = (int) ((3 * C - 5) / 4);
    int a = (12 * X + 12) % 19;
    int b = X % 4;
    long double Q =
        -1.904412361576 + 1.554241796621 * a + 0.25 * b - 0.003177794022 * X +
        S;
    int j = ((int) Q + 3 * X + 5 * b + 2 - S) % 7;
    long double r = Q - (int) Q;

    if ((j == 2) || (j == 4) || (j == 6))
        D = (int) Q + 23;
    else if ((j == 1) && (a > 6) && (r >= 0.632870370))
        D = (int) Q + 24;
    else if ((j == 0) && (a > 11) && (r >= 0.897723765))
        D = (int) Q + 23;
    else
        D = (int) Q + 22;

    if (D <= 31)
        M = 3;
    else {
        M = 4;
        D -= 31;
    }

    *jyear = A;
    *month = M;
    *day = D;

    return M_NO_ERR;
}

/**
 * @brief   Get the year, month and day of Jewish new year (1 Tishri)
 *
 * @param[in] year       year in the Christian calendar (Julian if <= 1582, else Gregorian).
 * @param[out] jyear  the jewish new year starting during year
 * @param[out] month  the month of jewish new year (1-> Jan, 12-> Dec)
 * @param[out] day    the day of jewish new year (from 1 to 31)
 *
 * @return function status
 * @retval M_NO_ERR The function was successfully executed
 * @retval M_INVALID_RANGE_ERR year is before -4172 (JD 0)
 */
m_err_t
cal_get_1_tishri (int year, int *jyear, int *month, int *day)
{
    struct tm td = { 0 };
    double jd;
    m_err_t err;

    cal_get_pesach (year, jyear, month, day);
    td.tm_year = year - 1900;
    td.tm_mon = *month - 1;
    td.tm_mday = *day;
    err = dt_date_to_jd (&td, &jd);
    if (err)
        return err;
    jd += 163;
    err = dt_jd_to_date (jd, &td);
    if (err)
        return err;
    *jyear += 1;
    *month = td.tm_mon + 1;
    *day = td.tm_mday;
    return M_NO_ERR;
}

/**
 * @brief   Get the type of jewish year
 *
 * @param[in] jyear    Jewish year
 * @param[out] is_leap 1 if the year is a leap (embolismic) year, 0 if it is a common year
 * @param[out] ndays    the number of days in the year
 *
 * @return function status
 * @retval M_NO_ERR The function was successfully executed
 * @retval M_INVALID_RANGE_ERR some calculations had to use a Julian year before -4172 (JD 0)
 */
m_err_t
cal_get_jewish_year_type (int jyear, int *is_leap, int *ndays)
{
    m_err_t err;
    int jy1, m1, d1, jy2, m2, d2;
    double jd1, jd2;
    struct tm td1 = { 0 };
    struct tm td2 = { 0 };

    int X = jyear - 3760;       /* Christian year corresponding to the end of jyear */
    err = cal_get_1_tishri (X, &jy2, &m2, &d2); /* 1 Tishri of next year */
    if (err)
        return err;
    err = cal_get_1_tishri (X - 1, &jy1, &m1, &d1);
    if (err)
        return err;

    td1.tm_year = X - 1 - 1900;
    td1.tm_mon = m1 - 1;
    td1.tm_mday = d1;

    td2.tm_year = X - 1900;
    td2.tm_mon = m2 - 1;
    td2.tm_mday = d2;

    dt_date_to_jd (&td2, &jd2);
    dt_date_to_jd (&td1, &jd1);

    *ndays = jd2 - jd1;
    int rm = jy1 % 19;
    if ((rm == 0) || (rm == 3) || (rm == 6) || (rm == 8) || (rm == 11)
        || (rm == 14) || (rm == 17))
        *is_leap = 1;
    else
        *is_leap = 0;
    return M_NO_ERR;
}
