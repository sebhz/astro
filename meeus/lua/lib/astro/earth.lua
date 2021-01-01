require "astro.constants"

local earth_flattening = astro.constants.earth_flattening
local earth_equ_radius = astro.constants.earth_equ_radius

--[[
	Computes the geodesic distance between two points on the Earth with a ~50 meters precision
  
  Parameters:
	L1, B1 : longitude and latitude of the first point (in radians)
	L2, B2 : longitude and latitude of the second point (in radians)
        
    Returns:
       distance in km
--]]
local function geodesic_distance(L1, B1, L2, B2)
	local F = (B1+B2)/2
	local G = (B1-B2)/2
	local lambda = (L1-L2)/2
	local sF = math.sin(F)
	local cF = math.cos(F)
	local sG = math.sin(G)
	local cG = math.cos(G)
	local sl = math.sin(lambda)
	local cl = math.cos(lambda)
	
	local S = sG*sG*cl*cl+cF*cF*sl*sl
	local C = cG*cG*cl*cl+sF*sF*sl*sl
	
	local omega = math.atan(math.sqrt(S/C))
	local R = math.sqrt(S*C)/omega
	local H1 = (3*R - 1)/2/C
	local H2 = (3*R + 1)/2/S
	local D  = 2*omega*earth_equ_radius
	
	return D*(1+earth_flattening*(H1*sF*sF*cG*cG-H2*cF*cF*sG*sG))
end

--[[
Convert geographical latitude to geocentric latitude
    
    [Meeus-1998: chapter 11]
    
    Parameters:
        phi : geographical latitude in radians
       H : altitude of the observer above sea level
          
    Returns:
        phi1: geocentric latitude in radians
        phi*sin(phi1)
        phi*cos(phi1)
--]]
local function geographical_to_geocentric_lat(phi, H)
	local ratio = (1-earth_flattening)
	local u = math.atan2(ratio*math.sin(phi), math.cos(phi))
	local r = H/6378140
	
	local phisinphi1 = ratio*math.sin(u) + r*math.sin(phi)
	local phicosphi1 = math.cos(u) + r*math.cos(phi)
	local phi1 = math.atan2(phisinphi1, phicosphi1)
	
	return phi1, phisinphi1, phicosphi1
end

if astro == nil then astro = {} end
astro["earth"] = { geodesic_distance = geodesic_distance,
                   geographical_to_geocentric_lat = geographical_to_geocentric_lat}
return astro