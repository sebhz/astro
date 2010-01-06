require "astro.calendar"
require "astro.pseudoscience"

local cal_to_jd = astro.calendar.cal_to_jd
local biorhythm = astro.pseudoscience.biorhythm

print(biorhythm(cal_to_jd(1973, 4, 28.75)))