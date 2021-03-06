require "astro.util"
require "astro.calendar"

local tb_iterator = astro.util.tb_iterator
local jd_to_jcent = astro.calendar.jd_to_jcent

local _tb = {
    {0, 0,  1, -19799805, 19850055, -5452852, -14974862,  66865439, 68951812},
    {0, 0,  2,    897144, -4954829,  3527812,   1672790, -11827535,  -332538},
    {0, 0,  3,    611149,  1211027, -1050748,    327647,   1593179, -1438890},
    {0, 0,  4,   -341243,  -189585,   178690,   -292153,    -18444,   483220},
    {0, 0,  5,    129287,   -34992,    18650,    100340,    -65977,   -85431},
    {0, 0,  6,    -38164,    30893,   -30697,    -25823,     31174,    -6032},
    {0, 1, -1,     20442,    -9987,     4878,     11248,     -5794,    22161},
    {0, 1,  0,     -4063,    -5071,      226,       -64,      4601,     4032},
    {0, 1,  1,     -6016,    -3336,     2030,      -836,     -1729,      234},
    {0, 1,  2,     -3956,     3039,       69,      -604,      -415,      702},
    {0, 1,  3,      -667,     3572,     -247,      -567,       239,      723},
    {0, 2, -2,      1276,      501,      -57,         1,        67,      -67},
    {0, 2, -1,      1152,     -917,     -122,       175,      1034,     -451},
    {0, 2,  0,       630,    -1277,      -49,      -164,      -129,      504},
    {1, -1, 0,      2571,     -459,     -197,       199,       480,     -231},
    {1, -1, 1,       899,    -1449,      -25,       217,         2,     -441},
    {1, 0, -3,     -1016,     1043,      589,      -248,     -3359,      265},
    {1, 0, -2,     -2343,    -1012,     -269,       711,      7856,    -7832},
    {1, 0, -1,      7042,      788,      185,       193,        36,    45763},
    {1, 0,  0,      1199,     -338,      315,       807,      8663,     8547},
    {1, 0,  1,       418,      -67,     -130,       -43,      -809,     -769},
    {1, 0,  2,       120,     -274,        5,         3,       263,     -144},
    {1, 0,  3,       -60,     -159,        2,        17,      -126,       32},
    {1, 0,  4,       -82,      -29,        2,         5,       -35,      -16},
    {1, 1, -3,       -36,      -29,        2,         3,       -19,       -4},
    {1, 1, -2,       -40,        7,        3,         1,       -15,        8},
    {1, 1, -1,       -14,       22,        2,        -1,        -4,       12},
    {1, 1,  0,         4,       13,        1,        -1,         5,        6},
    {1, 1,  1,         5,        2,        0,        -1,         3,        1},
    {1, 1,  3,        -1,        0,        0,         0,         6,       -2},
    {2, 0, -6,         2,        0,        0,        -2,         2,        2},
    {2, 0, -5,        -4,        5,        2,         2,        -2,       -2},
    {2, 0, -4,         4,       -7,       -7,         0,        14,       13},
    {2, 0, -3,        14,       24,       10,        -8,       -63,       13},
    {2, 0, -2,       -49,      -34,       -3,        20,       136,     -236},
    {2, 0, -1,       163,      -48,        6,         5,       273,     1065},
    {2, 0,  0,         9,      -24,       14,        17,       251,      149},
    {2, 0,  1,        -4,        1,       -2,         0,       -25,       -9},
    {2, 0,  2,        -3,        1,        0,         0,         9,       -2},
    {2, 0,  3,         1,        3,        0,         0,        -8,        7},
    {3, 0, -2,        -3,       -1,        0,         1,         2,      -10},
    {3, 0, -1,         5,       -3,        0,         0,        19,       35},
    {3, 0,  0,         0,        0,        1,         0,        10,        3} }

--[[
    Compute heliocentric coordinates of Pluto.
    Meeus - chapter 37
    will return meaningless results if called for a date before 1885 or after 2099

    Input: jd in dynamic time
    Returns : heliocentric longitude and latitude (relative  to J2000.0 equinox)
              heliocentric radius in AU
--]]
local function heliocentric_pluto(jd)
    local T = jd_to_jcent(jd)
    local J = math.rad(34.35 + 3034.9057*T) -- Mean longitude of Jupiter
    local S = math.rad(50.08 + 1222.1138*T) -- Mean longitude of Saturn
    local P = math.rad(238.96 + 144.9600*T) -- Mean longitude of Pluto

    local l, b, r = 0, 0 , 0

    for i, j, k, Al, Bl, Ab, Bb, Ar, Br in tb_iterator(_tb) do
        local alpha = i*J + j*S + k*P
        local s = math.sin(alpha)
        local c = math.cos(alpha)
        l = l + Al*s + Bl*c
        b = b + Ab*s + Bb*c
        r = r + Ar*s + Br*c
    end
    l = l*1e-6 + 238.958116 + 144.96*T
    b = b*1e-6 - 3.908239
    r = r*1e-7 + 40.7241346

    return l, b, r
end

local function geocentric_pluto(jd)
    local l, b, r = heliocentric_pluto(jd)
    local x = r*math.cos(l)*math.cos(b)
    -- cos e = 0.917482062, sin e = 0.397777156 - e is the mean obliquity of the ecliptic at J2000.0
    local y = r*(math.sin(l)*math.cos(b)*0.917482062 - math.sin(b)*0.397777156)
    local z = r*(math.sin(l)*math.cos(b)*0.397777156 + math.sin(b)*0.917482062)
end

if astro == nil then astro = {} end
astro["pluto"] = { heliocentric_pluto = heliocentric_pluto }
return astro