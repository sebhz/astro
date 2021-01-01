--[[ Functions to calculate nutation and obliquity values.

The IAU "1980 Theory of Nutation" is used, but terms with coefficients
smaller than 0.0003" have been dropped.

Reference: Jean Meeus, _Astronomical Algorithms_, second edition, 1998, Willmann-Bell, Inc.

The first edition of the Meeus book had some errors in the table. These may be 
corrected in the second edition. I recall correcting my values from those
published in _Explanatory Supplement to the Astronomical Almanac_, revised
edition edited by P. Kenneth Seidelman, 1992

--]]
require "astro.constants"
require "astro.util"
require "astro.calendar"

local polynomial  = astro.util.polynomial
local modpi2      = astro.util.modpi2
local dms_to_d    = astro.util.dms_to_d
local jd_to_jcent = astro.calendar.jd_to_jcent
local pi2         = astro.constants.pi2
local days_per_second = astro.constants.days_per_second

-- [Meeus-1998: table 22.A]
--
--    D, M, M1, F, omega, psiK, psiT, epsK, epsT
--
local _tbl = {
    { 0,  0,  0,  0,  1, -171996, -1742, 92025,  89},
    {-2,  0,  0,  2,  2,  -13187,   -16,  5736, -31},
    { 0,  0,  0,  2,  2,   -2274,    -2,   977,  -5},
    { 0,  0,  0,  0,  2,    2062,     2,  -895,   5},
    { 0,  1,  0,  0,  0,    1426,   -34,    54,  -1},
    { 0,  0,  1,  0,  0,     712,     1,    -7,   0},
    {-2,  1,  0,  2,  2,    -517,    12,   224,  -6},
    { 0,  0,  0,  2,  1,    -386,    -4,   200,   0},
    { 0,  0,  1,  2,  2,    -301,     0,   129,  -1},
    {-2, -1,  0,  2,  2,     217,    -5,   -95,   3},
    {-2,  0,  1,  0,  0,    -158,     0,     0,   0},
    {-2,  0,  0,  2,  1,     129,     1,   -70,   0},
    { 0,  0, -1,  2,  2,     123,     0,   -53,   0},
    { 2,  0,  0,  0,  0,      63,     0,     0,   0},
    { 0,  0,  1,  0,  1,      63,     1,   -33,   0},
    { 2,  0, -1,  2,  2,     -59,     0,    26,   0},
    { 0,  0, -1,  0,  1,     -58,    -1,    32,   0},
    { 0,  0,  1,  2,  1,     -51,     0,    27,   0},
    {-2,  0,  2,  0,  0,      48,     0,     0,   0},
    { 0,  0, -2,  2,  1,      46,     0,   -24,   0},
    { 2,  0,  0,  2,  2,     -38,     0,    16,   0},
    { 0,  0,  2,  2,  2,     -31,     0,    13,   0},
    { 0,  0,  2,  0,  0,      29,     0,     0,   0},
    {-2,  0,  1,  2,  2,      29,     0,   -12,   0},
    { 0,  0,  0,  2,  0,      26,     0,     0,   0},
    {-2,  0,  0,  2,  0,     -22,     0,     0,   0},
    { 0,  0, -1,  2,  1,      21,     0,   -10,   0},
    { 0,  2,  0,  0,  0,      17,    -1,     0,   0},
    { 2,  0, -1,  0,  1,      16,     0,    -8,   0},
    {-2,  2,  0,  2,  2,     -16,     1,     7,   0},
    { 0,  1,  0,  0,  1,     -15,     0,     9,   0},
    {-2,  0,  1,  0,  1,     -13,     0,     7,   0},
    { 0, -1,  0,  0,  1,     -12,     0,     6,   0},
    { 0,  0,  2, -2,  0,      11,     0,     0,   0},
    { 2,  0, -1,  2,  1,     -10,     0,     5,   0},
    { 2,  0,  1,  2,  2,      -8,     0,     3,   0},
    { 0,  1,  0,  2,  2,       7,     0,    -3,   0},
    {-2,  1,  1,  0,  0,      -7,     0,     0,   0},
    { 0, -1,  0,  2,  2,      -7,     0,     3,   0},
    { 2,  0,  0,  2,  1,      -7,     0,     3,   0},
    { 2,  0,  1,  0,  0,       6,     0,     0,   0},
    {-2,  0,  2,  2,  2,       6,     0,    -3,   0},
    {-2,  0,  1,  2,  1,       6,     0,    -3,   0},
    { 2,  0, -2,  0,  1,      -6,     0,     3,   0},
    { 2,  0,  0,  0,  1,      -6,     0,     3,   0},
    { 0, -1,  1,  0,  0,       5,     0,     0,   0},
    {-2, -1,  0,  2,  1,      -5,     0,     3,   0},
    {-2,  0,  0,  0,  1,      -5,     0,     3,   0},
    { 0,  0,  2,  2,  1,      -5,     0,     3,   0},
    {-2,  0,  2,  0,  1,       4,     0,     0,   0},
    {-2,  1,  0,  2,  1,       4,     0,     0,   0},
    { 0,  0,  1, -2,  0,       4,     0,     0,   0},
    {-1,  0,  1,  0,  0,      -4,     0,     0,   0},
    {-2,  1,  0,  0,  0,      -4,     0,     0,   0},
    { 1,  0,  0,  0,  0,      -4,     0,     0,   0},
    { 0,  0,  1,  2,  0,       3,     0,     0,   0},
    { 0,  0, -2,  2,  2,      -3,     0,     0,   0},
    {-1, -1,  1,  0,  0,      -3,     0,     0,   0},
    { 0,  1,  1,  0,  0,      -3,     0,     0,   0},
    { 0, -1,  1,  2,  2,      -3,     0,     0,   0},
    { 2, -1, -1,  2,  2,      -3,     0,     0,   0},
    { 0,  0,  3,  2,  2,      -3,     0,     0,   0},
    { 2, -1,  0,  2,  2,      -3,     0,     0,   0}}

--
-- Constant terms.
-- 
local _kD  = {math.rad(297.85036), math.rad(445267.111480), math.rad(-0.0019142), math.rad( 1.0/189474)}
local _kM  = {math.rad(357.52772), math.rad( 35999.050340), math.rad(-0.0001603), math.rad(-1.0/300000)}
local _kM1 = {math.rad(134.96298), math.rad(477198.867398), math.rad( 0.0086972), math.rad( 1.0/ 56250)}
local _kF  = {math.rad( 93.27191), math.rad(483202.017538), math.rad(-0.0036825), math.rad( 1.0/327270)}
local _ko  = {math.rad(125.04452), math.rad( -1934.136261), math.rad( 0.0020708), math.rad( 1.0/450000)}

-- Return some values needed for both nut_in_lon() and nut_in_obl()
local function _constants(T)
    local D     = modpi2(polynomial(_kD,  T))
    local M     = modpi2(polynomial(_kM,  T))
    local M1    = modpi2(polynomial(_kM1, T))
    local F     = modpi2(polynomial(_kF,  T))
    local omega = modpi2(polynomial(_ko,  T))
    return D, M, M1, F, omega
end

--[[
Return the nutation in longitude. 
    
    High precision. [Meeus-1998: pg 144]
    
    Parameters:
        jd : Julian Day in dynamical time
        
    Returns:
        nutation in longitude, in radians
    
--]]
local function nut_in_lon(jd)
    -- 
    -- Future optimization: factor the /1e5 and /1e6 adjustments into the table.
    --
    -- Could turn the loop into a generator expression. Too messy?
    --
    local T = jd_to_jcent(jd)
    local D, M, M1, F, omega = _constants(T)
    local deltaPsi = 0.0
    for i, v in ipairs(_tbl) do
		local tD, tM, tM1, tF, tomega, tpsiK, tpsiT, tepsK, tepsT = unpack(v)
        local arg = D*tD + M*tM + M1*tM1 + F*tF + omega*tomega
        deltaPsi = deltaPsi + (tpsiK/10000.0 + tpsiT/100000.0 * T) * math.sin(arg)
	end
    return math.rad(deltaPsi/3600)
end

--[[
Return the nutation in obliquity. 
    
    High precision. [Meeus-1998: pg 144]
    
    Parameters:
        jd : Julian Day in dynamical time
        
    Returns:
        nutation in obliquity, in radians
--]]
local function nut_in_obl(jd)
    -- 
    -- Future optimization: factor the /1e5 and /1e6 adjustments into the table.
    --
    -- Could turn the loop into a generator expression. Too messy?
    --
    local T = jd_to_jcent(jd)
    local D, M, M1, F, omega = _constants(T)
    local deltaEps = 0.0;
    for i, v in ipairs(_tbl) do
		local tD, tM, tM1, tF, tomega, tpsiK, tpsiT, tepsK, tepsT= unpack(v)
        local arg = D*tD + M*tM + M1*tM1 + F*tF + omega*tomega
        deltaEps = deltaEps + (tepsK/10000.0 + tepsT/100000.0 * T) * math.cos(arg)
	end
    return math.rad(deltaEps/3600)
end

--
-- Constant terms
-- 
local _el0 = {math.rad(dms_to_d(23, 26,  21.448)), 
        math.rad(dms_to_d( 0,  0, -46.8150)),
        math.rad(dms_to_d( 0,  0,  -0.00059)),
        math.rad(dms_to_d( 0,  0,   0.001813))}

 --[[
 Return the mean obliquity of the ecliptic. 
    
    Low precision, but good enough for most uses. [Meeus-1998: equation 22.2].
    
    Accuracy is 1" over 2000 years and 10" over 4000 years.

    Parameters:
        jd : Julian Day in dynamical time
        
    Returns:
        obliquity, in radians
--]] 
local function obliquity(jd)
    local T = jd_to_jcent(jd)
    return polynomial(_el0, T)
end

--
-- Constant terms
-- 
local _el1 = {math.rad(dms_to_d(23, 26,    21.448)),
        math.rad(dms_to_d( 0,  0, -4680.93)),
        math.rad(dms_to_d( 0,  0,    -1.55)),
        math.rad(dms_to_d( 0,  0,  1999.25)),
        math.rad(dms_to_d( 0,  0,   -51.38)),
        math.rad(dms_to_d( 0,  0,  -249.67)),
        math.rad(dms_to_d( 0,  0,   -39.05)),
        math.rad(dms_to_d( 0,  0,     7.12)),
        math.rad(dms_to_d( 0,  0,    27.87)),
        math.rad(dms_to_d( 0,  0,     5.79)),
        math.rad(dms_to_d( 0,  0,     2.45))}

--[[
Return the mean obliquity of the ecliptic. 
    
    High precision [Meeus-1998: equation 22.3].
    
    Accuracy is 0.01" between 1000 and 3000, and "a few arc-seconds
    after 10,000 years".
    
    Parameters:
        jd : Julian Day in dynamical time
        
    Returns:
        obliquity, in radians
--]]
local function obliquity_high(jd)
    local U = jd_to_jcent(jd) / 100
    return polynomial(_el1, U)
end

local function true_obliquity(jd)
	return obliquity_high(jd) + nut_in_obl(jd)
end
--[[
Return the nutation in right ascension (also called equation of the equinoxes.)
    
    Meeus-1998: page 88.
      
    Parameters:
        jd : Julian Day in dynamical time
        
    Returns:
        nutation, in radians
--]]

local function nut_in_ra(jd)
	local deltapsi = math.deg(nut_in_lon(jd))*3600     -- deltapsi in seconds
	local epsilon  = true_obliquity(jd)                -- Epsilon kept in radians
	local c = deltapsi*math.cos(epsilon)/15            -- result in seconds...
	return (c*pi2*days_per_second)                     --.. converted in radians
end

if astro == nil then astro = {} end
astro["nutation"] = {obliquity        = obliquity,
                     obliquity_high   = obliquity_high,
					 true_obliquity   = true_obliquity,
			         nut_in_obl       = nut_in_obl,
			         nut_in_lon       = nut_in_lon,
			         nut_in_ra        = nut_in_ra}
return astro
			
