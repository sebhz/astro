require "astro.constants"
require "astro.util"
require "astro.calendar"
require "astro.dynamical"
require "astro.vsop87d"
require "astro.nutation"
require "astro.coordinates"

local pi2                       = astro.constants.pi2
local dms_to_d                  = astro.util.dms_to_d
local get_current_jd            = astro.calendar.get_current_jd
local jd_to_jcent               = astro.calendar.jd_to_jcent
local ut_to_dt                  = astro.dynamical.ut_to_dt
local dimension3                = astro.vsop87d.dimension3
local vsop_to_fk5               = astro.vsop87d.vsop_to_fk5
local nut_in_lon                = astro.nutation.nut_in_lon
local true_obliquity            = astro.nutation.true_obliquity
local ecl_to_equ                = astro.coordinates.ecl_to_equ
local equ_to_horiz              = astro.coordinates.equ_to_horiz
local get_hour_angle            = astro.coordinates.get_hour_angle

local jd=get_current_jd()
local jde=ut_to_dt(jd)
local te=jd_to_jcent(jde)
local L, B, R = dimension3(jde, "Earth")
local Lsun, Bsun = vsop_to_fk5(jde, L+pi2/2, -B)
-- Lsun is the true longitude - add the effect of nutation
local Lsun_nutated = Lsun + nut_in_lon(jde)
-- ... and add also the effect of aberration (Meeus 25.10)
local Lsun_apparent = Lsun_nutated + math.rad(dms_to_d( 0,  0, -20.4898))/R
-- Get the sun equatoral coordinates
local ra, dec = ecl_to_equ(Lsun_apparent, Bsun, true_obliquity(jde))
-- Now compute our local hour angle
local H = get_hour_angle(jde, ra)
-- And finally get the sun azimuth and ascension
local A, h = equ_to_horiz(H, dec)
print(math.deg(h), math.deg(A))
