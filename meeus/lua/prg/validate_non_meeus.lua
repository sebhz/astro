require "astro.moon"
require "astro.util"
require "astro.calendar"
require "astro.globals"
require "astro.locations"

local cal_to_jd       = astro.calendar.cal_to_jd
local jd_to_cal       = astro.calendar.jd_to_cal
local jd_to_date       = astro.calendar.jd_to_date
local fday_to_hms     = astro.util.fday_to_hms
local set_location    = astro.locations.set_location

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
    print("\t"..label.." -- difference: "..(computed - reference).." "..units.." (expected)")
end


print("Lunation number")
l = astro.moon.lunation(cal_to_jd(2004, 1, 22), "brown")
report("lunation", l, 1003, 0, "lunations")
l = astro.moon.lunation(cal_to_jd(2004, 2, 21), "brown")
report("lunation", l, 1004, 0, "lunations")
l = astro.moon.lunation(cal_to_jd(2009, 3, 26), "brown")
report("lunation", l, 1066, 0, "lunations")
l = astro.moon.lunation(cal_to_jd(2009, 3, 26.6736), "brown")
report("lunation", l, 1067, 0, "lunations")

print("Hour angle to degree")
d = astro.util.hangle_to_d(24, 0, 0)
report("angle", d, 0, 0, "degrees")
d = astro.util.hangle_to_d(12, 0, 0)
report("angle", d, 180, 0, "degrees")
d = astro.util.hangle_to_d(18, 30, 0)
report("angle", d, 277.5, 0, "degrees")

print("Moon rise and set")
set_location("Paris", "France")
r, s = astro.moon.riseset(cal_to_jd(2009, 6 , 7))

report("rise", r, 2454990.3398684, 1e-7, "JD")
report("set",  s, 2454989.6255844, 1e-7, "JD")
