--[[
Lunar position model ELP2000-82 of Chapront.

The result values are for the equinox of date and have been adjusted
for light-time.

This is the simplified version of Jean Meeus, _Astronomical Algorithms_,
second edition, 1998, Willmann-Bell, Inc.

--]]
require "astro.constants"
require "astro.util"
require "astro.calendar"
require "astro.sun"
require "astro.coordinates"
require "astro.nutation"
require "astro.dynamical"

local tb_iterator                      = astro.util.tb_iterator
local polynomial                       = astro.util.polynomial
local modpi2                           = astro.util.modpi2
local round                            = astro.util.round
local quadratic_interpolation          = astro.util.quadratic_interpolation
local quadratic_roots                  = astro.util.quadratic_roots
local is_leap_year                     = astro.calendar.is_leap_year
local jd_to_jcent                      = astro.calendar.jd_to_jcent
local jd_to_cal                        = astro.calendar.jd_to_cal
local cal_to_day_of_year               = astro.calendar.cal_to_day_of_year
local pi2                              = astro.constants.pi2
local earth_equ_radius                 = astro.constants.earth_equ_radius
local km_per_au                        = astro.constants.km_per_au
local sun                              = astro.sun
local true_obliquity                   = astro.nutation.true_obliquity
local ecl_to_equ                       = astro.coordinates.ecl_to_equ
local equ_to_horiz                     = astro.coordinates.equ_to_horiz
local apparent_sidereal_time_greenwich = astro.sidereal.apparent_sidereal_time_greenwich
local dt_to_ut                         = astro.dynamical.dt_to_ut

-- [Meeus-1998: table 47.A]
--
--    D, M, M1, F, l, r
--
local _tblLR = {
    {0,  0,  1,  0, 6288774, -20905355},
    {2,  0, -1,  0, 1274027,  -3699111},
    {2,  0,  0,  0,  658314,  -2955968},
    {0,  0,  2,  0,  213618,   -569925},
    {0,  1,  0,  0, -185116,     48888},
    {0,  0,  0,  2, -114332,     -3149},
    {2,  0, -2,  0,   58793,    246158},
    {2, -1, -1,  0,   57066,   -152138},
    {2,  0,  1,  0,   53322,   -170733},
    {2, -1,  0,  0,   45758,   -204586},
    {0,  1, -1,  0,  -40923,   -129620},
    {1,  0,  0,  0,  -34720,    108743},
    {0,  1,  1,  0,  -30383,    104755},
    {2,  0,  0, -2,   15327,     10321},
    {0,  0,  1,  2,  -12528,         0},
    {0,  0,  1, -2,   10980,     79661},
    {4,  0, -1,  0,   10675,    -34782},
    {0,  0,  3,  0,   10034,    -23210},
    {4,  0, -2,  0,    8548,    -21636},
    {2,  1, -1,  0,   -7888,     24208},
    {2,  1,  0,  0,   -6766,     30824},
    {1,  0, -1,  0,   -5163,     -8379},
    {1,  1,  0,  0,    4987,    -16675},
    {2, -1,  1,  0,    4036,    -12831},
    {2,  0,  2,  0,    3994,    -10445},
    {4,  0,  0,  0,    3861,    -11650},
    {2,  0, -3,  0,    3665,     14403},
    {0,  1, -2,  0,   -2689,     -7003},
    {2,  0, -1,  2,   -2602,         0},
    {2, -1, -2,  0,    2390,     10056},
    {1,  0,  1,  0,   -2348,      6322},
    {2, -2,  0,  0,    2236,     -9884},
    {0,  1,  2,  0,   -2120,      5751},
    {0,  2,  0,  0,   -2069,         0},
    {2, -2, -1,  0,    2048,     -4950},
    {2,  0,  1, -2,   -1773,      4130},
    {2,  0,  0,  2,   -1595,         0},
    {4, -1, -1,  0,    1215,     -3958},
    {0,  0,  2,  2,   -1110,         0},
    {3,  0, -1,  0,    -892,      3258},
    {2,  1,  1,  0,    -810,      2616},
    {4, -1, -2,  0,     759,     -1897},
    {0,  2, -1,  0,    -713,     -2117},
    {2,  2, -1,  0,    -700,      2354},
    {2,  1, -2,  0,     691,         0},
    {2, -1,  0, -2,     596,         0},
    {4,  0,  1,  0,     549,     -1423},
    {0,  0,  4,  0,     537,     -1117},
    {4, -1,  0,  0,     520,     -1571},
    {1,  0, -2,  0,    -487,     -1739},
    {2,  1,  0, -2,    -399,         0},
    {0,  0,  2, -2,    -381,     -4421},
    {1,  1,  1,  0,     351,         0},
    {3,  0, -2,  0,    -340,         0},
    {4,  0, -3,  0,     330,         0},
    {2, -1,  2,  0,     327,         0},
    {0,  2,  1,  0,    -323,      1165},
    {1,  1, -1,  0,     299,         0},
    {2,  0,  3,  0,     294,         0},
    {2,  0, -1, -2,       0,      8752}}

-- [Meeus-1998: table 47.B]
--
--    D, M, M1, F, b
--
local _tblB = {
    {0,  0,  0,  1, 5128122},
    {0,  0,  1,  1,  280602},
    {0,  0,  1, -1,  277693},
    {2,  0,  0, -1,  173237},
    {2,  0, -1,  1,   55413},
    {2,  0, -1, -1,   46271},
    {2,  0,  0,  1,   32573},
    {0,  0,  2,  1,   17198},
    {2,  0,  1, -1,    9266},
    {0,  0,  2, -1,    8822},
    {2, -1,  0, -1,    8216},
    {2,  0, -2, -1,    4324},
    {2,  0,  1,  1,    4200},
    {2,  1,  0, -1,   -3359},
    {2, -1, -1,  1,    2463},
    {2, -1,  0,  1,    2211},
    {2, -1, -1, -1,    2065},
    {0,  1, -1, -1,   -1870},
    {4,  0, -1, -1,    1828},
    {0,  1,  0,  1,   -1794},
    {0,  0,  0,  3,   -1749},
    {0,  1, -1,  1,   -1565},
    {1,  0,  0,  1,   -1491},
    {0,  1,  1,  1,   -1475},
    {0,  1,  1, -1,   -1410},
    {0,  1,  0, -1,   -1344},
    {1,  0,  0, -1,   -1335},
    {0,  0,  3,  1,    1107},
    {4,  0,  0, -1,    1021},
    {4,  0, -1,  1,     833},
    {0,  0,  1, -3,     777},
    {4,  0, -2,  1,     671},
    {2,  0,  0, -3,     607},
    {2,  0,  2, -1,     596},
    {2, -1,  1, -1,     491},
    {2,  0, -2,  1,    -451},
    {0,  0,  3, -1,     439},
    {2,  0,  2,  1,     422},
    {2,  0, -3, -1,     421},
    {2,  1, -1,  1,    -366},
    {2,  1,  0,  1,    -351},
    {4,  0,  0,  1,     331},
    {2, -1,  1,  1,     315},
    {2, -2,  0, -1,     302},
    {0,  0,  1,  3,    -283},
    {2,  1,  1, -1,    -229},
    {1,  1,  0, -1,     223},
    {1,  1,  0,  1,     223},
    {0,  1, -2, -1,    -220},
    {2,  1, -1, -1,    -220},
    {1,  0,  1,  1,    -185},
    {2, -1, -2, -1,     181},
    {0,  1,  2,  1,    -177},
    {4,  0, -2, -1,     176},
    {4, -1, -1, -1,     166},
    {1,  0,  1, -1,    -164},
    {4,  0,  1, -1,     132},
    {1,  0, -1, -1,    -119},
    {4, -1,  0, -1,     115},
    {2, -2,  0,  1,     107}}

local function _E(T)
    local E = polynomial({1.0, -0.002516, -0.0000074}, T)
    local E2 = E*E

    return E, E2
end
-- Calculate values required by several other functions
local function _constants(T)
    --
    -- Constant terms.
    --
    local _kL1 = {math.rad(218.3164477), math.rad(481267.88123421), math.rad(-0.0015786), math.rad( 1.0/  538841), math.rad(-1.0/ 65194000)}
    local _kD  = {math.rad(297.8501921), math.rad(445267.1114034),  math.rad(-0.0018819), math.rad( 1.0/  545868), math.rad(-1.0/113065000)}
    local _kM  = {math.rad(357.5291092), math.rad( 35999.0502909),  math.rad(-0.0001536), math.rad( 1.0/24490000)}
    local _kM1 = {math.rad(134.9633964), math.rad(477198.8675055),  math.rad( 0.0087414), math.rad( 1.0/   69699), math.rad(-1.0/ 14712000)}
    local _kF  = {math.rad( 93.2720950), math.rad(483202.0175233),  math.rad(-0.0036539), math.rad(-1.0/ 3526000), math.rad( 1.0/863310000)}

    local _kA1 = {math.rad(119.75), math.rad(   131.849)}
    local _kA2 = {math.rad( 53.09), math.rad(479264.290)}
    local _kA3 = {math.rad(313.45), math.rad(481266.484)}
    local L1 = modpi2(polynomial(_kL1, T))
    local D  = modpi2(polynomial(_kD,  T))
    local M  = modpi2(polynomial(_kM,  T))
    local M1 = modpi2(polynomial(_kM1, T))
    local F  = modpi2(polynomial(_kF,  T))

    local A1 = modpi2(polynomial(_kA1, T))
    local A2 = modpi2(polynomial(_kA2, T))
    local A3 = modpi2(polynomial(_kA3, T))

    local E, E2 = _E(T)

    return L1, D, M, M1, F, A1, A2, A3, E, E2
end

-- ELP2000 lunar position calculations
--[[
Return geocentric ecliptic longitude, latitude and radius.

        When we need all three dimensions it is more efficient to combine the
        calculations in one routine.

        Parameters:
            jd : Julian Day in dynamical time

        Returns:
            longitude in radians
            latitude in radians
            radius in km, Earth's center to Moon's center
 --]]

local function dimension3(jd)
    local T = jd_to_jcent(jd)
    local L1, D, M, M1, F, A1, A2, A3, E, E2 = _constants(T)

    --
    -- longitude and radius
    --
    local lsum = 0.0
    local rsum = 0.0
    for i, v in ipairs (_tblLR) do
        local tD, tM, tM1, tF, tl, tr = unpack(v)
        local arg = tD * D + tM * M + tM1 * M1 + tF * F
        if math.abs(tM) == 1 then
            tl = tl*E
            tr = tr*E
        elseif math.abs(tM) == 2 then
            tl = tl*E2
            tr = tr*E2
        end
        lsum = lsum + tl * math.sin(arg)
        rsum = rsum + tr * math.cos(arg)
    end
    --
    -- latitude
    --
    local bsum = 0.0
    for i, v in ipairs (_tblB) do
        local tD, tM, tM1, tF, tb = unpack(v)
        local arg = tD * D + tM * M + tM1 * M1 + tF * F
        if math.abs(tM) == 1 then
            tb = tb*E
        elseif math.abs(tM) == 2 then
            tb = tb*E2
        end
        bsum = bsum + tb * math.sin(arg)
    end

    lsum = lsum + 3958 * math.sin(A1) +
            1962 * math.sin(L1 - F) +
             318 * math.sin(A2)

    bsum = bsum - 2235 * math.sin(L1) +
              382 * math.sin(A3) +
              175 * math.sin(A1 - F) +
              175 * math.sin(A1 + F) +
              127 * math.sin(L1 - M1) -
              115 * math.sin(L1 + M1)

    local longitude = L1 + math.rad(lsum / 1000000)
    local latitude = math.rad(bsum / 1000000)
    local dist = 385000.56 + rsum / 1000
    return longitude, latitude, dist
end

--[[Return the geocentric ecliptic longitude in radians.
 A subset of the logic in dimension3()
--]]
local function _longitude(jd)
    local T = jd_to_jcent(jd)
    local L1, D, M, M1, F, A1, A2, A3, E, E2 = _constants(T)

    local lsum = 0.0
    for i, v in ipairs (_tblLR) do
        local tD, tM, tM1, tF, tl, tr = unpack(v)
        local arg = tD * D + tM * M +tM1 * M1 + tF * F
        if math.abs(tM) == 1 then
            tl = tl*E
        elseif math.abs(tM) == 2 then
            tl = tl*E2
        end
        lsum = lsum + tl * math.sin(arg)
    end

   lsum = lsum +3958 * math.sin(A1) +
                1962 * math.sin(L1 - F) +
                 318 * math.sin(A2)

    local longitude = L1 + math.rad(lsum / 1000000)
    return longitude
end

--[[
Return the geocentric ecliptic latitude in radians.
 A subset of the logic in dimension3()
--]]
local function _latitude(jd)
    local T = jd_to_jcent(jd)
    local L1, D, M, M1, F, A1, A2, A3, E, E2 = _constants(T)

    local bsum = 0.0
    for i, v in ipairs (_tblB) do
        local tD, tM, tM1, tF, tb = unpack(v)
        local arg = tD * D + tM * M + tM1 * M1 + tF * F
        if math.abs(tM) == 1 then
           tb = tb*E
        elseif math.abs(tM) == 2 then
           tb = tb*E2
        end
        bsum = bsum+tb * math.sin(arg)
    end

    bsum = bsum -2235 * math.sin(L1) +
                  382 * math.sin(A3) +
                  175 * math.sin(A1 - F) +
                  175 * math.sin(A1 + F) +
                  127 * math.sin(L1 - M1) -
                  115 * math.sin(L1 + M1)

    local latitude = math.rad(bsum / 1000000)
    return latitude
end

--[[
 Return the geocentric radius in km.
 A subset of the logic in dimension3()
--]]
local function _radius(jd)
    local T = jd_to_jcent(jd)
    local L1, D, M, M1, F, A1, A2, A3, E, E2 = _constants(T)

    local rsum = 0.0
    for i, v in ipairs (_tblLR) do
        local tD, tM, tM1,tF, tl, tr = unpack(v)
        local arg = tD * D + tM * M + tM1 * M1 + tF * F
        if math.abs(tM) == 1 then
            tr = tr*E
        elseif math.abs(tM) == 2 then
            tr = tr*E2
        end
        rsum = rsum+tr * math.cos(arg)
    end
    local dist = 385000.56 + rsum / 1000
    return dist
end

 --[[
 Return one of geocentric ecliptic longitude, latitude and radius.

        Parameters:
            jd : Julian Day in dynamical time
            dim : "L" (longitude") or "B" (latitude) or "R" (radius)

        Returns:
            longitude in radians or
            latitude in radians or
            radius in km, Earth's center to Moon's center

 --]]

local function dimension(jd, dim)
        if dim == "L" then return _longitude(jd) end
        if dim == "B" then return _latitude(jd) end
        if dim == "R" then return _radius(jd) end
        error("unknown dimension = "..dim)
end

--[[
  Simple moon phase calculator adapted from the basic program found at
  http://www.skyandtelescope.com/resources/software/3304911.html.
  This function helps anyone who needs to know the Moon's
  phase (age), distance, and position along the ecliptic on
  any date within several thousand years in the past or future.
  To illustrate its application, Bradley Schaefer applied it
  to a number of famous events influenced by the Moon in
  World War II.  His article appeared in Sky & Telescope for
  April 1994, page 86.
--]]
local function moonfx(jd)
    local v  =(jd-2451550.1)/29.530588853
    local ip = v-math.floor(v)
    local ag = ip*29.530588853 -- Moon's age from new moon in days
    local ip = ip*pi2   -- Converts to radian

    -- Calculate distance from anomalistic phase
    v=(jd-2451562.2)/27.55454988
    local dp = v-math.floor(v)
    dp = dp*pi2
    local di = 60.4-3.3*math.cos(dp)-.6*math.cos(2*ip-dp)-.5*math.cos(2*ip)

    -- Calculate ecliptic latitude from nodal (draconic) phase
    v = (jd-2451565.2)/27.212220817
    local np = v-math.floor(v)
    np = np*pi2
    local la = 5.1*math.sin(np)

    -- Calculate ecliptic longitude from sidereal motion
    v=(jd-2451555.8)/27.321582241
    local rp = v-math.floor(v)
    local lo = 360*rp+6.3*math.sin(dp)+1.3*math.sin(2*ip-dp)+.7*math.sin(2*ip)

    return ag, di*earth_equ_radius, math.rad(la), math.rad(lo)
end

--[[
    Compute the moon phase new, 1st quarter, full, last quarter) around the julian date.
           Parameters:
                jd : Julian Day in dynamical time
        phase: integer between 0 and 0: 0-> new moon, 1-> first quarter, 2-> full moon, 3-> second quarter
    Returns :
         jd for the moon asked

    [Meeus - chapter 49]
--]]
local function moon_phase(jd, phase)
    local _kMean =     {2451550.09766,  29.530588861*1236.85,  0.00015437, -0.000000150, 0.00000000073}
    local _kM    =     {      2.55340,  29.105356700*1236.85, -0.0000014,  -0.00000011}
    local _kM1   =     {    201.56430, 385.816935280*1236.85,  0.0107582,   0.00001238, -0.000000058}
    local _kF    =     {    160.7108,  390.670502848*1236.85, -0.0016118,  -0.00000227, -0.000000011}
    local _kO    =     {    124.7746,   -1.563755880*1236.85,  0.0020672,  -0.00000215}
    local _cor   = {{0.000325, {299.77,  0.107408*1236.85, -0.009173}},
                    {0.000165, {251.88,  0.016321*1236.85}},
                    {0.000164, {251.83, 26.651886*1236.85}},
                    {0.000126, {349.42, 36.412478*1236.85}},
                    {0.000110, { 86.66, 18.206239*1236.85}},
                    {0.000062, {141.74, 53.303771*1236.85}},
                    {0.000060, {207.14,  2.453732*1236.85}},
                    {0.000056, {154.84,  7.306860*1236.85}},
                    {0.000047, { 34.52, 27.261239*1236.85}},
                    {0.000042, {207.19,  0.121824*1236.85}},
                    {0.000040, {291.34,  1.844379*1236.85}},
                    {0.000037, {161.72, 24.198154*1236.85}},
                    {0.000035, {239.56, 25.513099*1236.85}},
                    {0.000023, {331.55,  3.592518*1236.85}}}
    local yr, mo, d = jd_to_cal(jd)
    local n = cal_to_day_of_year(yr, mo, d)

    local f
    if is_leap_year(yr) then f = n/366 else f = n/365 end

    local k = (yr+f-2000)*12.3685
    -- Round to the nearest multiple of 0.25 according to the needed phase
     k = round(k-0.25*phase)+0.25*phase
    local T = k/1236.85
    local mean_phase = polynomial(_kMean, T)

    local E, E2 = _E(T)
    -- M, M1, F, O, new moon, full moon
    local _nf_cor = {{ 0, 1, 0, 0, -0.40720,    -0.40614},
                     { 1, 0, 0, 0,  0.17241*E,   0.17302*E},
                     { 0, 2, 0, 0,  0.01608,     0.01614},
                     { 0, 0, 2, 0,  0.01039,     0.01043},
                     {-1, 1, 0, 0,  0.00739*E,   0.00734*E},
                     { 1, 1, 0, 0, -0.00514*E,  -0.00515*E},
                     { 2, 0, 0, 0,  0.00208*E2,  0.00209*E2},
                     { 0, 1,-2, 0, -0.00111,    -0.00111},
                     { 0, 1, 2, 0, -0.00057,    -0.00057},
                     { 1, 2, 0, 0,  0.00056*E,   0.00056*E},
                     { 0, 3, 0, 0, -0.00042,    -0.00042},
                     { 1, 0, 2, 0,  0.00042*E,   0.00042*E},
                     { 1, 0,-2, 0,  0.00038*E,   0.00038*E},
                     {-1, 2, 0, 0, -0.00024*E,  -0.00024*E},
                     { 0, 0, 0, 1, -0.00017,    -0.00017},
                     { 2, 1, 0, 0, -0.00007,    -0.00007},
                     { 0, 2,-2, 0,  0.00004,     0.00004},
                     { 3, 0, 0, 0,  0.00004,     0.00004},
                     { 1, 1,-2, 0,  0.00003,     0.00003},
                     { 0, 2, 2, 0,  0.00003,     0.00003},
                     { 1, 1, 2, 0, -0.00003,    -0.00003},
                     {-1, 1, 2, 0,  0.00003,     0.00003},
                     {-1, 1,-2, 0, -0.00002,    -0.00002},
                     { 1, 3, 0, 0, -0.00002,    -0.00002},
                     { 0, 4, 0, 0,  0.00002,     0.00002}}

    -- M, M1, F, O, first and last quarters
    local _qq_cor = {{ 0, 1, 0, 0, -0.62801},
                     { 1, 0, 0, 0,  0.17172*E},
                     { 1, 1, 0, 0, -0.01183*E},
                     { 0, 2, 0, 0,  0.00862},
                     { 0, 0, 2, 0,  0.00804},
                     {-1, 1, 0, 0,  0.00454*E},
                     { 2, 0, 0, 0,  0.00204*E2},
                     { 0, 1,-2, 0, -0.00180},
                     { 0, 1, 2, 0, -0.00070},
                     { 0, 3, 0, 0, -0.00040},
                     {-1, 2, 0, 0, -0.00034*E},
                     { 1, 0, 2, 0,  0.00032*E},
                     { 1, 0,-2, 0,  0.00032*E},
                     { 2, 1, 0, 0, -0.00028*E2},
                     { 1, 2, 0, 0,  0.00027*E},
                     { 0, 0, 0, 1, -0.00017},
                     {-1, 1,-2, 0, -0.00005},
                     { 0, 2, 2, 0,  0.00004},
                     { 1, 1, 2, 0, -0.00004},
                     {-2, 1, 0, 0,  0.00004},
                     { 1, 1,-2, 0,  0.00003},
                     { 3, 0, 0, 0,  0.00003},
                     { 0, 2,-2, 0,  0.00002},
                     {-1, 1, 2, 0,  0.00002},
                     { 1, 3, 0, 0, -0.00002}}

    local M  = modpi2(math.rad(polynomial(_kM,  T)))
    local M1 = modpi2(math.rad(polynomial(_kM1, T)))
    local F  = modpi2(math.rad(polynomial(_kF, T)))
    local O  = modpi2(math.rad(polynomial(_kO, T)))

    if phase == 0 then -- New moon
        for kM, kM1, kF, kO, coefn in tb_iterator(_nf_cor) do
            local s = math.sin(kM*M+kM1*M1+kF*F+kO*O)
            mean_phase = mean_phase + s*coefn
        end
    end
    if phase == 2 then -- Full moon
        for kM, kM1, kF, kO, coefn, coeff in tb_iterator(_nf_cor) do
            local s = math.sin(kM*M+kM1*M1+kF*F+kO*O)
            mean_phase = mean_phase + s*coeff
        end
    end

    if phase == 1 or phase == 3 then -- first or last quarters
        for kM, kM1, kF, kO, coef in tb_iterator(_qq_cor) do
            local s = math.sin(kM*M+kM1*M1+kF*F+kO*O)
            mean_phase = mean_phase + s*coef
        end

        local W =  0.00306
                 - 0.00038*E*math.cos(M)
                 + 0.00026*math.cos(M1)
                 - 0.00002*math.cos(M1-M)
                 + 0.00002*math.cos(M1+M)
                 + 0.00002*math.cos(2*F)
        if phase == 3 then W = -W end
        mean_phase = mean_phase +W
    end

    for c, poly in tb_iterator(_cor) do
        mean_phase = mean_phase + c*math.sin(modpi2(math.rad(polynomial(poly, T))))
    end
    return mean_phase
end

--[[
    Compute the moon illuminated fraction and position's angle of the moon's bright limb

    Parameters:
                jd : Julian Day in dynamical time

    Returns :
         f, a (fraction, angle)

    [Meeus - chapter 49]
--]]
local function illuminated_fraction_high(jd)
    local lambda, beta, delta   = dimension3(jd)  -- Moon's geocentric longitude, latitude and radius
    local lambda0, beta0, R     = sun.dimension3(jd) -- Sun's geocentric longitude, latitude and radius

    R = R*km_per_au
    local psi = math.acos(math.cos(beta)*math.cos(lambda-lambda0))
    local i = math.atan2(R*math.sin(psi), delta-R*math.cos(psi))
    local k = (1+math.cos(i))/2

    local o = true_obliquity(jd)
    local asc,  decl  = ecl_to_equ(lambda, beta, o)
    local asc0, decl0 = ecl_to_equ(lambda0, beta0, o)
    local khi = math.atan2(math.cos(decl0)*math.sin(asc0-asc),
                           math.sin(decl0)*math.cos(decl) - math.cos(decl0)*math.sin(decl)*math.cos(asc0-asc))
    return k, modpi2(khi)
end

--[[
    Same as above - lower precision. Simpler algorithm. Does not return the angle of the bright limb
--]]
local function illuminated_fraction_low(jd)
    local T = jd_to_jcent(jd)
    local L1, D, M, M1 = _constants(T)

    local i = (180 - math.deg(D) - 6.289*math.sin(M1)
                                         + 2.100*math.sin(M)
                                         - 1.274*math.sin(2*D-M1)
                                         - 0.658*math.sin(2*D)
                                         - 0.214*math.sin(2*M1)
                                         - 0.110*math.sin(D))
    local k = (1+math.cos(math.rad(i)))/2
    return round(k, 2)
end
--[[
    Returns the longitude of the mean ascending node and of the mean perigee of the moon
    Parameters:
        jd: Julian day (dynamical time)

    Returns
        mean ascending node or mean perigee longitude in radians
--]]
local function mean_ascending_node_longitude(jd)
    local _O = {125.0445479, -1934.1362891, 0.0020754, 1/467441, -1/60616000}
    local T = jd_to_jcent(jd)
    return modpi2(math.rad(polynomial(_O, T)))
end

local function true_ascending_node_longitude(jd)
    local m = mean_ascending_node_longitude(jd)
    local T = jd_to_jcent(jd)
    local L1, D, M, M1, F = _constants(T)
    return modpi2(
           -math.rad(1.4979)*math.sin(2*(D-F))
           -math.rad(0.1500)*math.sin(M)
           -math.rad(0.1226)*math.sin(2*D)
           +math.rad(0.1176)*math.sin(2*F)
           -math.rad(0.0801)*math.sin(2*(M1-F))
           +m)
end

local function mean_perigee_longitude(jd)
    local _P = {83.3532465, 4096.0137287, -0.01032, -1/80053, -1/189999000}
    local T = jd_to_jcent(jd)
    return modpi2(math.rad(polynomial(_P, T)))
end

--[[
    Returns the jd for apogee of perigee, and the corresponding equatorial horizontal parallax
    Parameters:
        jd: Julian day (dynamical time)
        apo_nperi : 1 for an apogee, 0 for a perigee

    Returns
        jd for apogee or perigee
        parallax in seconds
--]]

local function apogee_perigee_time_low(jd, apo_nperi)
    local yr, mo, d = jd_to_cal(jd)
    local n = cal_to_day_of_year(yr, mo, d)
    local f
    if is_leap_year(yr) then f = n/366 else f = n/365 end
    local k = (yr+f-1999.97)*13.2555
    -- Round to the nearest multiple of 0.5 according to apogee or perigee
    k = round(k-0.5*apo_nperi)+0.5*apo_nperi

    local T = k/1325.55
    -- k = T*1325.55
    local _mT = { 2451534.6698,  27.55454989*1325.55, -0.0006691, -0.0000001098, 0.0000000052}
    local _mD = { 171.9179,     335.91060460*1325.55, -0.0100383, -0.00001156,   0.000000055}
    local _mM = { 347.3477,      27.15777210*1325.55, -0.0008130, -0.0000010 }
    local _mF = { 316.6109,     364.52879110*1325.55, -0.0125053, -0.0000148 }
    -- D, M, F, coef - for apogee
    local _mA = { { 2, 0, 0,  0.4392 },
                  { 4, 0, 0,  0.0684 },
                  { 0, 1, 0,  0.0456-0.00011*T },
                  { 2,-1, 0,  0.0426-0.00011*T },
                  { 0, 0, 2,  0.0212 },
                  { 1, 0, 0, -0.0189 },
                  { 6, 0, 0,  0.0144 },
                  { 4,-1, 0,  0.0113 },
                  { 2, 0, 2,  0.0047 },
                  { 1, 1, 0,  0.0036 },
                  { 8, 0, 0,  0.0035 },
                  { 6,-1, 0,  0.0034 },
                  { 2, 0,-2, -0.0034 },
                  { 2,-2, 0,  0.0022 },
                  { 3, 0, 0, -0.0017 },
                  { 4, 0, 2,  0.0013 },
                  { 8,-1, 0,  0.0011 },
                  { 4,-2, 0,  0.0010 },
                  {10, 0, 0,  0.0009 },
                  { 3, 1, 0,  0.0007 },
                  { 0, 2, 0,  0.0006 },
                  { 2, 1, 0,  0.0005 },
                  { 2, 2, 0,  0.0005 },
                  { 6, 0, 2,  0.0004 },
                  { 6,-2, 0,  0.0004 },
                  {10,-1, 0,  0.0004 },
                  { 5, 0, 0, -0.0004 },
                  { 4, 0,-2, -0.0004 },
                  { 0, 1, 2,  0.0003 },
                  {12, 0, 0,  0.0003 },
                  { 2,-1, 2,  0.0003 },
                  { 1,-1, 0, -0.0003 }}
    -- D, M, F, coef - for perigee
    local _mP = { { 2, 0, 0, -1.6769 },
                  { 4, 0, 0,  0.4589 },
                  { 6, 0, 0, -0.1856 },
                  { 8, 0, 0,  0.0883 },
                  { 2,-1, 0, -0.0773 + 0.00019*T },
                  { 0, 1, 0,  0.0502 - 0.00013*T },
                  {10, 0, 0, -0.0460 },
                  { 4,-1, 0,  0.0422 - 0.00011*T },
                  { 6,-1, 0, -0.0256 },
                  {12, 0, 0,  0.0253 },
                  { 1, 0, 0,  0.0237 },
                  { 8,-1, 0,  0.0162 },
                  {14, 0, 0, -0.0145 },
                  { 0, 0, 2,  0.0129 },
                  { 3, 0, 0, -0.0112 },
                  {10,-1, 0, -0.0104 },
                  {16, 0, 0,  0.0086 },
                  {12,-1, 0,  0.0069 },
                  { 5, 0, 0,  0.0066 },
                  { 2, 0, 2, -0.0053 },
                  {18, 0, 0, -0.0052 },
                  {14,-1, 0, -0.0046 },
                  { 7, 0, 0, -0.0041 },
                  { 2, 1, 0,  0.0040 },
                  {20, 0, 0,  0.0032 },
                  { 1, 1, 0, -0.0032 },
                  {16,-1, 0,  0.0031 },
                  { 4, 1, 0, -0.0029 },
                  { 9, 0, 0,  0.0027 },
                  { 4, 0, 2,  0.0027 },
                  { 2,-2, 0, -0.0027 },
                  { 4,-2, 0,  0.0024 },
                  { 6,-2, 0, -0.0021 },
                  {22, 0, 0, -0.0021 },
                  {18,-1, 0, -0.0021 },
                  { 6, 1, 0,  0.0019 },
                  {11, 0, 0, -0.0018 },
                  { 8, 1, 0, -0.0014 },
                  { 4, 0,-2, -0.0014 },
                  { 6, 0 ,2, -0.0014 },
                  { 3, 1, 0,  0.0014 },
                  { 5, 1, 0, -0.0014 },
                  {13, 0, 0,  0.0013 },
                  {20,-1, 0,  0.0013 },
                  { 3, 2, 0,  0.0011 },
                  { 4,-2, 2, -0.0011 },
                  { 1, 2, 0, -0.0010 },
                  {22,-1, 0, -0.0009 },
                  { 0, 0, 4, -0.0008 },
                  { 6, 0,-2,  0.0008 },
                  { 2, 1,-2,  0.0008 },
                  { 0, 2, 0,  0.0007 },
                  { 0,-1, 2,  0.0007 },
                  { 2, 0, 4,  0.0007 },
                  { 0,-2, 2, -0.0006 },
                  { 2, 2,-2, -0.0006 },
                  {24, 0, 0,  0.0006 },
                  { 4, 0,-4,  0.0005 },
                  { 2, 2, 0,  0.0005 },
                  { 1,-1, 0, -0.0004 }}

    local _pA =  {{ 2, 0, 0, -9.147 },
                  { 1, 0, 0, -0.841 },
                  { 0, 0, 2,  0.697 },
                  { 0, 1, 0, -0.656 + 0.0016*T },
                  { 4, 0, 0,  0.355 },
                  { 2,-1, 0,  0.159 },
                  { 1, 1, 0,  0.127 },
                  { 4,-1, 0,  0.065 },
                  { 6, 0, 0,  0.052 },
                  { 2, 1, 0,  0.043 },
                  { 2, 0, 2,  0.031 },
                  { 2, 0,-2, -0.023 },
                  { 2,-2, 0,  0.022 },
                  { 2, 2, 0,  0.019 },
                  { 0, 2, 0, -0.016 },
                  { 6,-1, 0,  0.014 },
                  { 8, 0, 0,  0.010 }}

    local _pP =  {{ 2, 0, 0, 63.224 },
                  { 4, 0, 0, -6.990 },
                  { 2,-1, 0,  2.834-0.0071*T },
                  { 6, 0, 0,  1.927 },
                  { 1, 0, 0, -1.263 },
                  { 8, 0, 0, -0.702 },
                  { 0, 1, 0,  0.696-0.0017*T },
                  { 0, 0, 2, -0,690 },
                  { 4,-1, 0, -0.629+0.0016*T },
                  { 2, 0, 2, -0.392 },
                  {10, 0, 0,  0.297 },
                  { 6,-1, 0,  0.260 },
                  { 3, 0, 0,  0.201 },
                  { 2, 1, 0, -0.161 },
                  { 1, 1, 0,  0.157 },
                  {12, 0, 0, -0.138 },
                  { 8,-1, 0, -0.127 },
                  { 2, 0,-2,  0.104 },
                  { 5, 0, 0, -0.079 },
                  {14, 0, 0,  0.068 },
                  {10,-1, 0,  0.067 },
                  { 4, 1, 0,  0.054 },
                  {12,-1, 0, -0.038 },
                  { 4,-2, 0, -0.038 },
                  { 7, 0, 0,  0.037 },
                  { 4, 0, 2, -0.037 },
                  {16, 0, 0, -0.035 },
                  { 3, 1, 0, -0.030 },
                  { 1,-1, 0,  0.029 },
                  { 6, 1, 0, -0.025 },
                  { 0, 2, 0,  0.023 },
                  {14,-1, 0,  0.023 },
                  { 2, 2, 0, -0.023 },
                  { 6,-2, 0,  0.022 },
                  { 2,-1,-2, -0.021 },
                  { 9, 0, 0, -0.020 },
                  {18, 0, 0,  0.019 },
                  { 6, 0, 2,  0.017 },
                  { 0,-1, 2,  0.014 },
                  {16,-1, 0, -0.014 },
                  { 4, 0,-2,  0.013 },
                  { 8, 1, 0,  0.012 },
                  {11, 0, 0,  0.011 },
                  { 5, 1, 0,  0.010 },
                  {20, 0, 0, -0.010 }}


    local mean_pa = polynomial(_mT, T)
    local D = polynomial(_mD, T)
    local M = polynomial(_mM, T)
    local F = polynomial(_mF, T)

    local _m, _p, parallax
    if apo_nperi == 1 then
        _m = _mA
        _p = _pA
        parallax = 3245.251 -- In arcseconds: 3245".251 according to Meeus table 50.B
    else
        _m = _mP
        _p = _pP
        parallax = 3629.215  -- 3629".215 according to Meeus table 50.B
    end

    local c = 0
    for aD, aM, aF, coef in tb_iterator(_m) do
        c = c+coef*math.sin(math.rad(aD*D+aM*M+aF*F))
    end
    mean_pa = mean_pa + c

    for pD, pM, pF, coef in tb_iterator(_p) do
        parallax = parallax + coef*math.cos(math.rad(pD*D+pM*M+pF*F))
    end

    return round(mean_pa, 4), round(parallax, 3)
end

local function moon_horizontal_parallax(jd)
    local R = dimension(jd, "R")
    return math.asin(math.rad(earth_equ_radius/R))
end

--[[
    Passage of the moon through the nodes
    Parameter
        - jd: julian date
        - desc_not_asc: 0 for the ascending node, 1 for the descending node
    Returns
        - julian day of the closer passage through the node
--]]
local function node(jd, desc_not_asc)
    local yr, mo, d = jd_to_cal(jd)
    local n = cal_to_day_of_year(yr, mo, d)
    local f
    if is_leap_year(yr) then f = n/366 else f = n/365 end
    local k = (yr+f-2000.05)*13.4223
    -- Round to the nearest multiple of 0.5 according to ascending or descending node
    k = round(k-0.5*desc_not_asc)+0.5*desc_not_asc
    local T = k/1342.33
    -- k = T*1342.33
    local _mD  = {183.6380, 331.73735682*1342.33, 0.0014852, 0.00000209, -0.00000001 }
    local _mM  = { 17.4006,  26.82037250*1342.33, 0.0001186, 0.00000006 }
    local _mM1 = { 38.3776, 355.52747313*1342.33, 0.0123499, 0.000014627,-0.000000069 }
    local _mO  = {123.9767,  -1.44098956*1342.33, 0.0020608, 0.00000214, -0.000000016 }
    local _mV  = {299.7500, 132.85,              -0.009173 }
    local D = polynomial(_mD, T)
    local M = polynomial(_mM, T)
    local M1 = polynomial(_mM1, T)
    local O = polynomial(_mO, T)
    local V = polynomial(_mV, T)
    local P = O + 272.75 - 2.3*T
    local E = _E(T)
    -- D, M, M1, coef
    local _mN = { { 0, 0, 1, -0.4721 },
                  { 2, 0, 0, -0.1649 },
                  { 2, 0,-1, -0.0868 },
                  { 2, 0, 1,  0.0084 },
                  { 2,-1, 0, -0.0083*E },
                  { 2,-1,-1, -0.0039*E },
                  { 0, 0 ,2,  0.0034 },
                  { 2, 0,-2, -0.0031 },
                  { 2, 1, 0,  0.0030*E },
                  { 0, 1,-1,  0.0028*E },
                  { 0, 1, 0,  0.0026*E },
                  { 4, 0, 0,  0.0025 },
                  { 1, 0, 0,  0.0024 },
                  { 0, 1, 1,  0.0022*E },
                  { 4, 0,-1,  0.0014 },
                  { 2, 1,-1,  0.0005*E },
                  { 2,-1, 1,  0.0004*E },
                  { 2,-2, 0, -0.0003*E },
                  { 4,-1, 0,  0.0003*E } }


    local node = polynomial( {2451565.1619, 27.212220817*1342.33, 0.0002762, 0.000000021, -0.000000000088}, T )
    node = node + 0.0017*math.sin(math.rad(O)) + 0.0003*math.sin(math.rad(V)) + 0.0003*math.sin(math.rad(P))

    for nD, nM, nM1, coef in tb_iterator(_mN) do
        local c = coef*math.sin(math.rad(nD*D + nM*M+ nM1*M1))
        node = node + c
    end
    return node
end

--[[
    Returns the lunation number
        Parameters
            - JD julian date (DT or UTC)
            - System can be "brown" (from the first 1923 new moon), "meeus" ( from the first 2000 new moon)
               "islamic" (from the beginning of islamic calendar) or "goldstein" (Goldstein system)
        Returns
            - The lunation number
--]]
local function lunation(jd, system)
    if system == nil then system = "brown" end
    -- moon_phase will not always return the closest full moon if we are close to a new moon.
    -- So we take the next and previous full moon, as well as the new moon in between, and determine
    -- the lunation from these three values
    local jdf1 = moon_phase(jd, 2) -- Full moon preceding or following jd
    local jdf2
    if jdf1 <= jd then -- jdf1 is the previous full moon
        jdf2 = moon_phase(jdf1+29, 2) -- jdf2 is the next full moon
    else
        jdf2 = moon_phase(jdf1-29, 2)
        jdf1, jdf2 = jdf2, jdf1
    end
    -- now jdf1 is the previous full moon, and jdf2 the next. Find the new moon between jdf1 and jdf2
    local jdn = moon_phase(jdf1+14, 0)
    local n
    -- Compute n in the brown system
    if jd < jdn then
        n = math.ceil((jdf1 - 2423436.6120014)/29.53058853)
    else
        n = math.ceil((jdf2 - 2423436.6120014)/29.53058853)
    end

    if system == "brown"     then return n end
    if system == "meeus"     then return n-953 end
    if system == "islamic"   then return n+17038 end
    if system == "goldstein" then return n+37105 end
    error("unknown lunation system")
end
--
-- Moon altitude at time JD
--
local function altitude(jd)
    local l, b   = dimension3(jd)
    local o      = true_obliquity(jd)
    local ra, de = ecl_to_equ(l, b, o)
    local H      = apparent_sidereal_time_greenwich(jd) - astro.globals.longitude - ra
    local A, h   = equ_to_horiz(H, de)
    -- h = h+0.7275*moon_horizontal_parallax(jd)-math.rad(34/60) -- Semi-diameter of the moon
    -- TODO - add effect of atmospheric refraction
    return h
end

--
-- Rising and setting time of the mon for julian day JD
--
local function riseset(jd)
    local rise, set, k, nsteps, uroot = nil, nil, 0, 24, false
    local jd_list, v_list = {0, 1, 2}, {}
    for i, v in ipairs(jd_list) do v_list[i] = altitude(jd+v/nsteps) end

    for i=1,nsteps do
        local a, b, c = quadratic_interpolation(jd_list, v_list)
        local s1, s2 = quadratic_roots(a, b, c)

        if s1 and not s2 then uroot = true end -- Very unlikely to ever happen due to the precision used

        if s1 >= 0 and s1 <= 2 then
            local slope = a*s1+b
            local j = jd + (i-1+s1)/nsteps
            local ut = dt_to_ut(j)
             if slope > 0 then rise = ut else set = ut end
            if uroot then k = i; break end
        end

        if s2 >= 0 and s2 <= 2 then
            local slope = a*s2+b
            local j = jd + (i-1+s2)/nsteps
            local ut = dt_to_ut(j)
            if slope > 0 then rise = ut else set = ut end
        end

        if rise and set then k = i; break end

        v_list[1], v_list[2] = v_list[2], v_list[3]
        v_list[3] = altitude(jd+(i+2)/nsteps)
    end
    if uroot then if rise then set = rise else rise = set end end
    return rise, set, k
end

if astro == nil then astro = {} end
astro["elp2000"] = { dimension3 = dimension3,
                     dimension  = dimension }
astro["moon"]  = { moonfx                        = moonfx,
                   moon_phase                    = moon_phase,
                   illuminated_fraction_high     = illuminated_fraction_high,
                   illuminated_fraction_low      = illuminated_fraction_low,
                   mean_ascending_node_longitude = mean_ascending_node_longitude,
                   true_ascending_node_longitude = true_ascending_node_longitude,
                   mean_perigee_longitude        = mean_perigee_longitude,
                   apogee_perigee_time_low       = apogee_perigee_time_low,
                   node                          = node,
                   moon_horizontal_parallax      = moon_horizontal_parallax,
                   lunation                      = lunation,
                   riseset                       = riseset
                   }
return astro