--[[
Usage:

    ./solstice.py start_year [stop_year]

Displays the instants of equinoxes and solstices for a range of years.
Times are accurate to one second.

The arguments must be integers.

If one argument is given, the display is for that year.

If two arguments are given, the display is for that range of
years.

--]]

require "astro.constants"
require "astro.calendar"
require "astro.dynamical"
require "astro.equinox"
require "astro.sun"
require "astro.globals"

local days_per_second     = astro.constants.days_per_second
local lt_to_str           = astro.calendar.lt_to_str
local dt_to_ut            = astro.dynamical.dt_to_ut
local equinox_approx, equinox = astro.equinox.equinox_approx, astro.equinox.equinox
local sun                     = astro.sun

local function usage()
    print("Usage:\n\t"..arg[0]..": year1 [year2]")
end

local start, stop

if #arg < 1 then
    usage()
    return
elseif #arg < 2 then
    start = tonumber(arg[1])
    stop  = start
elseif #arg < 3 then
    start = tonumber(arg[1])
    stop = tonumber(arg[2])
else
    usage()
    return
end

for yr = start,stop do
    print(yr)
    for i, season in ipairs(astro.globals.season_names) do
        local approx_jd = equinox_approx(yr, season)
        local jd = equinox(approx_jd, season, days_per_second)
        local ut = dt_to_ut(jd)
        print("\t"..season..": "..lt_to_str(ut))
    end
end
