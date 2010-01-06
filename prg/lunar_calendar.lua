require "astro.calendar"
require "astro.moon"
require "astro.nutation"
require "astro.coordinates"
require "astro.sidereal"
require "astro.globals"
require "astro.dynamical"

local elp2000                      = astro.elp2000
local true_obliquity               = astro.nutation.true_obliquity
local ecl_to_equ                   = astro.coordinates.ecl_to_equ
local equ_to_horiz                 = astro.coordinates.equ_to_horiz
local apparent_sidereal_time_greenwich = astro.sidereal.apparent_sidereal_time_greenwich
local cal_to_jd                    = astro.calendar.cal_to_jd
local jd_to_cal                    = astro.calendar.jd_to_cal
local lt_to_str                    = astro.calendar.lt_to_str
local is_leap_year                 = astro.calendar.is_leap_year
local day_of_year_to_cal           = astro.calendar.day_of_year_to_cal
local cal_to_day_of_year           = astro.calendar.cal_to_day_of_year
local ut_to_lt                     = astro.calendar.ut_to_lt
local dt_to_ut                     = astro.dynamical.dt_to_ut
local lunation                     = astro.moon.lunation
local moon_phase                   = astro.moon.moon_phase
local illuminated_fraction_low     = astro.moon.illuminated_fraction_low

local function usage()
	print("Usage:\n\t"..arg[0]..": year")
end

-- This is probably overkill...
local function get_moon_parameters(jd)
	local l, b, r = elp2000.dimension3(jd)
	local o      = true_obliquity(jd)
	local ra, de = ecl_to_equ(l, b, o)
	local H      = apparent_sidereal_time_greenwich(jd) - astro.globals.longitude - ra
	local A, h   = equ_to_horiz(H, de)
	local lun    = lunation(jd)
	local i      = illuminated_fraction_low(jd)
	return h, r, b, i,lun
end
if #arg ~= 1 then
	usage()
	return
end

local yr = tonumber(arg[1])

-- Fill a table, indexed by day number in the year, containing for each day
-- {lunation, moon altitude, moon distance from earth, moon phase, ascending|descending|nil }
-- Moon phase is computed with low accuracy (day !)
-- Altitude and  distance from Earth computed at  midnight
-- ascending if moon crosses ascending node, descending else
local nd = 365
if is_leap_year(yr) then nd = 366 end

-- First pass to get the lunation, altitude, distance and node
local _l = {}
local jd = cal_to_jd(yr-1, 31, 12)
local h_old, r_old, b_old = get_moon_parameters(cal_to_jd(yr-1, 31, 12))

for d=1,nd do
	local m, day = day_of_year_to_cal(yr, d)
	local jd = cal_to_jd(yr, m, day)
	local h, r, b, i, lun = get_moon_parameters(jd)
	local e, D, node
	if h > h_old then e = "rising"  else  e = "falling" end
	if r > r_old then D = "leaving" else  D = "nearing" end
	if b_old > 0 and b < 0 then node = "descending" end
	if b_old < 0 and b > 0 then node = "ascending" end
	_l[d] = { lun, e, D, i, node}
	b_old, h_old, r_old = b, h, r
end

-- Second pass to get the phases
-- Find the first new moon of the year
local jdnew = moon_phase(cal_to_jd(yr), 0)
if cal_to_jd(jdnew) ~= yr then
	jdnew = moon_phase(cal_to_jd(yr)+15, 0)
end

local jd_end = cal_to_jd(yr, 12, 31)
repeat 
	local d = math.floor(cal_to_day_of_year(jd_to_cal(jdnew)))
	_l[d][6] = "new"
	
	jdnew = moon_phase(jdnew+7, 1)
	if jdnew > jd_end then break end
	d = math.floor(cal_to_day_of_year(jd_to_cal(jdnew)))
	_l[d][6] = "first quarter"

	jdnew = moon_phase(jdnew+7, 2)
	if jdnew > jd_end then break end
	d = math.floor(cal_to_day_of_year(jd_to_cal(jdnew)))
	_l[d][6] = "full"

	jdnew = moon_phase(jdnew+7, 3)
	if jdnew > jd_end then break end
	d = math.floor(cal_to_day_of_year(jd_to_cal(jdnew)))
	_l[d][6] = "last quarter"
		
	jdnew = moon_phase(jdnew+7, 0)
until jd_to_cal(jdnew) ~= yr


for i, v in ipairs(_l) do
		print(i, _l[i][1], _l[i][2], _l[i][3], _l[i][4], _l[i][5], _l[i][6])
end

