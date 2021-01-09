require "astro.moon"
require "astro.calendar"
require "astro.dynamical"

local moon_phase = astro.moon.moon_phase
local lunation   = astro.moon.lunation
local jd_to_cal  = astro.calendar.jd_to_cal
local cal_to_jd  = astro.calendar.cal_to_jd
local lt_to_str  = astro.calendar.lt_to_str
local dt_to_ut   = astro.dynamical.dt_to_ut
local fday_to_hms = astro.util.fday_to_hms

local function usage()
    print("Usage:\n\t"..arg[0]..": year")
end

if #arg ~= 1 then
    usage()
    return
end

local yr = tonumber(arg[1])
-- Find the first new moon of the year
local jdnew = moon_phase(cal_to_jd(yr), 0)

repeat
    local l  = lunation(jdnew)
    local jdsave = jdnew

    local nt = lt_to_str(dt_to_ut(jdnew, "", "minute"))

    jdnew = moon_phase(jdnew+7, 1)
    local qt = lt_to_str(dt_to_ut(jdnew, "", "minute"))

    jdnew = moon_phase(jdnew+7, 2)
    local ft = lt_to_str(dt_to_ut(jdnew, "", "minute"))

    jdnew = moon_phase(jdnew+7, 3)
    local qqt = lt_to_str(dt_to_ut(jdnew, "", "minute"))

    jdnew = moon_phase(jdnew+7, 0)

    -- Duration of the lunation
    local d, i = math.modf(jdnew-jdsave)
    local h, m , s = fday_to_hms(i)

    print(l.." | "..nt.." | "..qt.." | "..ft.." | "..qqt.." | ".. d..":"..h..":"..m)
until jd_to_cal(jdnew) ~= yr
