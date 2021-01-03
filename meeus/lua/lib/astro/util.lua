-- Collection of miscellaneous functions
require "astro.globals"
require "astro.constants"
local pi2             = astro.constants.pi2
local minutes_per_day = astro.constants.minutes_per_day
local seconds_per_day = astro.constants.seconds_per_day

local function quadratic_interpolation(x_list, y_list)
    local P, Q, R, S, T, U, V = 0, 0, 0, 0, 0, 0, 0

    for i, v in ipairs(x_list) do
        v2 = v*v
        v3 = v2*v
        v4 = v3*v
        P = P+v
        Q = Q+v2
        R = R+v3
        S = S+v4
        T = T+y_list[i]
        U = U+v*y_list[i]
        V = V+v2*y_list[i]
    end
    local N = #x_list
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

--[[
Useful iterator to traverse tables of tables
--]]
local function tb_iterator(t)
    local n = #t
    local i = 0
    return function()
        i = i + 1
        if i <= n then return unpack(t[i]) end
    end
end

--[[
    rounding to the nearest integer
--]]
local function round (x, decimal)
    if decimal == nil then decimal = 0 end
    local p = 10^decimal
    local y = x*p

    if x >= 0 then
        return math.floor(y + 0.5)/p
    end

    return math.ceil(y - 0.5)/p
end

--[[
Reduce an angle in radians to the range 0..2pi.

    Parameters:
        x : angle in radians

    Returns:
        angle in radians in the range 0..2pi
--]]
local function modpi2(x)
    x = math.fmod(x, pi2)
    if x < 0.0 then
        x = x+pi2
    end
    return x
end

--[[ Convert an angle in decimal degrees to degree components.

    Return a tuple (degrees, minutes, seconds). Degrees and minutes
    will be integers, seconds may be floating.

    If the argument is negative:
        The return value of degrees will be negative.
        If degrees is 0, minutes will be negative.
        If minutes is 0, seconds will be negative.

    Parameters:
        x : degrees

    Returns:
        degrees
        minutes
        seconds

--]]
local function d_to_dms(x)
    local negative
    if x < 0 then negative = true else negative = false end

    x = math.abs(x)
    local deg = math.floor(x)
    x = x-deg
    local mn = math.floor(x * 60)
    x = x - mn / 60.0
    local sec = x * 3600

    if negative then
        if deg > 0 then
            deg = -deg
        elseif mn > 0 then
            mn = -mn
        else
            sec = -sec
        end
    end

    return deg, mn, sec
end

--[[
Return angle b - a, accounting for circular values.

    Parameters a and b should be in the range 0..pi*2. The
    result will be in the range -pi..pi.

    This allows us to directly compare angles which cross through 0:

        359 degress... 0 degrees... 1 degree... etc

    Parameters:
        a : first angle, in radians
        b : second angle, in radians

    Returns:
        b - a, in radians
--]]
local function diff_angle(a, b)
    local result
    if b < a then
        result = b + pi2 - a
    else
        result = b - a
    end
    if result > math.pi then
        result = result-pi2
    end
    return result
end

--[[
Convert an angle in degree components to decimal degrees.

    If any of the components are negative the result will also be negative.

    Parameters:
        deg : degrees
        min : minutes
        sec : seconds

    Returns:
        decimal degrees

--]]
local function dms_to_d(deg, min, sec)
    local result = math.abs(deg) + math.abs(min) / 60.0 + math.abs(sec) / 3600.0
    if deg < 0 or min < 0 or sec < 0 then
        result = -result
    end
    return result
end
--[[
Convert an hour angle in hour, minute, seconds to decimal degrees.

     If any of the components are negative the result will also be negative.

    Parameters:
        hour : hours
        min : minutes
        sec : seconds

    Returns:
        decimal degrees

--]]
local function hangle_to_d(hour, min, sec)
    local s = math.abs(hour)*3600+math.abs(min)*60+math.abs(sec)
    s = s%seconds_per_day
    if hour < 0 or min < 0 or sec < 0 then
        s = -s
    end

    return s/seconds_per_day*360
end

--[[
Convert fractional day (0.0..1.0) to integral hours, minutes, seconds.

    Parameters:
        day : a fractional day in the range 0.0..1.0

    Returns:
        hour : 0..23
        minute : 0..59
        seccond : 0..59
--]]
local function fday_to_hms(day)
    local tsec = day * seconds_per_day
    local tmin = tsec / 60
    local thour = tmin / 60
    local hour = thour % 24
    local min = tmin % 60
    local sec = tsec % 60
    return math.floor(hour), math.floor(min), sec
end

--[[
Convert hours-minutes-seconds into a fractional day 0.0..1.0.

    Parameters:
        hr : hours, 0..23
        mn : minutes, 0..59
        sec : seconds, 0..59

    Returns:
        fractional day, 0.0..1.0

--]]
local function hms_to_fday(hr, mn, sec)
    return ((hr / 24.0) + (mn / minutes_per_day) + (sec / seconds_per_day))
end

--[[
Interpolate from three equally spaced tabular values.

    [Meeus-1998 equation 3.3]

    Parameters:
        n : the interpolating factor, must be between -1 and 1
        y : a sequence of three values

    Results:
        the interpolated value of y

--]]
local function interpolate3(n, y)
    if (n < -1) or (n > 1) then
        error("Interpolating factor out of range: "..n)
    end
    local a = y[2] - y[1]
    local b = y[3] - y[2]
    local c = b - a
    return y[2] + n/2 * (a + b + n*c)
end

--[[
Interpolate from three equally spaced tabular angular values.

    [Meeus-1998 equation 3.3]

    This version is suitable for interpolating from a table of
    angular values which may cross the origin of the circle,
    for example: 359 degrees...0 degrees...1 degree.

    Parameters:
        n : the interpolating factor, must be between -1 and 1
        y : a sequence of three values

    Results:
        the interpolated value of y
--]]
local function interpolate_angle3(n, y)
    if (n < -1) or (n > 1) then
        error("Interpolating factor out of range: "..n)
    end

    local a = diff_angle(y[1], y[2])
    local b = diff_angle(y[2], y[3])
    local c = diff_angle(a, b)
    return y[2] + n/2 * (a + b + n*c)
end

--[[
Evaluate a simple polynomial.

    Where: terms[0] is constant, terms[1] is for x, terms[2] is for x^2, etc.

    Example:
        y = polynomial((1.1, 2.2, 3.3, 4.4), t)

        returns the value of:

            1.1 + 2.2 * t + 3.3 * t^2 + 4.4 * t^3

    Parameters:
        terms : sequence of coefficients
        x : variable value

    Results:
        value of the polynomial
--]]
local function polynomial(terms, x)
    local i = #terms
    local result = terms[i]
    i = i - 1
    while i > 0 do
       result = result * x + terms[i]
        i = i-1
    end
    return result
end

--[[
Read a parameter file and assign global values.

    Parameters:
        parameter file name

    Returns:
        nothing
--]]
local function load_params(param_file)
    local f = assert(loadfile(param_file)) f()
    local sto, dto, lgv, lav

    local stn = astrolabe_param.standard_timezone_name or "CST" -- Defaults the name to CST
    local s = astrolabe_param.standard_timezone_offset or "0 hours" -- Defaults the offset to 0 days
    for offset, unit in string.gmatch(s, "(%d+)%s+(%w+)") do
        sto = tonumber(offset)
        if sto == nil then
            error("Bad standard timezone offset :"..offset)
        end
        if unit ~= "day" and unit ~= "days" and unit ~= "hour" and unit ~= "hours" and
           unit ~= "minute" and unit ~= "minutes" and unit ~= "second" and unit ~= "seconds" then
           error("Bad standard timezone offset unit :"..unit)
        end
        if unit == "hour" or unit == "hours" then sto = sto/24 end
        if unit == "minute" or unit == "minutes" then sto = sto/minutes_per_day end
        if unit == "second" or unit == "seconds" then sto = sto/seconds_per_day end
    end

    local dtn = astrolabe_param.daylight_timezone_name or "CDT" -- Defaults the name to CDT
    s = astrolabe_param.daylight_timezone_offset or "0 hours" -- Defaults the offset to 0 days
    for offset, unit in string.gmatch(s, "(%d+)%s+(%w+)") do
        dto = tonumber(offset)
        if dto == nil then
            error("Bad daylight timezone offset :"..offset)
        end
        if unit ~= "day" and unit ~= "days" and unit ~= "hour" and unit ~= "hours" and
           unit ~= "minute" and unit ~= "minutes" and unit ~= "second" and unit ~= "seconds" then
           error("Bad daylight timezone offset unit :"..unit)
        end
        if unit == "hour" or unit == "hours" then dto = dto/24 end
        if unit == "minute" or unit == "minutes" then dto = dto/minutes_per_day end
        if unit == "second" or unit == "seconds" then dto = dto/seconds_per_day end
    end

    local longitude = astrolabe_param.longitude or "0 east"
    for value, direction in string.gmatch(longitude, "(%w+)%s+(%w+)") do
        lgv = tonumber(value)
        if lgv == nil then
            error("Bad longitude value :"..value)
        end
        if direction ~= "east" and direction ~= "west" then
           error("Bad longitude direction :"..direction)
        end
        if direction == "east" then lgv = -lgv end
        lgv = d_to_r(lgv)
    end

    local latitude = astrolabe_param.latitude or "0 north"
    for value, direction in string.gmatch(latitude, "(%w+)%s+(%w+)") do
        lav = tonumber(value)
        if lav == nil then
            error("Bad latitude value :"..value)
        end
        if direction ~= "south" and direction ~= "north" then
           error("Bad latitude direction :"..direction)
        end
        if direction == "south" then lav = -lav end
        lav = d_to_r(lav)
    end
    astro.globals.standard_timezone_name   = stn
    astro.globals.standard_timezone_offset = sto
    astro.globals.daylight_timezone_name   = dtn
    astro.globals.daylight_timezone_offset = dto
    astro.globals.latitude                 = lav
    astro.globals.longitude                = lgv
end

if astro == nil then astro = {} end
astro["util"] = { load_params        = load_params,
         modpi2             = modpi2,
         interpolate_angle3 = interpolate_angle3,
         interpolate3       = interpolate3,
         hms_to_fday        = hms_to_fday,
         fday_to_hms        = fday_to_hms,
         dms_to_d           = dms_to_d,
         d_to_dms           = d_to_dms,
         hangle_to_d        = hangle_to_d,
         diff_angle         = diff_angle,
         polynomial         = polynomial,
         tb_iterator        = tb_iterator,
         round              = round,
         quadratic_interpolation = quadratic_interpolation,
         quadratic_roots    = quadratic_roots}

return astro