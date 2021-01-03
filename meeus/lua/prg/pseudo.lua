require "astro.calendar"
require "astro.pseudoscience"

local cal_to_jd = astro.calendar.cal_to_jd
local biorhythm = astro.pseudoscience.biorhythm
local astrology = astro.pseudoscience.astrology

print(biorhythm(cal_to_jd(1973, 4, 28.75)))

local bodies = { "Sun", "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune" }
for i, p in ipairs(bodies) do
    local sign = astrology(p, cal_to_jd(1973, 3, 28.75))
    print(p.." is in "..sign)
end
