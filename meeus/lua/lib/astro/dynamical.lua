--[[Functions which calculate the deltaT correction to convert between
dynamical and universal time.

Reference: Jean Meeus, _Astronomical Algorithms_, second edition, 1998,
Willmann-Bell, Inc.
--]]
require "astro.constants"
require "astro.util"
require "astro.calendar"

local polynomial      = astro.util.polynomial
local seconds_per_day = astro.constants.seconds_per_day
local cal_to_jd       = astro.calendar.cal_to_jd
local jd_to_cal       = astro.calendar.jd_to_cal

-- _tbl is a list of tuples (jd, seconds), giving deltaT values for the beginnings of
-- years in a historical range. [Meeus-1998: table 10.A]
local _tbl = {
    {cal_to_jd(1620), 121.0},
    {cal_to_jd(1622), 112.0},
    {cal_to_jd(1624), 103.0},
    {cal_to_jd(1626), 95.0},
    {cal_to_jd(1628), 88.0},

    {cal_to_jd(1630), 82.0},
    {cal_to_jd(1632), 77.0},
    {cal_to_jd(1634), 72.0},
    {cal_to_jd(1636), 68.0},
    {cal_to_jd(1638), 63.0},

    {cal_to_jd(1640), 60.0},
    {cal_to_jd(1642), 56.0},
    {cal_to_jd(1644), 53.0},
    {cal_to_jd(1646), 51.0},
    {cal_to_jd(1648), 48.0},

    {cal_to_jd(1650), 46.0},
    {cal_to_jd(1652), 44.0},
    {cal_to_jd(1654), 42.0},
    {cal_to_jd(1656), 40.0},
    {cal_to_jd(1658), 38.0},

    {cal_to_jd(1660), 35.0},
    {cal_to_jd(1662), 33.0},
    {cal_to_jd(1664), 31.0},
    {cal_to_jd(1666), 29.0},
    {cal_to_jd(1668), 26.0},

    {cal_to_jd(1670), 24.0},
    {cal_to_jd(1672), 22.0},
    {cal_to_jd(1674), 20.0},
    {cal_to_jd(1676), 28.0},
    {cal_to_jd(1678), 16.0},

    {cal_to_jd(1680), 14.0},
    {cal_to_jd(1682), 12.0},
    {cal_to_jd(1684), 11.0},
    {cal_to_jd(1686), 10.0},
    {cal_to_jd(1688), 9.0},

    {cal_to_jd(1690), 8.0},
    {cal_to_jd(1692), 7.0},
    {cal_to_jd(1694), 7.0},
    {cal_to_jd(1696), 7.0},
    {cal_to_jd(1698), 7.0},

    {cal_to_jd(1700), 7.0},
    {cal_to_jd(1702), 7.0},
    {cal_to_jd(1704), 8.0},
    {cal_to_jd(1706), 8.0},
    {cal_to_jd(1708), 9.0},

    {cal_to_jd(1710), 9.0},
    {cal_to_jd(1712), 9.0},
    {cal_to_jd(1714), 9.0},
    {cal_to_jd(1716), 9.0},
    {cal_to_jd(1718), 10.0},

    {cal_to_jd(1720), 10.0},
    {cal_to_jd(1722), 10.0},
    {cal_to_jd(1724), 10.0},
    {cal_to_jd(1726), 10.0},
    {cal_to_jd(1728), 10.0},

    {cal_to_jd(1730), 10.0},
    {cal_to_jd(1732), 10.0},
    {cal_to_jd(1734), 11.0},
    {cal_to_jd(1736), 11.0},
    {cal_to_jd(1738), 11.0},

    {cal_to_jd(1740), 11.0},
    {cal_to_jd(1742), 11.0},
    {cal_to_jd(1744), 12.0},
    {cal_to_jd(1746), 12.0},
    {cal_to_jd(1748), 12.0},

    {cal_to_jd(1750), 12.0},
    {cal_to_jd(1752), 13.0},
    {cal_to_jd(1754), 13.0},
    {cal_to_jd(1756), 13.0},
    {cal_to_jd(1758), 14.0},

    {cal_to_jd(1760), 14.0},
    {cal_to_jd(1762), 14.0},
    {cal_to_jd(1764), 14.0},
    {cal_to_jd(1766), 15.0},
    {cal_to_jd(1768), 15.0},

    {cal_to_jd(1770), 15.0},
    {cal_to_jd(1772), 15.0},
    {cal_to_jd(1774), 15.0},
    {cal_to_jd(1776), 16.0},
    {cal_to_jd(1778), 16.0},

    {cal_to_jd(1780), 16.0},
    {cal_to_jd(1782), 16.0},
    {cal_to_jd(1784), 16.0},
    {cal_to_jd(1786), 16.0},
    {cal_to_jd(1788), 16.0},

    {cal_to_jd(1790), 16.0},
    {cal_to_jd(1792), 15.0},
    {cal_to_jd(1794), 15.0},
    {cal_to_jd(1796), 14.0},
    {cal_to_jd(1798), 13.0},

    {cal_to_jd(1800), 13.1},
    {cal_to_jd(1802), 12.5},
    {cal_to_jd(1804), 12.2},
    {cal_to_jd(1806), 12.0},
    {cal_to_jd(1808), 12.0},

    {cal_to_jd(1810), 12.0},
    {cal_to_jd(1812), 12.0},
    {cal_to_jd(1814), 12.0},
    {cal_to_jd(1816), 12.0},
    {cal_to_jd(1818), 11.9},

    {cal_to_jd(1820), 11.6},
    {cal_to_jd(1822), 11.0},
    {cal_to_jd(1824), 10.2},
    {cal_to_jd(1826), 9.2},
    {cal_to_jd(1828), 8.2},

    {cal_to_jd(1830), 7.1},
    {cal_to_jd(1832), 6.2},
    {cal_to_jd(1834), 5.6},
    {cal_to_jd(1836), 5.4},
    {cal_to_jd(1838), 5.3},

    {cal_to_jd(1840), 5.4},
    {cal_to_jd(1842), 5.6},
    {cal_to_jd(1844), 5.9},
    {cal_to_jd(1846), 6.2},
    {cal_to_jd(1848), 6.5},

    {cal_to_jd(1850), 6.8},
    {cal_to_jd(1852), 7.1},
    {cal_to_jd(1854), 7.3},
    {cal_to_jd(1856), 7.5},
    {cal_to_jd(1858), 7.6},

    {cal_to_jd(1860), 7.7},
    {cal_to_jd(1862), 7.3},
    {cal_to_jd(1864), 6.2},
    {cal_to_jd(1866), 5.2},
    {cal_to_jd(1868), 2.7},

    {cal_to_jd(1870), 1.4},
    {cal_to_jd(1872), -1.2},
    {cal_to_jd(1874), -2.8},
    {cal_to_jd(1876), -3.8},
    {cal_to_jd(1878), -4.8},

    {cal_to_jd(1880), -5.5},
    {cal_to_jd(1882), -5.3},
    {cal_to_jd(1884), -5.6},
    {cal_to_jd(1886), -5.7},
    {cal_to_jd(1888), -5.9},

    {cal_to_jd(1890), -6.0},
    {cal_to_jd(1892), -6.3},
    {cal_to_jd(1894), -6.5},
    {cal_to_jd(1896), -6.2},
    {cal_to_jd(1898), -4.7},

    {cal_to_jd(1900), -2.8},
    {cal_to_jd(1902), -0.1},
    {cal_to_jd(1904), 2.6},
    {cal_to_jd(1906), 5.3},
    {cal_to_jd(1908), 7.7},

    {cal_to_jd(1910), 10.4},
    {cal_to_jd(1912), 13.3},
    {cal_to_jd(1914), 16.0},
    {cal_to_jd(1916), 18.2},
    {cal_to_jd(1918), 20.2},

    {cal_to_jd(1920), 21.1},
    {cal_to_jd(1922), 22.4},
    {cal_to_jd(1924), 23.5},
    {cal_to_jd(1926), 23.8},
    {cal_to_jd(1928), 24.3},

    {cal_to_jd(1930), 24.0},
    {cal_to_jd(1932), 23.9},
    {cal_to_jd(1934), 23.9},
    {cal_to_jd(1936), 23.7},
    {cal_to_jd(1938), 24.0},

    {cal_to_jd(1940), 24.3},
    {cal_to_jd(1942), 25.3},
    {cal_to_jd(1944), 26.2},
    {cal_to_jd(1946), 27.3},
    {cal_to_jd(1948), 28.2},

    {cal_to_jd(1950), 29.1},
    {cal_to_jd(1952), 30.0},
    {cal_to_jd(1954), 30.7},
    {cal_to_jd(1956), 31.4},
    {cal_to_jd(1958), 32.2},

    {cal_to_jd(1960), 33.1},
    {cal_to_jd(1962), 34.0},
    {cal_to_jd(1964), 35.0},
    {cal_to_jd(1966), 36.5},
    {cal_to_jd(1968), 38.3},

    {cal_to_jd(1970), 40.2},
    {cal_to_jd(1972), 42.2},
    {cal_to_jd(1974), 44.5},
    {cal_to_jd(1976), 46.5},
    {cal_to_jd(1978), 48.5},

    {cal_to_jd(1980), 50.5},
    {cal_to_jd(1982), 52.2},
    {cal_to_jd(1984), 53.8},
    {cal_to_jd(1986), 54.9},
    {cal_to_jd(1988), 55.8},

    {cal_to_jd(1990), 56.9},
    {cal_to_jd(1992), 58.3},
    {cal_to_jd(1994), 60.0},
    {cal_to_jd(1996), 61.6},
    {cal_to_jd(1998), 63.0},

    --  the following are not from Meeus, but are taken from
    -- http://hpiers.obspm.fr/eop-pc/earthor/ut1lod/ut1-tai.html
    {cal_to_jd(2000), 32.184 + 31.6445},
    {cal_to_jd(2002), 32.184 + 32.1158},
    {cal_to_jd(2004), 32.184 + 32.3896},
    {cal_to_jd(2006), 32.184 + 32.6612},
    {cal_to_jd(2008), 32.184 + 33.2733},
    {cal_to_jd(2010), 32.184 + 33.897},
    {cal_to_jd(2012), 32.184 + 34.511}
}

local _tbl_start = 1620
local _tbl_end = 2012

--[[
Return deltaT as seconds of time.

    For a historical range from 1620 to a recent year, we interpolate from a
    table of observed values. Outside that range we use formulae.

    Parameters:
        jd : Julian Day number
    Returns:
        deltaT in seconds
--]]
local function deltaT_seconds(jd)
    local yr, mo, day
    local jd1, secs1, jd0, secs0
    yr, mo, day = jd_to_cal(jd)
    --
    -- 1620 - 20xx - do linear interpolation
    --
    if yr == _tbl_end then
        return _tbl[_tbl_end][1]
    end

    if _tbl_start <= yr and yr < _tbl_end then
        for i=1,#_tbl-1 do
            if jd >= _tbl[i][1] and jd < _tbl[i+1][1] then
                jd1, secs1 = unpack(_tbl[i+1])
                jd0, secs0 = unpack(_tbl[i])
            end
        end
        --  simple linear interpolation between two values
        return ((jd - jd0) * (secs1 - secs0) / (jd1 - jd0)) + secs0
    end

    local t = (yr - 2000) / 100.0

    --
    -- before 948 [Meeus-1998: equation 10.1]
    --
    if yr < 948 then
        return polynomial({2177, 497, 44.1}, t)
    end

    --
    -- 948 - 1620 and after 2012 [Meeus-1998: equation 10.2)
    --
    local result = polynomial({102, 102, 25.3}, t)

    --
    -- correction for 2012-2100 [Meeus-1998: pg 78]
    --
    if _tbl_end <= yr and yr < 2100 then
        result = result + 0.37 * (yr - 2100)
    end
    return result
end

--[[
Convert Julian Day from dynamical to terrestrial universal time.

    Parameters:
        jd : Julian Day number (dynamical time)
    Returns:
        Julian Day number (universal time)

--]]
local function dt_to_ut(jd)
    return jd - deltaT_seconds(jd) / seconds_per_day
end

--[[
Convert Julian Day from terrestrial universal time to dynamical.

    Parameters:
        jd : Julian Day number (universal time)
    Returns:
        Julian Day number (dynamical time)

--]]
local function ut_to_dt(jd)
    return jd + deltaT_seconds(jd) / seconds_per_day
end


--[[
Converts from terrestrial dynamic time to barycentric dynamic time

    Parameters:
       tt : terrestrial dynamic time
       jd : Julian Day number (terrestrial dynamic time)
    Returns:
              barycentric dynamic time

--]]
local function tdt_to_bdt(tt, jd)
    local g = 357.33 + 0.9856003*(jd-2451545)
    local tdb = tt + 0.001658*math.sin(g) + 0.000014*math.sin(2*g)
    return tdb
end

if astro == nil then astro = {} end
astro["dynamical"] = {dt_to_ut       = dt_to_ut,
                      ut_to_dt       = ut_to_dt,
                      tdt_to_bdt     = tdt_to_bdt,
                      deltaT_seconds = deltaT_seconds}
return astro
