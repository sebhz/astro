require "astro.util"
require "astro.earth"
require "astro.sidereal"

local modpi2                           = astro.util.modpi2
local geographical_to_geocentric_lat   = astro.earth.geographical_to_geocentric_lat
local apparent_sidereal_time_greenwich = astro.sidereal.apparent_sidereal_time_greenwich
--[[
Convert ecliptic to equitorial coordinates. 
    
    [Meeus-1998: equations 13.3, 13.4]
    
    Parameters:
        longitude : ecliptic longitude in radians
        latitude : ecliptic latitude in radians
        obliquity : obliquity of the ecliptic in radians
    
    Returns:
        Right accension in radians
        Declination in radians
--]]
local function ecl_to_equ(longitude, latitude, obliquity)
    local cose = math.cos(obliquity)
    local sine = math.sin(obliquity)
    local sinl = math.sin(longitude)
    local ra = modpi2(math.atan2(sinl * cose - math.tan(latitude) * sine, math.cos(longitude)))
    local dec = math.asin(math.sin(latitude) * cose + math.cos(latitude) * sine * sinl)
    return ra, dec
end

--[[
Convert equitorial to horizontal coordinates.
    
    [Meeus-1998: equations 13.5, 13.6]

    Note that azimuth is measured westward starting from the south.
    
    This is not a good formula for using near the poles.
    
    Parameters:
        H : hour angle in radians
        decl : declination in radians
        
    Returns:
        azimuth in radians
        altitude in radians
--]]    
local function equ_to_horiz(H, decl)
    local cosH = math.cos(H)
    local sinLat = math.sin(astro.globals.latitude)
    local cosLat = math.cos(astro.globals.latitude)
    local A = math.atan2(math.sin(H), cosH * sinLat - math.tan(decl) * cosLat)
    local h = math.asin(sinLat * math.sin(decl) + cosLat * math.cos(decl) * cosH)
    return A, h
end

--[[
Convert equitorial to ecliptic coordinates. 
    
    [Meeus-1998: equations 13.1, 13.2]
    
    Parameters:
        ra : right accension in radians
        dec : declination in radians
        obliquity : obliquity of the ecliptic in radians
        
    Returns:
        ecliptic longitude in radians
        ecliptic latitude in radians
--]]
local function equ_to_ecl(ra, dec, obliquity)
    local cose = math.cos(obliquity)
    local sine = math.sin(obliquity)
    local sina = math.sin(ra)
    local longitude = modpi2(math.atan2(sina * cose + math.tan(dec) * sine, math.cos(ra)))
    local latitude = modpi2(math.asin(math.sin(dec) * cose - math.cos(dec) * sine * sina))
    return longitude, latitude
end

--[[
Convert geocentric to topocentric coordinates. 
    
    [Meeus-1998: equations 40.2, 40.3]
    
    Parameters:
        rho: geocentric radius in radians
        H : observer's altitude (above sea level) in meters
        L ; observer longitude (in radians)
        ra : body right ascension in radians
        decl : body declination in radians
        d : body distance (in AU)
        jd : observer's hour angle in radian
        
    Returns:
        topocentric right ascension in radians
        topocentric declination in radians
 --]]
local function geocentric_to_topocentric(phi, H, L, ra, decl, d, jd)
	local sinparallax = math.sin(math.rad(8.794/3600))/d
	
	local ha    = modpi2(apparent_sidereal_time_greenwich(jd) - L - ra)
	local p1, psinp1, pcosp1 = geographical_to_geocentric_lat(phi, H)
	local tmp   = math.cos(decl)-pcosp1*sinparallax*math.cos(ha)
	local da    = math.atan2(-pcosp1*sinparallax*math.sin(ha),                 tmp)
	local tdecl = math.atan2((math.sin(decl)-psinp1*sinparallax)*math.cos(da), tmp)
	
	return ra+da, tdecl
end

if astro == nil then astro = {} end
astro["coordinates"] = {
		 equ_to_ecl                = equ_to_ecl,
		 equ_to_horiz              = equ_to_horiz,
		 ecl_to_equ                = ecl_to_equ,
         geocentric_to_topocentric = geocentric_to_topocentric }
