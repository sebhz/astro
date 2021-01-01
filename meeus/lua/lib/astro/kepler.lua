require "astro.util"
require "astro.constants"

local pi2    = astro.constants.pi2
local modpi2 = astro.util.modpi2

local function solve_kepler(M, E, err)
	err = err/pi2 -- error in radian
	local i, f = math.modf(M/pi2)
	M = modpi2(f*pi2)
	f = 1
	if M > math.pi then 
		f = -1 
		M = pi2-M
	end
	local E0 = math.pi/2
	local D  = math.pi/4
	local nsteps = 0
	while D > err/2 do
		nsteps = nsteps + 1
		local s
		local M1 = E0-E*math.sin(E0)
		if (M-M1) < 0 then s = -1 else s = 1 end
		E0 = E0 + D*s
		D = D/2
	end
	return E0*f, nsteps
end

if astro == nil then astro = {} end
astro["kepler"] = { solve_kepler = solve_kepler }
return astro