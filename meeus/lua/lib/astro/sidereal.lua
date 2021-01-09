--[[ Sidereal time at Greenwich

Reference: Jean Meeus, _Astronomical Algorithms_, second edition, 1998, Willmann-Bell, Inc.

--]]
require "astro.util"
require "astro.calendar"
require "astro.nutation"

local modpi2      = astro.util.modpi2
local jd_to_jcent = astro.calendar.jd_to_jcent
local nut_in_lon  = astro.nutation.nut_in_lon
local nut_in_obl  = astro.nutation.nut_in_obl
local obliquity_high = astro.nutation.obliquity_high
local nut_in_ra      = astro.nutation.nut_in_ra

--[[
Return the mean sidereal time at Greenwich.

    The Julian Day number must represent Universal Time.

    Parameters:
        jd : Julian Day number

    Return:
        sidereal time in radians (2pi radians = 24 hrs)
--]]
local function mean_sidereal_time_greenwich(jd)
    local T = jd_to_jcent(jd)
    local T2 = T * T
    local T3 = T2 * T
    local theta0 = 280.46061837 + 360.98564736629 * (jd - 2451545.0)  + 0.000387933 * T2 - T3 / 38710000
    local result = math.rad(theta0)
    return modpi2(result)
end

--[[
Return the apparent sidereal time at Greenwich.

    The Julian Day number must represent Universal Time.

    Parameters:
        jd : Julian Day number

    Return:
        sidereal time in radians (2pi radians = 24 hrs)
--]]
local function apparent_sidereal_time_greenwich(jd)
    -- Nutation in right ascension should be computed from the DT julian date - we neglect the difference here
    return modpi2(mean_sidereal_time_greenwich(jd)+nut_in_ra(jd))
end

if astro == nil then astro = {} end
astro["sidereal"] = {mean_sidereal_time_greenwich     = mean_sidereal_time_greenwich,
                     apparent_sidereal_time_greenwich = apparent_sidereal_time_greenwich}
return astro
