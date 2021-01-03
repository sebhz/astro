require "astro.util"
require "astro.calendar"
require "astro.constants"
require "astro.dynamical"
require "astro.globals"
require "astro.sidereal"
require "astro.coordinates"

local mean_sidereal_time_greenwich = astro.sidereal.mean_sidereal_time_greenwich
local seconds_per_day         = astro.constants.seconds_per_day
local pi2                     = astro.constants.pi2
local earth_equ_radius        = astro.constants.earth_equ_radius
local standard_rst_altitude   = astro.constants.standard_rst_altitude
local deltaT_seconds          = astro.dynamical.deltaT_seconds
local interpolate_angle3      = astro.util.interpolate_angle3
local interpolate3            = astro.util.interpolate3
local diff_angle              = astro.util.diff_angle
local modpi2                  = astro.util.modpi2
local equ_to_horiz            = astro.coordinates.equ_to_horiz
--[[
Compute Rise, Set, and Transit times.

Each of the routines requires three equatorial coordinates for the
object: yesterday, today and tomorrow, all at 0hr UT.

This approach is inadequate for the Moon, which moves too fast to
be accurately interpolated from three daily positions.

Bug: each of the routines drops some events which occur near 0hr UT.

--]]

local _k1 = math.rad(360.985647)

--[[
Return the Julian Day of the rise time of an object.

    Parameters:
        jd      : Julian Day number of the day in question, at 0 hr UT
        raList  : a sequence of three right accension values, in radians,
            for (jd-1, jd, jd+1)
        decList : a sequence of three right declination values, in radians,
            for (jd-1, jd, jd+1)
        h0      : the standard altitude in radians
        delta   : desired accuracy in days. Times less than one minute are
            infeasible for rise times because of atmospheric refraction.

    Returns:
        Julian Day of the rise time

--]]
local function rise(jd, raList, decList, h0, delta)
    local longitude = astro.globals.longitude
    local latitude = astro.globals.latitude
    local THETA0 = mean_sidereal_time_greenwich(jd)
    local deltaT_days = deltaT_seconds(jd) / seconds_per_day

    local cosH0 = (math.sin(h0) - math.sin(latitude) * math.sin(decList[1])) / (math.cos(latitude) * math.cos(decList[1]))
    --
    -- future: return some indicator when the object is circumpolar or always
    -- below the horizon.
    --
    if cosH0 < -1.0 then -- circumpolar
        return nil
    end
    if cosH0 > 1.0 then -- never rises
        return nil
    end

    local H0 = math.acos(cosH0)
    local m0 = (raList[1] + longitude - THETA0) / pi2
    local m = m0 - H0 / pi2  -- this is the only difference between rise() and set()
    if m < 0 then
        m = m+1
    elseif m > 1 then
        m = m-1
    end

    if m < 0 or m > 1 then error("m is out of range = "..m) end
    for bailout=1,20 do
        local m0 = m
        local theta0 = modpi2(THETA0 + _k1 * m)
        local n = m + deltaT_days
        if n <= -1 or n >= 1 then return nil end -- Bug: this is where we drop some events
        local ra = interpolate_angle3(n, raList)
        local dec = interpolate3(n, decList)
        local H = theta0 - longitude - ra
        H = diff_angle(0.0, H)
        local A, h
        A, h = equ_to_horiz(H, dec)
        local dm = (h - h0) / (pi2 * math.cos(dec) * math.cos(latitude) * math.sin(H))
        m = m+dm
        if math.abs(m - m0) < delta then return jd + m end
    end
    error("bailout")
end

--[[ Return the Julian Day of the set time of an object.

    Parameters:
        jd      : Julian Day number of the day in question, at 0 hr UT
        raList  : a sequence of three right accension values, in radians,
            for (jd-1, jd, jd+1)
        decList : a sequence of three right declination values, in radians,
            for (jd-1, jd, jd+1)
        h0      : the standard altitude in radians
        delta   : desired accuracy in days. Times less than one minute are
            infeasible for set times because of atmospheric refraction.

    Returns:
        Julian Day of the set time

 --]]
local function set(jd, raList, decList, h0, delta)
    local longitude = astro.globals.longitude
    local latitude = astro.globals.latitude
    local THETA0 = mean_sidereal_time_greenwich(jd)
    local deltaT_days = deltaT_seconds(jd) / seconds_per_day

    local cosH0 = (math.sin(h0) - math.sin(latitude) * math.sin(decList[1])) / (math.cos(latitude) * math.cos(decList[1]))
    --
    -- future: return some indicator when the object is circumpolar or always
    -- below the horizon.
    --
    if cosH0 < -1.0 then -- circumpolar
        return nil
    end
    if cosH0 > 1.0 then -- never rises
        return nil
    end

    local H0 = math.acos(cosH0)
    local m0 = (raList[1] + longitude - THETA0) / pi2
    local m = m0 + H0 / pi2  -- this is the only difference between rise() and set()
    if m < 0 then
        m = m+1
    elseif m > 1 then
        m = m-1
    end

    if m < 0 or m > 1 then error("m is out of range = "..m) end
    for bailout=1,20 do
        local m0 = m
        local theta0 = modpi2(THETA0 + _k1 * m)
        local n = m + deltaT_days
        if n <= -1 or n >= 1 then return nil end -- Bug: this is where we drop some events
        local ra = interpolate_angle3(n, raList)
        local dec = interpolate3(n, decList)
        local H = theta0 - longitude - ra
        H = diff_angle(0.0, H)
        local A, h
        A, h = equ_to_horiz(H, dec)
        local dm = (h - h0) / (pi2 * math.cos(dec) * math.cos(latitude) * math.sin(H))
        m = m+dm
        if math.abs(m - m0) < delta then return jd + m end
    end
    error("bailout")
end

--[[
Return the Julian Day of the transit time of an object.

    Parameters:
        jd      : Julian Day number of the day in question, at 0 hr UT
        raList  : a sequence of three right accension values, in radians,
            for (jd-1, jd, jd+1)
        delta   : desired accuracy in days.

    Returns:
        Julian Day of the transit time

--]]
local function transit(jd, raList, delta)
    --
    -- future: report both upper and lower culmination, and transits of objects below
    -- the horizon
    --
    local longitude = astro.globals.longitude
    local THETA0 = mean_sidereal_time_greenwich(jd)
    local deltaT_days = deltaT_seconds(jd) / seconds_per_day

    local m = (raList[1] + longitude - THETA0) / pi2
    if m < 0 then
        m = m+1
    elseif m > 1 then
        m = m-1
    end
    if m < 0 or m > 1 then error("m is out of range = "..m) end
    for bailout=1,20 do
        local m0 = m
        local theta0 = modpi2(THETA0 + _k1 * m)
        local n = m + deltaT_days
        if n <=-1 or n >= 1 then return nil end -- Bug: this is where we drop some events
        local ra = interpolate_angle3(n, raList)
        local H = theta0 - longitude - ra
        H = diff_angle(0.0, H)
        local dm = -H/pi2
        m = m+dm
        if math.abs(m - m0) < delta then return jd + m end
    end

    error("bailout")
end

--[[
Return the standard altitude of the Moon.

    Parameters:
        r : Distance between the centers of the Earth and Moon, in km.

    Returns:
        Standard altitude in radians.

--]]
local function moon_rst_altitude(r)
    -- horizontal parallax
    local parallax = math.asin(earth_equ_radius / r)

    return 0.7275 * parallax + standard_rst_altitude
end

if astro == nil then astro = {} end
astro["riseset"] = { moon_rst_altitude = moon_rst_altitude,
                     transit           = transit,
                     set               = set,
                     rise              = rise }
return astro
