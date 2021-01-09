--[[ A collection of date and time functions.

The functions which use Julian Day Numbers are valid only for positive values,
i.e., for dates after -4712 (4713BC).

Unless otherwise specified, Julian Day Numbers may be fractional values.

Numeric years use the astronomical convention of a year 0: 0 = 1BC, -1 = 2BC, etc.

Numeric months are 1-based: Jan = 1...Dec = 12.

Numeric days are the same as the calendar value.

Reference: Jean Meeus, _Astronomical Algorithms_, second edition, 1998, Willmann-Bell, Inc.

--]]
require "astro.util"
require "astro.globals"

local modpi2      = astro.util.modpi2
local fday_to_hms = astro.util.fday_to_hms
local hms_to_fday = astro.util.hms_to_fday

--[[
Return True if this is a leap year in the Julian or Gregorian calendars

    Parameters:
        yr        : year
        gregorian : If True, use Gregorian calendar, else use Julian calendar (default: True)

    Return:
        True is this is a leap year, else False.

--]]
local function is_leap_year(yr, gregorian)
    if gregorian == nil then gregorian = true end
    yr = math.floor(yr)
    if gregorian then
        return (yr % 4 == 0) and ((yr % 100 ~= 0) or (yr % 400 == 0))
    else
        return yr % 4 == 0
    end
end

--[[
Convert a date in the Julian or Gregorian calendars to the Julian Day Number

    Parameters:
        yr        : year
        mo        : month (default: 1)
        day       : day, may be fractional day (default: 1)
        gregorian : If True, use Gregorian calendar, else use Julian calendar (default: True)

    Return:
        jd        : julian day number

   This is not Meeus formula... but it works just fine :-)
--]]
local function cal_to_jd(yr, mo, day, gregorian)
    mo = mo or 1
    day = day or 1
    if gregorian == nil then gregorian = true end

    local a = math.floor((14-mo)/12)
    local y = yr + 4800 - a
    local m = mo + 12*a -3

    local jdn = day + math.floor((153*m+2)/5)+365*y+math.floor(y/4)-32083.5
    if not gregorian then
        return jdn
    else
        return jdn - math.floor(y/100)+math.floor(y/400)+38
    end
end
--[[
Meeus' implementation - which gives the same results
--]]
local function cal_to_jd(yr, mo, day, gregorian)
    mo = mo or 1
    day = day or 1
    if gregorian == nil then gregorian = true end
    if mo <= 2 then
        yr = yr-1
        mo = mo+12
    end
    if gregorian then
        A = math.floor(yr / 100)
        B = 2 - A + math.floor(A / 4)
    else
        B = 0
    end
    return math.floor(365.25 * (yr + 4716)) + math.floor(30.6001 * (mo + 1)) + day + B - 1524.5
end

--[[
Get the julian day corresponding to current UTC time
--]]
local function get_current_jd()
    local date=os.date("!*t")

    return cal_to_jd(date['year'],
                     date['month'],
                     date['day'] + hms_to_fday(date['hour'], date['min'], date['sec']))
end

--[[
Convert a date in the Julian or Gregorian calendars to day of the year (Meeus 7.1).

    Parameters:
        yr        : year
        mo        : month
        day       : day
        gregorian : If True, use Gregorian calendar, else use Julian calendar (default: True)

    Return:
        day number : 1 = Jan 1...365 (or 366 for leap years) = Dec 31.

--]]
local function cal_to_day_of_year(yr, mo, dy, gregorian)
    local K
    if gregorian == nil then gregorian = true end
    if is_leap_year(yr, gregorian) then
        K = 1
    else
        K = 2
    end

    local dy = math.floor(dy)
    return math.floor(275 * mo / 9.0) - (K * math.floor((mo + 9) / 12.0)) + dy - 30
end

--[[ Convert a day of year number to a month and day in the Julian or Gregorian calendars.

    Parameters:
        yr        : year
        N         : day of year, 1..365 (or 366 for leap years)
        gregorian : If True, use Gregorian calendar, else use Julian calendar (default: True)

    Return:
        month
        day

--]]
local function day_of_year_to_cal(yr, N, gregorian)
    local K, mo

    if gregorian == nil then gregorian = true end

    if is_leap_year(yr, gregorian) then
        K = 1
    else
        K = 2
    end

    if (N < 32) then
        mo = 1
    else
        mo = math.floor(9 * (K+N) / 275.0 + 0.98)
    end
    local dy = math.floor(N - math.floor(275 * mo / 9.0) + K * math.floor((mo + 9) / 12.0) + 30)
    return mo, dy
end

--[[
Return the date of Jewish Pesach  for a year in the Julian or Gregorian calendars.

    Parameters:
        yr        : year (in the Jewish calendar)
        gregorian : If True, use Gregorian calendar, else use Julian calendar (default: True)

    Return:
        month
        day
Meeus - chapter 9
--]]
local function pesach(yr, gregorian)
    if gregorian == nil then gregorian = true end
    local C = math.floor(yr/100)
    local S = 0
    if gregorian then
        S = math.floor((3*C-5)/4)
    end
    local A = yr-3760
    local a = (12*yr+12)%19
    local b = yr%4
    local Q = -1.904412361576 + 1.554241796621*a+0.25*b-0.003177794022*yr+S
    local j = (math.floor(Q)+3*yr + 5*b + 2 -S)%7
    local r = Q-math.floor(Q)

    local D
    if j==2 or j==4 or j==6 then
        D = math.floor(Q)+23
    elseif j==1 and a > 6 and r >= 0.63287037 then
        D = math.floor(Q)+24
    elseif j==0 and a > 11 and r >= 0.897723765 then
        D = math.floor(Q) + 23
    else
        D = math.floor(Q) + 22
    end

    if D > 31 then
        return 4, D-31
    else
        return 3, D
    end
end

local function jewish_new_year(yr)
    local gr_yr = yr-1-3760
    local m, d = pesach(yr-1)
    local jd = cal_to_jd(gr_yr, m, d) + 316
    return jd_to_cal(jd)
end
--[[
Converts a date in the moslem calendar to a date in the Christian calendar
Meeus - chapter 9
    Input: h - moslem yearhe christian year
           m - moslem month number
           d - moslem day
    Returns: yr, month, day in the christian calendar

    This function will return meaningless results if called with a date earlier than
    622, July 16th
--]]
local function moslem_to_christian(h, m, d)
    local N = d + math.floor(29.5001*(m-1)+0.99)
    local Q  = math.floor(h/30)
    local R  = h%30
    local A = math.floor((11*R+3)/30)
    local W = 404*Q + 354*R+208 + A
    local Q1 = math.floor(W/1461)
    local Q2 = W%1461
    local G  = 621 + 4*math.floor(7*Q+Q1)
    local K = math.floor(Q2/365.2422)
    local E = math.floor(K*365.2422)
    local J = Q2-E+N-1
    local X = G+K

    if J > 366 and X%4 == 0 then
        X = X+1
        J = J - 366
    elseif J > 365 and X%4 > 0 then
        X = X+1
        J = J - 365
    end

    -- X is the year, J is the day in the julian calendar
    -- Convert to MJD
    local jd = math.floor(365.25*(X-1)) + 1721423 + J
    local alpha = math.floor((jd-1867216.25)/36524.25)
    local beta
    if jd < 2299161 then -- Before 1582, Oct 15th
        beta = jd
    else
        beta = jd+ 1 + alpha - math.floor((alpha/4))
    end
    local b = beta+1524

    local c = math.floor((b-122.1)/365.25)
    local d = math.floor(365.25*c)
    local e = math.floor((b-d)/30.6001)
    D = b-d-math.floor(30.6001*e)
    if e < 14 then M = e-1 else M = e-13 end
    if M > 2  then X = c-4716 else X = c-4715 end

    return X, M, D
end

local function christian_to_moslem(X, M, D, gregorian)
    if gregorian == nil then gregorian = true end
    -- first convert the gregorian date to a julian date
    if gregorian then
        if M < 3 then
            X = X-1
            M = M+12
        end
        local alpha = math.floor(X/100)
        local beta  = 2-alpha+math.floor(alpha/4)
        local b = math.floor(365.25*X)+math.floor(30.6001*(M+1))+D+1722519+beta

        local c = math.floor((b-122.1)/365.25)
        local d = math.floor(365.25*c)
        local e = math.floor((b-d)/30.6001)
        D = b-d-math.floor(30.6001*e)
        if e < 14 then M = e-1 else M = e-13 end
        if M > 2  then X = c-4716 else X = c-4715 end
    end

    local W
    if X%4 == 0 then W = 1 else W = 2 end
    local N = math.floor(275*M/9)-W*math.floor((M+9)/12) + D - 30
    local A = X - 623
    local B = math.floor(A/4)
    local C = A%4
    local C1 = 365.2501*C
    local C2 = math.floor(C1)
    if C1 - C2 > 0.5 then C2 = C2 + 1 end
    local Dp = 1461*B+170+C2
    local Q = math.floor(Dp/10631)
    local R = Dp%10631
    local J = math.floor(R/354)
    local K = R%354
    local O = math.floor((11*J+14)/30)
    local H = 30*Q+J+1
    local JJ = K-O+N-1

    if JJ > 354 then
        local CL = H%30
        local DL = (11*CL+3)%30
        if DL < 19 then
            JJ = JJ-354
            H=H+1
        else
            JJ = JJ-355
            H=H+1
        end
        if JJ == 0 then
            JJ = 355
            H = H-1
        end
    end

    local S = math.floor((JJ-1)/29.5)
    local m = 1 + S
    local d = math.floor(JJ-29.5*S)
    if JJ == 355 then
        m = 12
        d = 30
    end

    return H, m, d

end

--[[
Return the date of Western ecclesiastical Easter for a year in the Julian or Gregorian calendars.

    Parameters:
        yr        : year
        gregorian : If True, use Gregorian calendar, else use Julian calendar (default: True)

    Return:
        month
        day

   Julian formula found in Meeus.
   Gregorian formula taken from Wikipedia (for the formula published in Nature, April 20th, 1876)
--]]
local function easter(yr, gregorian)
    local a, b,c, d, e, tmp
    if gregorian == nil then gregorian = true end
    yr = math.floor(yr)
    if gregorian then
        a = yr % 19
        b = math.floor(yr / 100)
        c = yr % 100
        d = math.floor(b / 4)
        e = b % 4
        local f = math.floor((b + 8) / 25)
        local g = math.floor((b - f + 1) / 3)
        local h = (19 * a + b - d - g + 15) % 30
        local i = math.floor(c / 4)
        local k = c % 4
        local l = (32 + 2 * e + 2 * i - h - k) % 7
        local m = math.floor((a + 11 * h + 22 * l) / 451)
        tmp = h + l - 7 * m + 114
    else
        a = yr % 4
        b = yr % 7
        c = yr % 19
        d = (19 * c + 15) % 30
        e = (2 * a + 4 * b - d + 34) % 7
        tmp = d + e + 114
    end
    local mo = math.floor(tmp / 31)
    local dy = (tmp % 31) + 1
    return mo, dy
end

--[[
Convert a Julian day number to a date in the Julian or Gregorian calendars.

    Parameters:
        jd        : Julian Day number
        gregorian : If True, use Gregorian calendar, else use Julian calendar (default: True)

    Return:
        year
        month
        day (may be fractional)

    Return a tuple (year, month, day).
--]]
local function jd_to_cal(jd, gregorian)
    if gregorian == nil then gregorian = true end
    local F, Z, A, mo, yr

    Z, F = math.modf(jd + 0.5)
    if gregorian then
        local alpha = math.floor((Z - 1867216.25) / 36524.25)
        A = Z + 1 + alpha - math.floor(alpha / 4)
    else
        A = Z
    end

    local B = A + 1524
    local C = math.floor((B - 122.1) / 365.25)
    local D = math.floor(365.25 * C)
    local E = math.floor((B - D) / 30.6001)
    local day = B - D - math.floor(30.6001 * E) + F
    if E < 14 then
        mo = E - 1
    else
        mo = E - 13
    end

    if mo > 2 then
        yr = C - 4716
    else
        yr = C - 4715
    end

    return yr, mo, day
end

--[[Return the day of week for a Julian Day Number.

    The Julian Day Number must be for 0h UT.

    Parameters:
        jd : Julian Day number

    Return:
        day of week: 0 = Sunday...6 = Saturday.

 --]]
local function jd_to_day_of_week(jd)
    local i = jd + 1.5
    return math.floor(i) % 7
end

local function jd_to_date(jd, gregorian)
    local y, month, df = jd_to_cal(jd, gregorian)
    local d, f = math.modf(df)
    local h, m, s = fday_to_hms(f)
    return y, month, d, h, m, s
end

--[[
Is this instant within the Daylight Savings Time period

-- for Europe: last sunday of march 1:00UTC to last sunday of october 1:00UTC

    If astro.globals.daylight_timezone_name is nil, the function always returns false.

    Parameters:
        jd : Julian Day number representing an instant in Universal Time

    Return:
        True if Daylight Savings Time is in effect, False otherwise.
--]]
local function is_dst(jd)
    if not astro.globals.daylight_timezone_name then return false end
    --  What year is this?
    local yr, mon, day = jd_to_cal(jd)
    -- Last day of march
    local start = cal_to_jd(yr, 3, 31)
    -- Back to last sunday
    local dow = jd_to_day_of_week(start)
    if dow then start = start - dow end
    -- Advance to 1AM
    start = start + 1.0 / 24
    -- Before the beginning of the period ?
    if jd < start then return false end

    -- Last day in October
    local stop = cal_to_jd(yr, 10, 31)
    -- Backup to the last Sunday
    dow = jd_to_day_of_week(stop)
    stop = stop - dow
    --  Advance to 1AM
    stop = stop + 1.0 / 24
    -- Before the end of the period ?
    if jd < stop then return true end
    -- After the end of the period
    return false
end

--[[
Return the number of Julian centuries since J2000.0

    Parameters:
        jd : Julian Day number

    Return:
        Julian centuries
--]]
local function jd_to_jcent(jd)
    return (jd - 2451545.0) / 36525.0
end

--[[
Convert local time in Julian Days to a formatted string.

    The general format is:

        YYYY-MMM-DD HH:MM:SS ZZZ

    Truncate the time value to seconds, minutes, hours or days as
    indicated. If level = "day", don't print the time zone string.

    Pass an empty string ("", the default) for zone if you want to do
    your own zone formatting in the calling module.

    Parameters:
        jd    : Julian Day number
        zone  : Time zone string (default = "")
        level : "day" or "hour" or "minute" or "second" (default = "second")

    Return:
        formatted date/time string
--]]
local function lt_to_str(jd, zone, level)
    zone = zone or ""
    level = level or "second"
    local yr, mon, day, fday, iday, hr, mn, sec

    yr, mon, day = jd_to_cal(jd)
    iday, fday = math.modf(day)
    iday = math.floor(iday)
    hr, mn, sec = fday_to_hms(fday)
    sec = math.floor(sec)

    month = astro.globals.month_names[mon]

    if level == "second" then
        return string.format("%d-%s-%02d %02d:%02d:%02d %s", yr, month, iday, hr, mn, sec, zone)
    end

    if level == "minute" then
        return string.format("%d-%s-%02d %02d:%02d %s", yr, month, iday, hr, mn, zone)
    end

    if level == "hour" then
        return string.format("%d-%s-%02d %02d %s", yr, month, iday, hr, zone)
    end

    if level == "day" then
        return string.format("%d-%s-%02d", yr, astro.globals.month_names[mon], iday)
    end

    error("Unknown time level = "..level)
end

--[[
Convert universal time in Julian Days to a local time.

    Include Daylight Savings Time offset, if any.

    Parameters:
        jd : Julian Day number, universal time

    Return:
        Julian Day number, local time
        zone string of the zone used for the conversion
--]]
local function ut_to_lt(jd)
    local zone, offset
    if is_dst(jd) then
        zone   = astro.globals.daylight_timezone_name
        offset = astro.globals.daylight_timezone_offset
    else
        zone   = astro.globals.standard_timezone_name
        offset = astro.globals.standard_timezone_offset
    end
    return jd - offset/24, zone
end

if astro == nil then astro = {} end
astro["calendar"] = {ut_to_lt                = ut_to_lt,
            lt_to_str               = lt_to_str,
            get_current_jd          = get_current_jd,
            jd_to_jcent             = jd_to_jcent,
            jd_to_day_of_week       = jd_to_day_of_week,
            jd_to_cal               = jd_to_cal,
            jd_to_date              = jd_to_date,
            is_leap_year            = is_leap_year,
            is_dst                  = is_dst,
            easter                  = easter,
            pesach                  = pesach,
            moslem_to_christian     = moslem_to_christian,
            christian_to_moslem     = christian_to_moslem,
            day_of_year_to_cal      = day_of_year_to_cal,
            cal_to_day_of_year      = cal_to_day_of_year,
            cal_to_jd               = cal_to_jd
            }
return astro
