--[[
Geocentric solar position and radius, low precision.
--]]
require "astro.util"
require "astro.calendar"
require "astro.vsop87d"
require "astro.nutation"
require "astro.coordinates"

local polynomial  = astro.util.polynomial
local modpi2      = astro.util.modpi2
local dms_to_d    = astro.util.dms_to_d
local jd_to_jcent = astro.calendar.jd_to_jcent
local vsop87d     = astro.vsop87d
local vsop_to_fk5 = astro.vsop87d.vsop_to_fk5
local obliquity_high = astro.nutation.obliquity_high
local true_obliquity = astro.nutation.true_obliquity
local nut_in_lon = astro.nutation.nut_in_lon
local ecl_to_equ = astro.coordinates.ecl_to_equ

--[[
Return one of geocentric ecliptic longitude, latitude and radius.
        Parameters:
            jd : Julian Day in dynamical time
            dim : one of "L" (longitude) or "B" (latitude) or "R" (radius).

        Returns:
            Either longitude in radians, or
            latitude in radians, or
            radius in au.
--]]
local function dimension(jd, dim)
    local X = vsop87d.dimension(jd, "Earth", dim)
    if dim == "L" then
        X = modpi2(X + math.pi)
    elseif dim == "B" then
        X = -X
    end
    return X
end

--[[
Return geocentric ecliptic longitude, latitude and radius.

        Parameters:
            jd : Julian Day in dynamical time

        Returns:
            longitude in radians
            latitude in radians
            radius in au

  --]]
local function dimension3(jd)
    local L = dimension(jd, "L")
    local B = dimension(jd, "B")
    local R = dimension(jd, "R")
    return L, B, R
end

--
-- Constant terms
---
local _kL0 = {math.rad(280.46646),  math.rad(36000.76983),  math.rad( 0.0003032)}
local _kM  = {math.rad(357.52911),  math.rad(35999.05029),  math.rad(-0.0001537)}
local _kC  = {math.rad(  1.914602), math.rad(   -0.004817), math.rad(-0.000014)}

local _ck3 = math.rad( 0.019993)
local _ck4 = math.rad(-0.000101)
local _ck5 = math.rad( 0.000289)

-- Return geometric longitude and radius vector.
-- Low precision. The longitude is accurate to 0.01 degree.
-- The latitude should be presumed to be 0.0. [Meeus-1998: equations 25.2 through 25.5
--    Parameters:
--        jd : Julian Day in dynamical time
--
--    Returns:
--        longitude in radians
--        radius in au
--
local function longitude_radius_low(jd)
    local T = jd_to_jcent(jd)
    local L0 = polynomial(_kL0, T)
    local M = polynomial(_kM, T)
    local e = polynomial({0.016708634, -0.000042037, -0.0000001267}, T)
    local C = polynomial(_kC, T) * math.sin(M)
        + (_ck3 - _ck4 * T) * math.sin(2 * M)
        + _ck5 * math.sin(3 * M)
    local L = modpi2(L0 + C)
    local v = M + C
    local R = 1.000001018 * (1 - e * e) / (1 + e * math.cos(v))
    return L, R
end

--
-- Constant terms
--
local _lk0 = math.rad(125.04)
local _lk1 = math.rad(1934.136)
local _lk2 = math.rad(0.00569)
local _lk3 = math.rad(0.00478)

-- Correct the geometric longitude for nutation and aberration.
--    Low precision. [Meeus-1998: pg 164]
--
--    Parameters:
--        jd : Julian Day in dynamical time
--        L : longitude in radians
--    Returns:
--        corrected longitude in radians
--
local function apparent_longitude_low(jd, L)
    local T = jd_to_jcent(jd)
    local omega = _lk0 - _lk1 * T
    return modpi2(L - _lk2 - _lk3 * math.sin(omega))
end

--
-- Constant terms
--
local _lk4 = math.rad(dms_to_d(0, 0, 20.4898))

-- Correct for aberration; low precision, but good enough for most uses.
--
--    [Meeus-1998: pg 164]
--
--    Parameters:
--        R : radius in au
--
--    Returns:
--        correction in radians
local function aberration_low(R)
    return -_lk4 / R
end

--[[
Returns the rectangular coordinates of the sun, relative to the mean equinox of the day
--]]
local function rectangular_md(jd)
    local L, B, R = dimension3(jd)
    L, B = vsop_to_fk5(jd, L, B)
    local e = obliquity_high(jd)
    local X = R*math.cos(B)*math.cos(L)
    local Y = R*(math.cos(B)*math.sin(L)*math.cos(e) - math.sin(B)*math.sin(e))
    local Z = R*(math.cos(B)*math.sin(L)*math.sin(e) + math.sin(B)*math.cos(e))
    return X, Y, Z
end

--[[
    Returns the equation of time at JD
    parameters:
        jd: julian day in dynamic time

    Returns:
        Equation of time in radians (2Pi radians = 24 hours)
--]]
local function equation_time(jd)
    local tau = jd_to_jcent(jd)/10
    local _p = {280.4664567, 360007.6982779, 0.03032028, 1/49931, -1/15300, -1/2000000}
    local L0 = modpi2(math.rad(polynomial(_p, tau)))
    local L, B, R = dimension3(jd)

    L, B = vsop_to_fk5(jd, L, B)
    epsilon    = true_obliquity(jd)
    deltaPsi   = nut_in_lon(jd)
    asc        = ecl_to_equ(L, B, epsilon)
    return L0 - math.rad(0.0057183) - asc + deltaPsi*math.cos(epsilon)
end

if astro == nil then astro = {} end
astro["sun"] = {dimension3     = dimension3,
                dimension      = dimension,
                aberration_low = aberration_low,
                apparent_longitude_low = apparent_longitude_low,
                longitude_radius_low = longitude_radius_low,
                rectangular_md  = rectangular_md,
                equation_time   = equation_time}
return astro