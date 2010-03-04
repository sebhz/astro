require "astro.calendar"
require "astro.pseudoscience"

local cal_to_jd = astro.calendar.cal_to_jd
local biorhythm = astro.pseudoscience.biorhythm
local astrology = astro.pseudoscience.astrology

print(biorhythm(cal_to_jd(1973, 4, 28.75)))

astrology()
astrology(cal_to_jd(1973, 4, 28.75))
