--
-- Abbreviation for standard timezone (e.g., "CST" for North American
-- Central Standard Time)
--
local standard_timezone_name = "CET "
--
-- Time in fractional days to be subtracted from UT to calculate the standard
-- time zone offset. Locations east of Greenwich should use negative values.
--
local standard_timezone_offset = -1
--
-- Abbreviation for daylight savings timezone (e.g., "CDT" for North American
-- Central Daylight Time)
--
-- This is optional. If set to None, no daylight savings conversions
-- will be performed.
--
local daylight_timezone_name = "CEST"
--
-- Time in fractional days to be subtracted from UT to calculate the daylight savings
-- time zone offset. Locations east of Greenwich should use negative values.
--
-- This value is not used unless "daylight_timezone_name" has an value other
-- than None.
--
local daylight_timezone_offset = -2
--
-- Observer's longitude in radians, measured positive west of Greenwich,
-- negative to the east. Should be between -pi...pi.
--
local longitude = math.rad(-7.27)

-- Observer's latitude in radians, measured positive north of the equator,
-- negative to the south. Should be between -pi/2...pi/2.
--
local latitude =  math.rad(43.7) -- Nice

--
-- Month names. There must be twelve. The default is three-character
-- abbreviations so that listings line up.
--
local month_names = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
--
-- Season names. There must be four. These are used to characterize the
-- equinoxes and solstices.
--
local season_names = {"spring", "summer", "autumn", "winter"}

if astro == nil then astro = {} end
astro["globals"] = { standard_timezone_name = standard_timezone_name,
            standard_timezone_offset = standard_timezone_offset,
            daylight_timezone_name = daylight_timezone_name,
            daylight_timezone_offset = daylight_timezone_offset,
            latitude    = latitude,
            longitude   = longitude,
            month_names = month_names,
            season_names = season_names,
            }

return astro
