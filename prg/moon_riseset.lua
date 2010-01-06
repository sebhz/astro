--[[ 
Very naive algorithm to compute moonrise and set time
--]]
require "astro.moon"
require "astro.nutation"
require "astro.coordinates"
require "astro.sidereal"
require "astro.calendar"
require "astro.dynamical"
require "astro.util"

local elp2000                      = astro.elp2000
local moon_horizontal_parallax     = astro.moon.moon_horizontal_parallax
local true_obliquity               = astro.nutation.true_obliquity
local ecl_to_equ                   = astro.coordinates.ecl_to_equ
local equ_to_horiz                 = astro.coordinates.equ_to_horiz
local apparent_sidereal_time_greenwich = astro.sidereal.apparent_sidereal_time_greenwich
local cal_to_jd                    = astro.calendar.cal_to_jd
local jd_to_cal                    = astro.calendar.jd_to_cal
local lt_to_str                    = astro.calendar.lt_to_str
local is_leap_year                 = astro.calendar.is_leap_year
local day_of_year_to_cal           = astro.calendar.day_of_year_to_cal
local ut_to_lt                     = astro.calendar.ut_to_lt
local dt_to_ut                     = astro.dynamical.dt_to_ut
local round                        = astro.util.round

local function usage()
	print("Usage:\n\t"..arg[0]..": year")
end

local function quadratic_interpolation(jd_list, v_list)
	local P, Q, R, S, T, U, V = 0, 0, 0, 0, 0, 0, 0
	
	for i, v in ipairs(jd_list) do
		v2 = v*v
		v3 = v2*v
		v4 = v3*v
		P = P+v
		Q = Q+v2
		R = R+v3
		S = S+v4
		T = T+v_list[i]
		U = U+v*v_list[i]
		V = V+v2*v_list[i]
	end
	local N = #jd_list
	local D = N*Q*S+2*P*Q*R-Q*Q*Q-P*P*S-N*R*R
	local a = (N*Q*V+P*R*T+P*Q*U-Q*Q*T-P*P*V-N*R*U)/D
	local b = (N*S*U+P*Q*V+Q*R*T-Q*Q*U-P*S*T-N*R*V)/D
	local c = (Q*S*T+Q*R*U+P*R*V-Q*Q*V-P*S*U-R*R*T)/D
	
	return a, b, c
end

local function quadratic_roots(a, b, c)
	local delta = b*b-4*a*c
	if delta < 0 then return nil end
	if delta == 0 then return -b/2/a end
	sqd = math.sqrt(delta)
	return (-b+sqd)/2/a, (-b-sqd)/2/a
end

local function altitude(jd)
	local l, b   = elp2000.dimension3(jd)
	local o      = true_obliquity(jd)
	local ra, de = ecl_to_equ(l, b, o)
	local H      = apparent_sidereal_time_greenwich(jd) - astro.globals.longitude - ra
	local A, h   = equ_to_horiz(H, de)
	-- h = h+0.7275*moon_horizontal_parallax(jd)-math.rad(34/60) -- Semi-diameter of the moon
	-- TODO - add effect of atmospheric refraction
	return h
end

local function sgn(x)
	if x < 0 then return -1 end
	return 1
end

local function report_riseset(rise, set, k)
	if rise then
		local lt, zone = ut_to_lt(rise)
		print("Rise: "..lt_to_str(lt, zone, "minute"))
	else 
		print("Moon did not rise this day")
	end
	if set then
		local lt, zone = ut_to_lt(set)
		print("Set : "..lt_to_str(lt, zone, "minute"))
	else 
		print("Moon did not set this day")
	end
	print(k.." iteration(s) done")
end

local function riseset_linear(jd)
	local s = sgn(altitude(jd))
	local rise, set, k = nil, nil, 0
	for i=1, 1440 do
		k = i
		local j = jd+i/1440
		local h = altitude(j)
		if sgn(h) ~= s then
			local t = ""
			if sgn(h) < 0 then set = dt_to_ut(j) else rise = dt_to_ut(j) end
			if rise and set then break end
			s = sgn(h)
		end
	end
	return rise, set, k
end

local function riseset_quadratic(jd)
	local rise, set, k, nsteps, uroot = nil, nil, 0, 24, false
	local jd_list, v_list = {0, 1, 2}, {}
	for i, v in ipairs(jd_list) do v_list[i] = altitude(jd+v/nsteps) end

	for i=1,nsteps do
		local a, b, c = quadratic_interpolation(jd_list, v_list)
		local s1, s2 = quadratic_roots(a, b, c)
		
		if s1 and not s2 then uroot = true end -- Very unlikely to ever happen due to the precision used
		
		if s1 >= 0 and s1 <= 2 then
			local slope = a*s1+b
			local j = jd + (i-1+s1)/nsteps
			local ut = dt_to_ut(j)
 			if slope > 0 then rise = ut else set = ut end
			if uroot then k = i; break end
		end
		
		if s2 >= 0 and s2 <= 2 then		
			local slope = a*s2+b
			local j = jd + (i-1+s2)/nsteps
			local ut = dt_to_ut(j)
			if slope > 0 then rise = ut else set = ut end 
		end
		
		if rise and set then k = i; break end
		
		v_list[1], v_list[2] = v_list[2], v_list[3]
		v_list[3] = altitude(jd+(i+2)/nsteps)
	end
	if uroot then if rise then set = rise else rise = set end end
	return rise, set, k
end

if #arg ~= 1 then
	usage()
	return
end

local yr = tonumber(arg[1])
local nd = 365
if is_leap_year(yr) then nd = 366 end

local hold = -1
print("Moon altitude at midnight")
for d=1,nd do
	local jd = cal_to_jd(yr, day_of_year_to_cal(yr, d))
	local h = altitude(jd)
	local direction = "rising"
	if h < hold then direction = "falling" end
	print(math.deg(h))
	hold = h
end

while true do end
print("Quadratic extrapolation")
local x = os.clock()
for d=1,nd do
	local jd = cal_to_jd(yr, day_of_year_to_cal(yr, d))
	riseset_quadratic(jd)
end
local y = os.clock()
print(string.format("Used CPU time: %.2f seconds\n", y - x))

x = os.clock()
print("Linear extrapolation")
for d=1,nd do
	local jd = cal_to_jd(yr, day_of_year_to_cal(yr, d))
	riseset_linear(jd)
end
y = os.clock()
print(string.format("Used CPU time: %.2f seconds\n", y - x))

local kr, ks = 0, 0
print("Comparing results between linear and quadratic")
for d=1,nd do
	local jd = cal_to_jd(yr, day_of_year_to_cal(yr, d))
	local rl, sl = riseset_linear(jd)
	local rq, sq = riseset_quadratic(jd)
	
	if rl then dr = round((rl-rq)*1440) end -- round to the closest minute - should crash if rl is defined but not rq
	if sl then ds = round((sl-sq)*1440) end 
	
	if dr > 0 then kr=kr+1 end
	if ds > 0 then ks=ks+1 end
end
print(kr .. " rise difference(s) / " .. ks .. " set difference(s) detected")