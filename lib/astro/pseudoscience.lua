require "astro.calendar"
require "astro.constants"
require "astro.util"

local cal_to_jd       = astro.calendar.cal_to_jd
local seconds_per_day = astro.constants.seconds_per_day
local pi2             = astro.constants.pi2
local round           = astro.util.round
--[[
	Computes the 3 major biorhythms
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

if astro == nil then astro = {} end
astro["pseudoscience"] = { biorhythm = biorhythm }