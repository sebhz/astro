require "astro.calendar"
require "astro.constants"
require "astro.util"
require "astro.vsop87d"
require "astro.nutation"
require "astro.coordinates"

local cal_to_jd         = astro.calendar.cal_to_jd
local seconds_per_day   = astro.constants.seconds_per_day
local days_per_second   = astro.constants.days_per_second
local pi2               = astro.constants.pi2
local round             = astro.util.round
local geocentric_planet = astro.vsop87d.geocentric_planet
local nut_in_lon        = astro.nutation.nut_in_lon
local true_obliquity    = astro.nutation.true_obliquity
local equ_to_ecl        = astro.coordinates.equ_to_ecl

--[[
	Computes some  biorhythms
--]]
local function biorhythm(jd_origin, jd_current)
	if jd_current == nil then 
		local d = os.date("*t")
		local fday = (d.hour*3600+d.min*60+d.sec)/seconds_per_day
		jd_current = cal_to_jd(d.year, d.month, d.day+fday)
	end
	
	local t = jd_current-jd_origin
	local physical     = round(math.sin(pi2*t/23), 2)
	local emotional    = round(math.sin(pi2*t/28), 2)
	local intellectual = round(math.sin(pi2*t/33), 2)
	local intuitive    = round(math.sin(pi2*t/38), 2)
	
	return physical, emotional, intellectual, intuitive
end

local function astrology(jd)
	local signs = { "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces" };
	local planets = { "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune" }

	if jd == nil then 
		local d = os.date("*t")
		local fday = (d.hour*3600+d.min*60+d.sec)/seconds_per_day
		jd = cal_to_jd(d.year, d.month, d.day+fday)
	end
	
	local deltaPsi = nut_in_lon(jd)
	local epsilon  = true_obliquity(jd)
	for i, p in ipairs(planets) do
		local ra, decl = geocentric_planet(jd, p, deltaPsi, epsilon, days_per_second)
		local long, lat = equ_to_ecl(ra, decl, epsilon)
		local i = 1+math.floor(math.deg(long)/30)
		print(p.." is in "..signs[i])
	end 
end

if astro == nil then astro = {} end
astro["pseudoscience"] = { biorhythm = biorhythm,
                           astrology = astrology }
