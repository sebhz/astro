--[[
Validate Astrolabe routines against examples given in
_Astronomical Algorithms_ by Jean Meeus, second edition 1998,
Willmann-Bell Inc.

Where testing shows no differences between Meeus and the Astrolabe
results (to the precision printed in Meeus), I have used the report()
routine to verify the results.

In some cases I do show small differences and display these with the
report_diff() routine. The differences do not seem to be of any consequential
sizes, but are inexplicable. I speculate they may be caused by:

    1. Errors in Astrolabe code
    2. Misprints in the book
    3. Differences in math libraries (which seems unlikely, in
        that I get the same values on different platforms)
        
Attached to the bottom of this script is the output I get.
    
Note that Meeus presents a truncated version of VSOP87d and some differences
are to be expected when comparing results with the complete version that
Astrolabe uses. He sometimes prints values are derived from the complete
theory, and we use those where possible.
--]]
require "astro.globals"
require "astro.constants"
require "astro.util"
require "astro.calendar"
require "astro.moon"
require "astro.dynamical"
require "astro.sun"
require "astro.equinox"
require "astro.nutation"
require "astro.riseset"
require "astro.vsop87d"
require "astro.pluto"
require "astro.sidereal"
require "astro.coordinates"
require "astro.kepler"
require "astro.earth"

local pi2             = astro.constants.pi2
local modpi2          = astro.util.modpi2
local hms_to_fday     = astro.util.hms_to_fday
local seconds_per_day = astro.constants.seconds_per_day
local days_per_second = astro.constants.days_per_second
local km_per_au       = astro.constants.km_per_au
local tb_iterator     = astro.util.tb_iterator
local dms_to_d        = astro.util.dms_to_d
local cal_to_jd       = astro.calendar.cal_to_jd
local jd_to_cal       = astro.calendar.jd_to_cal
local round           = astro.util.round

local function report(label, computed, reference, delta, units)
    if math.abs(computed - reference) > delta then
        print("\t"..label)
        print("\t\tERROR:")
        print("\t\t\tcomputed   ="..computed)
        print("\t\t\treference   ="..reference)
        print("\t\t\tdifference ="..math.abs(computed - reference).." "..units)
	end
end
    
function report_diff(label, computed, reference, units)
    print("\t"..label.."\tdifference: "..(computed - reference).." "..units)
end    

--astro.util.load_params()
local sun = astro.sun
local vsop = astro.vsop87d

print("3.1 Interpolate3")
y = astro.util.interpolate3(0.18125, {0.884226, 0.877366, 0.870531})
report("au", y, 0.876125, 1e-6, "au")

print("7.a Convert Gregorian date to Julian day number")
jd = cal_to_jd(1957, 10, 4.81)
report("julian day", jd, 2436116.31, 0.01, "days")

print("7.b Convert Julian date to Julian day number")
jd = cal_to_jd(333, 1, 27.5, false)
report("julian day", jd, 1842713.0, 0.01, "days")

print("7.c Convert Julian day number to Gregorian date")
yr, mo, day = jd_to_cal(2436116.31)
report("year", yr, 1957, 0, "years")
report("month", mo, 10, 0, "months")
report("day", day, 4.81, 0.01, "days")

print("7.c(1) Convert Julian day number to Julian date")
yr, mo, day = jd_to_cal(1842713.0, false)
report("year", yr, 333, 0, "years")
report("month", mo, 1, 0, "months")
report("day", day, 27.5, 0.01, "days")

print("7.c(2) Convert Julian day number to Julian date")
yr, mo, day = jd_to_cal(1507900.13, false)
report("year", yr, -584, 0, "years")
report("month", mo, 5, 0, "months")
report("day", day, 28.63, 0.01, "days")

print("7.d Time interval in days")
jd0 = cal_to_jd(1910, 4, 20.0)
jd1 = cal_to_jd(1986, 2, 9.0)
report("interval", jd1 - jd0, 27689, 0, "days")

print("7.d(1) Time interval in days")
jd = cal_to_jd(1991, 7, 11)
jd = jd + 10000
yr, mo, day = jd_to_cal(jd)
report("year", yr, 2018, 0, "years")
report("month", mo, 11, 0, "months")
report("day", day, 26, 0, "days")

print("7.e Day of the week")
jd = cal_to_jd(1954, 6, 30.0)
report("julian day", jd, 2434923.5, 0, "days")
dow = astro.calendar.jd_to_day_of_week(jd)
report("day of week", dow, 3, 0, "days")

print("7.f Day of the year")
N = astro.calendar.cal_to_day_of_year(1978, 11, 14)
report("day of the year", N, 318, 0, "days")

print("7.g Day of the year")
N = astro.calendar.cal_to_day_of_year(1988, 4, 22)
report("day of the year", N, 113, 0, "days")

print("7(pg 66-1) Day of the year to calendar")
mo, day = astro.calendar.day_of_year_to_cal(1978, 318)
report("month", mo, 11, 0, "months")
report("days", day, 14, 0, "days")

print("7(pg 66-2) Day of the year to calendar")
mo, day = astro.calendar.day_of_year_to_cal(1988, 113)
report("month", mo, 4, 0, "months")
report("day", day, 22, 0, "days")

 tbl = { 
    {1991, 3, 31},
    {1992, 4, 19},
    {1993, 4, 11},
    {1954, 4, 18},
    {2000, 4, 23},
    {1818, 3, 22}}
    
print("8(pg 68) Gregorian Easter (6 times)")
for i,v in pairs(tbl) do
	yr, mo, day = unpack(v)
    xmo, xday = astro.calendar.easter(yr)
    report("month", xmo, mo, 0, "months")
    report("day", xday, day, 0, "days")
end

print("8(pg 69) Julian Easter (3 times)")
for i, yr in ipairs({179, 711, 1243}) do
	mo, day = astro.calendar.easter(yr, false)
    report("month", mo, 4, 0, "months")
    report("day", day, 12, 0, "days")
end

print("9.a Jewish Pesach")
mo, day = astro.calendar.pesach(1990)
report("month", mo, 4, 0, "months")
report("day", day, 10, 0, "days")

print("9.b Julian date of Moslem year 1421 first day")
yr, mo, day = astro.calendar.moslem_to_christian(1421, 1, 1)
report("year", yr, 2000, 0, "months")
report("month", mo, 4, 0, "months")
report("day", day, 6, 0, "days")

print("9.c Moslem date for Aug 13 1991 gregorian")
yr, mo, day = astro.calendar.christian_to_moslem(1991, 8, 13)
report("year", yr, 1412, 0, "months")
report("month", mo, 2, 0, "months")
report("day", day, 2, 0, "days")

print("10.a DeltaT 1990 (pg 78)")
jd = cal_to_jd(1990, 1, 27)
secs = astro.dynamical.deltaT_seconds(jd)
report("seconds", secs, 57, 1, "seconds")

print("10.a DeltaT 1977")
jd = cal_to_jd(1977, 2, 18)
secs = astro.dynamical.deltaT_seconds(jd)
report("seconds", secs, 48, 1, "seconds")

print("10.b DeltaT 333")
jd = cal_to_jd(333, 2, 6)
secs = astro.dynamical.deltaT_seconds(jd)
report("seconds", secs, 6146, 1, "seconds")

print("11.a geographic to geocentric latitude")
a, b, c = astro.earth.geographical_to_geocentric_lat(math.rad(33.35611), 1706)
report("phi sin phi'", round(b, 6), 0.546861, 0, "radians")
report("phi cos phi'", round(c, 6), 0.836339, 0, "radians")

print("11.c geodesic distance")
d = astro.earth.geodesic_distance(math.rad(dms_to_d(-2, 20, 14)), math.rad(dms_to_d(48, 50, 11)), math.rad(dms_to_d(77, 3, 56)), math.rad(dms_to_d(38, 55 ,17)))
report("geodesic distance", d, 6181.628, 0.001, "km")


print("12.a Sidereal time (mean)")
theta0 = astro.sidereal.mean_sidereal_time_greenwich(2446895.5)
fday = astro.util.hms_to_fday(13, 10, 46.3668)
report("sidereal time", theta0 / pi2, fday, 1.0 / (seconds_per_day * 1000), "days")

print("12.a Sidereal time (apparent)")
theta0 = astro.sidereal.apparent_sidereal_time_greenwich(2446895.5)
fday = astro.util.hms_to_fday(13, 10, 46.1351)
report("sidereal time", theta0 / pi2, fday, 1.0 / (seconds_per_day*1000), "days")

print("12.b Sidereal time (mean)")
theta0 = astro.sidereal.mean_sidereal_time_greenwich(2446896.30625)
report("sidereal time", theta0 / pi2, 128.7378734 / 360, 1e-7, "days")

print("13.a Equitorial to ecliptical coordinates")
L, B = astro.coordinates.equ_to_ecl(math.rad(116.328942), math.rad(28.026183), math.rad(23.4392911))
report("longitude", math.deg(L), 113.215630, 1e-6, "degrees")
report("latitude", math.deg(B), 6.684170, 1e-6, "degrees")

print("13.a Ecliptical to equitorial coordinates")
ra, dec = astro.coordinates.ecl_to_equ(math.rad(113.215630), math.rad(6.684170), math.rad(23.4392911))
report("right accension", math.deg(ra), 116.328942, 1e-6, "degrees")
report("declination", math.deg(dec), 28.026183, 1e-6, "degrees")

print("13.b Equitorial to horizontal coordinates")
local t0 = astro.sidereal.apparent_sidereal_time_greenwich(2446896.30625)
local H  = t0-math.rad(astro.util.dms_to_d(77, 3, 56))-math.rad(360*astro.util.hms_to_fday(23, 9, 16.641))
--A, h = astro.coordinates.equ_to_horizontal()
--print(math.deg(modpi2(H)))

print("15.a Rise, Set, Transit")
save_Long = astro.globals.longitude
save_Lat = astro.globals.latitude
astro.globals.longitude = math.rad(71.0833)
astro.globals.latitude = math.rad(42.3333)

ut = cal_to_jd(1988, 3, 20)
raList = {math.rad(40.68021), math.rad(41.73129), math.rad(42.78204)}
decList = {math.rad(18.04761), math.rad(18.44092), math.rad(18.82742)}

jd = astro.riseset.rise(ut, raList, decList, math.rad(-0.5667), astro.constants.days_per_minute)
report("rise, julian days", jd - ut, 0.51766, 1e-5, "days")

jd = astro.riseset.set(ut, raList, decList, math.rad(-0.5667), astro.constants.days_per_minute)
report("set, julian days", jd - ut, 0.12130, 1e-5, "days")

jd = astro.riseset.transit(ut, raList, 1.0 / (60 * 24))
report("transit, julian days", jd - ut, 0.81980, 1e-5, "days")

astro.globals.longitude = save_Long
astro.globals.latitude = save_Lat

print("22.a Nutation (delta psi)")
deltaPsi = astro.nutation.nut_in_lon(2446895.5)
d, m, s = astro.util.d_to_dms(math.deg(deltaPsi))
report("degrees", d, 0, 0, "degrees")
report("minutes", m, 0, 0, "minutes")
report("seconds", s, -3.788, 0.001, "seconds")

print("22.a Nutation (delta epsilon)")
deltaEps = astro.nutation.nut_in_obl(2446895.5)
d, m, s = astro.util.d_to_dms(math.deg(deltaEps))
report("degrees", d, 0, 0, "degrees")
report("minutes", m, 0, 0, "minutes")
report("seconds", s, 9.443, 0.001, "seconds")

print("22.a Nutation (epsilon)")
eps = astro.nutation.obliquity(2446895.5)
d, m, s = astro.util.d_to_dms(math.deg(eps))
report("degrees", d, 23, 0, "degrees")
report("minutes", m, 26, 0, "minutes")
report("seconds", s, 27.407, 0.001, "seconds")

print("22.a Nutation (epsilon - high precision)")
eps = astro.nutation.obliquity_high(2446895.5)
d, m, s = astro.util.d_to_dms(math.deg(eps))
report("degrees", d, 23, 0, "degrees")
report("minutes", m, 26, 0, "minutes")
report("seconds", s, 27.407, 0.001, "seconds")

print("25.a Sun position, low precision")
L, R = sun.longitude_radius_low(2448908.5)
report("longitude", math.deg(L), 199.90988, 1e-5, "degrees")
report("radius", R, 0.99766, 1e-5, "au")
L = sun.apparent_longitude_low(2448908.5, L)
report("longitude", math.deg(L), 199.90895, 1e-5, "degrees")

print("25.b Sun position, high precision")
L, B, R = sun.dimension3(2448908.5)
report_diff("longitude", math.deg(L) * 3600, 199.907372 * 3600, "arc-seconds")
report_diff("latitude", math.deg(B) * 3600, 0.644, "arc-seconds")
report_diff("radius", R * km_per_au, 0.99760775 * km_per_au, "km")
L, B = vsop.vsop_to_fk5(2448908.5, L, B)
report_diff("corrected longitude", math.deg(L) * 3600, 199.907347 * 3600, "arc-seconds")
report_diff("corrected latitude", math.deg(B) * 3600, 0.62, "arc-seconds")
aberration = sun.aberration_low(R)
report("aberration", math.deg(aberration) * 3600, -20.539, 0.001, "arc-seconds")

print("25.b Sun position, high precision (complete theory pg 165)")
report("longitude", math.deg(L) * 3600 * 100, dms_to_d(199, 54, 26.18) * 3600 * 100, 1, "arc-seconds/100")
report("latitude", math.deg(B) * 3600 * 100, 0.72 * 100, 1, "arc-seconds/100")
report("radius", R, 0.99760853, 1e-8, "au")

print("26.a rectangular coordinates of the sun, relative to the mean equinox of the date")
X, Y, Z = astro.sun.rectangular_md(2448908.5)
report_diff("X", X*km_per_au, -0.9379952*km_per_au, "km")
report_diff("Y", Y*km_per_au, -0.3116544*km_per_au, "km")
report_diff("Z", Z*km_per_au, -0.1351215*km_per_au, "km")

print("27.a Approximate solstice")
jd = astro.equinox.equinox_approx(1962, "summer")
report("julian day", jd, 2437837.39245, 1e-5, "days")

print("27.a Exact solstice")
jd = astro.equinox.equinox(2437837.38589, "summer", days_per_second)
report("julian day", jd, cal_to_jd(1962, 6, 21) + astro.util.hms_to_fday(21, 24, 42), 1e-5, "days")

tbl = {
    {1996, 
        {{"spring", 20, hms_to_fday( 8,  4,  7)},
        {"summer",  21, hms_to_fday( 2, 24, 46)},
        {"autumn",  22, hms_to_fday(18,  1,  8)},
        {"winter",  21, hms_to_fday(14,  6, 56)}}},
    {1997,
        {{"spring", 20, hms_to_fday(13, 55, 42)},
        {"summer",  21, hms_to_fday( 8, 20, 59)},
        {"autumn",  22, hms_to_fday(23, 56, 49)},
        {"winter",  21, hms_to_fday(20,  8,  5)}}},
    {1998,
        {{"spring", 20, hms_to_fday(19, 55, 35)},
        {"summer",  21, hms_to_fday(14,  3, 38)},
        {"autumn",  23, hms_to_fday( 5, 38, 15)},
        {"winter",  22, hms_to_fday( 1, 57, 31)}}},
    {1999,
        {{"spring", 21, hms_to_fday( 1, 46, 53)},
        {"summer",  21, hms_to_fday(19, 50, 11)},
        {"autumn",  23, hms_to_fday(11, 32, 34)},
        {"winter",  22, hms_to_fday( 7, 44, 52)}}},
    {2000,
        {{"spring", 20, hms_to_fday( 7, 36, 19)},
        {"summer",  21, hms_to_fday( 1, 48, 46)},
        {"autumn",  22, hms_to_fday(17, 28, 40)},
        {"winter",  21, hms_to_fday(13, 38, 30)}}},
    {2001,
        {{"spring", 20, hms_to_fday(13, 31, 47)},
        {"summer",  21, hms_to_fday( 7, 38, 48)},
        {"autumn",  22, hms_to_fday(23,  5, 32)},
        {"winter",  21, hms_to_fday(19, 22, 34)}}},
    {2002,
        {{"spring", 20, hms_to_fday(19, 17, 13)},
        {"summer",  21, hms_to_fday(13, 25, 29)},
        {"autumn",  23, hms_to_fday( 4, 56, 28)},
        {"winter",  22, hms_to_fday( 1, 15, 26)}}},
    {2003,
        {{"spring", 21, hms_to_fday( 1,  0, 50)},
        {"summer",  21, hms_to_fday(19, 11, 32)},
        {"autumn",  23, hms_to_fday(10, 47, 53)},
        {"winter",  22, hms_to_fday( 7,  4, 53)}}},
    {2004,
        {{"spring", 20, hms_to_fday( 6, 49, 42)},
        {"summer",  21, hms_to_fday( 0, 57, 57)},
        {"autumn",  22, hms_to_fday(16, 30, 54)},
        {"winter",  21, hms_to_fday(12, 42, 40)}}},
    {2005,
        {{"spring", 20, hms_to_fday(12, 34, 29)},
        {"summer",  21, hms_to_fday( 6, 47, 12)},
        {"autumn",  22, hms_to_fday(22, 24, 14)},
        {"winter",  21, hms_to_fday(18, 36, 01)}}}}

months = {["spring"] = 3,  ["summer"] = 6, ["autumn"] = 9, ["winter"] = 12}
       
print("27(pg 182) Exact solstice (40 times)")
for i, t in ipairs(tbl) do
	local yr, s = unpack(t)
	for j, terms in ipairs(s) do
		local season, day, fday = unpack(terms)
		local approx = astro.equinox.equinox_approx(yr, season)
		local jd = astro.equinox.equinox(approx, season, days_per_second)
		report("julian day "..yr.." "..season, jd, cal_to_jd(yr, months[season], day + fday), days_per_second, "days")
	end
end

print("28.a Equation of time")
E = astro.sun.equation_time(2448908.5)
report_diff("equation of time", 240*math.deg(E), 240*3.427351, "seconds")

print("30 Kepler's equation")
local million_ac = { { 0.1, 5,  5.554589 },
                     { 0.2, 5,  6.246908 },
					 { 0.3, 5,  7.134960 },
					 { 0.4, 5,  8.313903 },
					 { 0.5, 5,  9.950063 },
					 { 0.6, 5, 12.356653 },
					 { 0.7, 5, 16.167990 },
					 { 0.8, 5, 22.656579 },
					 { 0.9, 5, 33.344447 },
					 {0.99, 5, 45.361023 },
					 {0.99, 1, 24.725822 },
					 {0.99,33, 89.722155 } }

local milliard_ac = { { 0.99,  2, 32.3610074720 },
                      { 0.999, 6, 49.5696248539 },
                      { 0.999, 7, 52.2702615280 } }					  
for E, M, E0 in tb_iterator(million_ac) do
	local e0, n = astro.kepler.solve_kepler(math.rad(M), E, 1e-7)
	report("eccentric anomaly", math.deg(e0), E0, 1e-6, "degrees")
end

for E, M, E0 in tb_iterator(milliard_ac) do
	local e0, n = astro.kepler.solve_kepler(math.rad(M), E, 1e-11)
	report("eccentric anomaly", math.deg(e0), E0, 1e-10, "degrees")
end

print("32.a Planet position")
L, B, R = vsop.dimension3(2448976.5, "Venus")
report_diff("longitude", math.deg(L) * 3600, 26.11428 * 3600, "arc-seconds")
report_diff("latitude", math.deg(B) * 3600, -2.62070 * 3600, "arc-seconds")
report_diff("radius", R * km_per_au, 0.724603 * km_per_au, "km")

print("33.a Apparent position")
ra, dec = vsop.geocentric_planet(2448976.5, "Venus", math.rad(dms_to_d(0, 0, 16.749)), math.rad(23.439669), days_per_second)
report("ra", math.deg(ra), math.deg(hms_to_fday(21, 4, 41.454) * pi2), 1e-5, "degrees")
report("dec", math.deg(dec), dms_to_d(-18, 53, 16.84), 1e-5, "degrees")

print("37.a (1) heliocentric coordinates of Pluto")
L, B, R = astro.pluto.heliocentric_pluto(2448908.5)
report("latitude",  round(B, 5),  14.587820, 0, "degrees")
report("longitude", round(L, 5), 232.740710, 0, "degrees")
report("radius",    round(R, 6),  29.711111, 0, "au")

print("40.a topocentric right ascension and declination")
ra, decl = astro.coordinates.geocentric_to_topocentric(math.rad(33.356111), 1706, math.rad(116.8625), math.rad(339.530208), math.rad(-15.771083), 0.37276, cal_to_jd(2003, 8, 28.136806))
report("topocentric right ascension",  round(math.deg(ra),4),  339.5356, 0, "degrees")
report("topocentric declination",      round(math.deg(decl),4), -15.775, 0, "degrees")

local elp2000 = astro.elp2000
print("47.a Moon position")
L, B, R = elp2000.dimension3(2448724.5)
report_diff("longitude", math.deg(L) * 3600 * 1000, 133.162655 * 3600 * 1000, "arc-seconds/1000")
report("latitude", math.deg(B), -3.229126, 1e-6, "degrees")
report("radius", R, 368409.7, 0.1, "km")

L = elp2000.dimension(2448724.5, "L")
report_diff("longitude(1)", math.deg(L) * 3600 * 1000, 133.162655 * 3600 * 1000, "arc-seconds/1000")

B = elp2000.dimension(2448724.5, "B")
report("latitude(1)", math.deg(B), -3.229126, 1e-6, "degrees")

R = elp2000.dimension(2448724.5, "R")
report("radius(1)", R, 368409.7, 0.1, "km")

print("47 Moon ascending node longitude")
L = math.deg(astro.moon.mean_ascending_node_longitude(cal_to_jd(1913, 5, 27)))
report("ascending node", L, 0, 10-3, "degrees")
L = math.deg(astro.moon.mean_ascending_node_longitude(cal_to_jd(1922, 9, 16.18)))
report("ascending node", L, 180, 10-3, "degrees")

print("48.a (1) Illuminated fraction of moon's disk (high precision)")
k, khi = astro.moon.illuminated_fraction_high(cal_to_jd(1992, 4, 12), 0)
report("fraction", k, 0.678, 0.001, "percent")
report("angle of bright limb", math.deg(khi), 285,0.1, "degrees")

print("48.a (2) Illuminated fraction of moon's disk (low precision)")
k = astro.moon.illuminated_fraction_low(cal_to_jd(1992, 4, 12), 0)
report("fraction", k, 0.680, 0.001, "percent")

print("49.a New moon")
jd = astro.moon.moon_phase(cal_to_jd(1977, 2, 13), 0)
yr, mo, day = jd_to_cal(jd)
report("year", yr, 1977, 0, "years")
report("month", mo, 2, 0, "months")
report("day", day, 18.15118, 0.00001, "days")

print("49.b Moon last quarter")
jd = astro.moon.moon_phase(cal_to_jd(2044, 1, 19), 3)
yr, mo, day = jd_to_cal(jd)
report("year", yr, 2044, 0, "years")
report("month", mo, 1, 0, "months")
report("day", day, 21.99186, 0.00001, "days")

print("50 Moon apogee")
jd, parallax = astro.moon.apogee_perigee_time_low(cal_to_jd(1988, 10, 1), 1)
report_diff("Apogee time", jd*seconds_per_day/60, 2447442.3537*seconds_per_day/60, "minutes")
report("parallax", parallax, 3240.679, 0, "seconds")

print("50 Moon perigee (p 361)")
jd = astro.moon.apogee_perigee_time_low(cal_to_jd(1997, 12, 9), 0)
report("Perigee time", jd, 2450792.2059, 0, "jd fractions")
jd = astro.moon.apogee_perigee_time_low(cal_to_jd(1998, 1, 3), 0)
report("Perigee time", jd, 2450816.8549, 0, "jd fractions")
jd = astro.moon.apogee_perigee_time_low(cal_to_jd(1990, 12, 2), 0)
report("Perigee time", jd, 2448227.9505, 0, "jd fractions")
jd = astro.moon.apogee_perigee_time_low(cal_to_jd(1990, 12, 30), 0)
report("Perigee time", jd, 2448256.4941, 0, "jd fractions")

print("51.a Moon ascending node time")
jd = astro.moon.node(cal_to_jd(1987, 5, 15), 0)
report("Ascending node", jd, 2446938.76803, 1e-5, "jd fraction")
