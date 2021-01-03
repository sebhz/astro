-- Useful constants.
-- Don't change these unless you are moving to a new universe.
local pi2 = 2 * math.pi

--
-- Ratio of Earth's polar to equitorial radius.
--
local earth_pol_to_equ_radius = 0.99664719

--
-- Earth flattening
--
local earth_flattening = 1/298.257
--
-- Equitorial radius of the Earth in km.
--
local earth_equ_radius = 6378.14

--
-- How many minutes in a day?
--
local minutes_per_day = 24.0 * 60.0

--
-- How many days in minute?
--
local days_per_minute = 1.0 / minutes_per_day

--
-- How many seconds (time) in a day?
--
local seconds_per_day = 24.0 * 60.0 * 60.0

--
-- How many days in a second?
--
local days_per_second = 1.0 / seconds_per_day

--
-- How many kilometers in an astronomical unit?
--
local km_per_au = 149597870

--
-- For rise-set-transit: altitude deflection caused by refraction
--
local standard_rst_altitude = -0.00989078087105 -- -0.5667 degrees
local sun_rst_altitude = -0.0145438286569       -- -0.8333 degrees

if astro == nil then astro = {} end
astro["constants"] = { sun_rst_altitude      = sun_rst_altitude,
              standard_rst_altitude = standard_rst_altitude,
              km_per_au             = km_per_au,
              days_per_second       = days_per_second,
              seconds_per_day       = seconds_per_day,
              days_per_minute       = days_per_minute,
              minutes_per_day       = minutes_per_day,
              earth_equ_radius      = earth_equ_radius,
              earth_flattening      = earth_flattening,
              earth_pol_to_equ_radius = earth_pol_to_equ_radius,
              pi2                   = pi2}

return astro

