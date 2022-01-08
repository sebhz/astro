#include <stdio.h>
#include <time.h>
#include "meeus.h"

/**
 * \brief   Get the month and day of Christian Easter sunday
 *
 * \param[in] year       year in the Julian or Gregorian calendar.
 * \param[in,out] month  the month of Easter for the given year (1-> Jan, 12-> Dec)
 * \param[in,out] day    the day of Easter sunday in the Easter month (from 1 to 31)
 *
 * \return return error code
 * \retval M_NO_ERR The function was successfully executed
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
        int f = (b + 8)/25;
        int g = (b - f + 1)/3;
        int h = (19 * a + b - d - g + 15) % 30;
        int i = c / 4;
        int k = c % 4;
        int l = (32 + 2*e + 2*i - h - k)% 7;
        int m = (a + 11*h + 22*l)/451;
        int o = h + l - 7*m + 114;
        *month = o/31;
        *day = (o%31) + 1;
    }
    else {
        int a = year % 4;
        int b = year % 7;
        int c = year % 19;
        int d = (19*c + 15)%30;
        int e = (2*a + 4*b - d + 34)%7;
        int h = d + e + 114;
        *month = h/31;
        *day = (h %31) + 1;
    }
    return M_NO_ERR;
}
