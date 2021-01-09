--[[
The VSOP87d planetary position model """
]]--
require "astro.constants"
require "astro.calendar"
require "astro.util"
require "astro.globals"
require "astro.vsop87d_data"
require "astro.coordinates"

local pi2         = astro.constants.pi2
local jd_to_jcent = astro.calendar.jd_to_jcent
local dms_to_d    = astro.util.dms_to_d
local modpi2      = astro.util.modpi2
local polynomial  = astro.util.polynomial
local diff_angle  = astro.util.diff_angle
local ecl_to_equ  = astro.coordinates.ecl_to_equ
local _planets    = vsop87d_data._planets

--[[
Return one of heliocentric ecliptic longitude, latitude and radius.
        [Meeus-1998: pg 218]

        Parameters:
            jd : Julian Day in dynamical time
            planet : must be one of ("Mercury", "Venus", "Earth", "Mars",
                "Jupiter", "Saturn", "Uranus", "Neptune")
            dim : must be one of "L" (longitude) or "B" (latitude) or "R" (radius)

        Returns:
            longitude in radians, or
            latitude in radians, or
            radius in au

        """
--]]
local function dimension(jd, planet, dim)
    local X = 0.0
    local tauN = 1.0
    local tau = jd_to_jcent(jd) / 10.0
    local c = _planets[planet][dim]

    -- To do: write a proper iterator for this one
    for i, series in ipairs(c) do
        local seriesSum = 0
        for j, s in ipairs(series) do
            local A, B, C = unpack(s)
            seriesSum = seriesSum + A*math.cos(B+C*tau)
        end
        X = X+seriesSum*tauN
        tauN = tauN*tau -- last one is wasted
    end
    if dim == "L" then X = modpi2(X) end

    return X
end

--[[
Return heliocentric ecliptic longitude, latitude and radius.

        Parameters:
            jd : Julian Day in dynamical time
            planet : must be one of ("Mercury", "Venus", "Earth", "Mars",
                "Jupiter", "Saturn", "Uranus", "Neptune")

        Returns:
            longitude in radians
            latitude in radians
            radius in au
--]]
local function dimension3(jd, planet)
    local L = dimension(jd, planet, "L")
    local B = dimension(jd, planet, "B")
    local R = dimension(jd, planet, "R")
    return L, B, R
end

--
-- Constant terms
--
local _k0 = math.rad(-1.397)
local _k1 = math.rad(-0.00031)
local _k2 = math.rad(dms_to_d(0, 0, -0.09033))
local _k3 = math.rad(dms_to_d(0, 0,  0.03916))


--[[
Convert VSOP to FK5 coordinates.

    This is required only when using the full precision of the
    VSOP model.

    [Meeus-1998: pg 219]

    Parameters:
        jd : Julian Day in dynamical time
        L : longitude in radians
        B : latitude in radians

    Returns:
        corrected longitude in radians
        corrected latitude in radians
--]]
local function vsop_to_fk5(jd, L, B)
    local T = jd_to_jcent(jd)
    local L1 = polynomial({L, _k0, _k1}, T)
    local cosL1 = math.cos(L1)
    local sinL1 = math.sin(L1)
    local deltaL = _k2 + _k3 * (cosL1 + sinL1) * math.tan(B)
    local deltaB = _k3 * (cosL1 - sinL1)
    return modpi2(L + deltaL), B + deltaB
end

--[[
Calculate the equatorial coordinates of a planet

    The results will be geocentric, corrected for light-time and
    aberration.

    Parameters:
        jd : Julian Day in dynamical time
        planet : must be one of ("Mercury", "Venus", "Earth", "Mars",
            "Jupiter", "Saturn", "Uranus", "Neptune")
        deltaPsi : nutation in longitude, in radians
        epsilon : True obliquity (corrected for nutation), in radians
        delta : desired accuracy, in days

    Returns:
        right accension, in radians
        declination, in radians
--]]
local function geocentric_planet(jd, planet, deltaPsi, epsilon, delta)
    local t = jd
    local l0 = -100.0 -- impossible value
    -- We need to iterate to correct for light-time and aberration.
    -- At most three passes through the loop always nails it.
    -- Note that we move both the Earth and the other planet during
    -- the iteration.
    local ba, l, b
    for bailout = 1, 20 do
        ba = bailout
        -- heliocentric geometric ecliptic coordinates of the Earth
        local L0, B0, R0 = dimension3(t, "Earth")

        -- heliocentric geometric ecliptic coordinates of the planet
        local L, B, R = dimension3(t, planet)

        -- rectangular offset
        local cosB0 = math.cos(B0)
        local cosB = math.cos(B)
        local x = R * cosB * math.cos(L) - R0 * cosB0 * math.cos(L0)
        local y = R * cosB * math.sin(L) - R0 * cosB0 * math.sin(L0)
        local z = R * math.sin(B)        - R0 * math.sin(B0)

        -- geocentric geometric ecliptic coordinates of the planet
        local x2 = x*x
        local y2 = y*y
        l = math.atan2(y, x)
        b = math.atan2(z, math.sqrt(x2 + y2))

        -- distance to planet in AU
        local dist = math.sqrt(x2 + y2 + z*z)

        -- light time in days
        local tau = 0.0057755183 * dist

        if math.abs(diff_angle(l, l0)) < pi2 * delta then break end

        -- adjust for light travel time and try again
        l0 = l
        t = jd - tau
    end
    if ba > 19 then error("bailout") end

    -- transform to FK5 ecliptic and equinox
    l, b = vsop_to_fk5(jd, l, b)

    -- nutation in longitude
    l = l + deltaPsi

    -- equatorial coordinates
    local ra, dec = ecl_to_equ(l, b, epsilon)

    return ra, dec
end

if _VERSION == "Lua 5.3" or _VERSION == "Lua 5.4" then
    unpack = table.unpack
end

if astro == nil then astro = {} end
astro["vsop87d"] = { vsop_to_fk5       = vsop_to_fk5,
                     geocentric_planet = geocentric_planet,
                     dimension3        = dimension3,
                     dimension         = dimension }
return astro
