-- Calculate the times of solstice and equinox events for Earth
require "astro.constants"
require "astro.util"
require "astro.calendar"
require "astro.sun"
require "astro.vsop87d"
require "astro.nutation"

local jd_to_jcent = astro.calendar.jd_to_jcent
local polynomial  = astro.util.polynomial
local diff_angle  = astro.util.diff_angle
local sun         = astro.sun
local vsop_to_fk5 = astro.vsop87d.vsop_to_fk5
local pi2         = astro.constants.pi2
local nut_in_lon  = astro.nutation.nut_in_lon
--
-- Meeus-1998 Table 27.A
--
local _approx_1000 = {
    ["spring"]={1721139.29189, 365242.13740,  0.06134,  0.00111, -0.00071},
    ["summer"]={1721233.25401, 365241.72562, -0.05323,  0.00907, -0.00025},
    ["autumn"]={1721325.70455, 365242.49558, -0.11677, -0.00297,  0.00074},
    ["winter"]={1721414.39987, 365242.88257, -0.00769, -0.00933, -0.00006}}

--
-- Meeus-1998 Table 27.B
--
local _approx_3000 = {
    ["spring"]={2451623.80984, 365242.37404,  0.05169, -0.00411, -0.00057},
    ["summer"]={2451716.56767, 365241.62603,  0.00325,  0.00888, -0.00030},
    ["autumn"]={2451810.21715, 365242.01767, -0.11575,  0.00337,  0.00078},
    ["winter"]={2451900.05952, 365242.74049, -0.06223, -0.00823,  0.00032}}

--
-- Meeus-1998 Table 27.C
--
local _terms = {
    {485, math.rad(324.96),  math.rad(  1934.136)},
    {203, math.rad(337.23),  math.rad( 32964.467)},
    {199, math.rad(342.08),  math.rad(    20.186)},
    {182, math.rad( 27.85),  math.rad(445267.112)},
    {156, math.rad( 73.14),  math.rad( 45036.886)},
    {136, math.rad(171.52),  math.rad( 22518.443)},
    { 77, math.rad(222.54),  math.rad( 65928.934)},
    { 74, math.rad(296.72),  math.rad(  3034.906)},
    { 70, math.rad(243.58),  math.rad(  9037.513)},
    { 58, math.rad(119.81),  math.rad( 33718.147)},
    { 52, math.rad(297.17),  math.rad(   150.678)},
    { 50, math.rad( 21.02),  math.rad(  2281.226)},
    { 45, math.rad(247.54),  math.rad( 29929.562)},
    { 44, math.rad(325.15),  math.rad( 31555.956)},
    { 29, math.rad( 60.93),  math.rad(  4443.417)},
    { 18, math.rad(155.12),  math.rad( 67555.328)},
    { 17, math.rad(288.79),  math.rad(  4562.452)},
    { 16, math.rad(198.04),  math.rad( 62894.029)},
    { 14, math.rad(199.76),  math.rad( 31436.921)},
    { 12, math.rad( 95.39),  math.rad( 14577.848)},
    { 12, math.rad(287.11),  math.rad( 31931.756)},
    { 12, math.rad(320.81),  math.rad( 34777.259)},
    {  9, math.rad(227.73),  math.rad(  1222.114)},
    {  8, math.rad( 15.45),  math.rad( 16859.074)}}
    
--[[
Returns the approximate time of a solstice or equinox event.
    
    The year must be in the range -1000...3000. Within that range the
    the error from the precise instant is at most 2.16 minutes.
    
    Parameters:
        yr     : year
        season : one of ("spring", "summer", "autumn", "winter")
    
    Returns:
        Julian Day of the event in dynamical time
    
--]]
local function equinox_approx(yr, season)

    if yr < -1000 or yr > 3000 then error("year is out of range") end
	local Y, tbl
	
    yr = math.floor(yr)
    if yr > -1000 and yr <= 1000 then
        Y = yr / 1000.0
        tbl = _approx_1000
    else
        Y = (yr - 2000) / 1000.0
        tbl = _approx_3000
	end
	
    local jd = polynomial(tbl[season], Y)
    local T = jd_to_jcent(jd)
    local W = math.rad(35999.373 * T - 2.47)
    local delta_lambda = 1 + 0.0334 * math.cos(W) + 0.0007 * math.cos(2 * W)

	local S = 0
	for i, v in ipairs(_terms) do
		S = S + v[1] * math.cos(v[2]+v[3]*T)
	end
	jd = jd + 0.00001*S/delta_lambda
	
    return jd
end

local _circle = { 
    ["spring"] = 0.0,
    ["summer"] = math.pi * 0.5,
    ["autumn"] = math.pi,
    ["winter"] = math.pi * 1.5}

_k_sun_motion = 365.25 / pi2

--[[
    Return the precise moment of an equinox or solstice event on Earth.
    
    Parameters:
        jd     : Julian Day of an approximate time of the event in dynamical time
        season : one of ("spring", "summer", "autumn", "winter")
        delta  : the required precision in days. Times accurate to a second are
            reasonable when using the VSOP model.
        
    Returns:
        Julian Day of the event in dynamical time
--]]
local function equinox(jd, season, delta)
    --
    -- If we knew that the starting approximate time was close enough
    -- to the actual time, we could pull nut_in_lon() and the aberration
    -- out of the loop and save some calculating.
    --
    local circ = _circle[season]

    for k =1, 20 do
        local jd0 = jd
        local L, B, R = sun.dimension3(jd)
        L = L+astro.nutation.nut_in_lon(jd) + sun.aberration_low(R)
        L, B = vsop_to_fk5(jd, L, B)
        -- Meeus uses jd + 58 * sin(diff(...))
        jd = jd+diff_angle(L, circ) * _k_sun_motion
        if math.abs(jd - jd0) < delta then 
            return jd
		end
	end
    error("bailout")
end

if astro == nil then astro = {} end
astro["equinox"] = {equinox_approx = equinox_approx,
                    equinox        = equinox}
return astro