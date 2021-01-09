require "astro.util"
require "astro.vsop87d"

if _VERSION == "Lua 5.3" or _VERSION == "Lua 5.4" then
    unpack = table.unpack
end

local tb_iterator = astro.util.tb_iterator

local function usage()
    print("Usage:\n\t"..arg[0]..": vsop87_chk file")
end

local function report(computed, reference, delta)
    if math.abs(computed-reference) > delta then
        print("ERROR\n\tComputed: "..computed.."\n\tReference: "..reference)
        print("\tDifference: "..math.abs(computed-reference))
        return true
    end
end

if #arg ~= 1 then
    usage()
    return
end

local f = io.open(arg[1], "r")
if not f then error("Unable to open file "..arg[1]) end
local content = f:read("*all")
f:close()

local _trt = { ["MERCURY"] = "Mercury",
               ["VENUS"]   = "Venus",
               ["MARS"]    = "Mars",
               ["EARTH"]   = "Earth",
               ["JUPITER"] = "Jupiter",
               ["SATURN"]  = "Saturn",
               ["URANUS"]  = "Uranus",
               ["NEPTUNE"] = "Neptune",
              }
-- Now parse the "content" string line by line and construct a table of tables of the form  (planet_name, julian_day, longitude, latitude, radius)
local looking, planet, jd = false, nil, nil
local index = 1
local _t = {}
for line in string.gmatch(content, "[^\n]+") do
    if looking then
        local s, e, l, b, r = string.find(line, "l%s+([-%d.]+)%s+rad%s+b%s+([-%d.]+)%s+rad%s+r%s+([-%d.]+)")
        if s then
            _t[index] = {planet, jd, tonumber(l), tonumber(b), tonumber(r)}
            looking = false
            index   = index+1
        else
            error("Parsing error")
        end
    end
    local s, e, p, j = string.find(line, "VSOP87D%s+(%a+)%s+JD([%d.]+)")
    if s then
        looking = true
        planet  = _trt[p]
        jd      = tonumber(j)
    end
end

-- OK now _t contains a list of planets, jd and l, b, r
print(#_t.." test:")
local err = false
for i, v in ipairs(_t) do
    planet, jd, l, b, r = unpack(v)
    local L, B, R = astro.vsop87d.dimension3(jd, planet)
    print(planet, jd)
    err = err or report(L, l, 1e-10)
    err = err or report(B, b, 1e-10)
    err = err or report(R, r, 1e-10)
end
if err then print("VSOP87D checker reported errors") else print("VSOP87D checker did not report any error") end
