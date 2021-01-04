#!/bin/bash
# set -x

if [ -z ${ASTRO_SH_LIB_PATH+x} ]
then
    ASTRO_SH_LIB_PATH="$(dirname ${BASH_SOURCE[0]})/../lib"
fi

. $ASTRO_SH_LIB_PATH/coord
. $ASTRO_SH_LIB_PATH/sun

get_sun_coord(){
    local _latitude=$2
    local _longitude=$3

    # Sun coordinates computations work with Julian Ephemeris Day (DT) as base...
    local _JDE=$(dt_jde_from_date $1)
    local _TE=$(dt_j2000_t $_JDE)
    local _L=$(sun_true_longitude $_TE)
    local _lambda=$(sun_apparent_longitude $_TE $_L)
    local _epsilon=$(obliquity_ecliptic_true $_TE)
    # RA and decl are mostly constant over the course of a day but let's be precise :-)
    local _right_ascension=$(sun_apparent_right_ascension $_TE $_lambda $_epsilon)
    local _declination=$(sun_apparent_declination $_TE $_lambda $_epsilon)

    # ...but hour angle must be computed from Julian Day (UT)
    local _JD=$(dt_jd_from_date $1)
    local _H=$(dt_get_local_hour_angle $_JD $_longitude $_right_ascension)
    # This is hour angle computed from mean sidereal time - correct it to get apparent sidereal time
    local _obliquity_correction=$(obliquity_apparent_correction $_TE)
    local _apparent_hour_angle=$(bc -l <<< "$_obliquity_correction + $_H")
    local _horizontal_coord=$(equatorial_to_horizontal $_apparent_hour_angle $_latitude $_declination)
    local _AZIMUTH=$(echo $_horizontal_coord | cut -d' ' -f1)
    local _ALTITUDE=$(echo $_horizontal_coord | cut -d' ' -f2)

    echo -n $(bc -l <<< "scale=2; $_ALTITUDE/1")
    echo -n ","
    bc -l <<< "scale=2; $_AZIMUTH/1"
}

lat=$1
long=$2
get_sun_coord "$(date -u +"%Y %m %d %H %M %S")" $lat $long

