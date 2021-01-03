#!/bin/bash
#set -x

if [ -z ${ASTRO_SH_LIB_PATH+x} ]
then
    ASTRO_SH_LIB_PATH="$(dirname ${BASH_SOURCE[0]})/../lib"
fi

. $ASTRO_SH_LIB_PATH/coord
. $ASTRO_SH_LIB_PATH/sun

get_sun_coord(){
    __JD=$(dt_jd_from_date $1)
    __T=$(dt_j2000_t $__JD)

    # Sun coordinate computations work with Julian Ephemeris Day (DT) as base
    __JDE=$(dt_jde_from_date $1)
    __TE=$(dt_j2000_t $__JDE)
    __L0=$(sun_mean_longitude $__TE)
    __M=$(sun_mean_anomaly $__TE)
    __e=$(earth_orbit_eccentricity $__TE)
    __C=$(sun_center $__TE $__M)
    __L=$(sun_true_longitude $__TE)
    __v=$(sun_true_anomaly $__TE)
    __lambda=$(sun_apparent_longitude $__TE $__L)
    __epsilon=$(obliquity_ecliptic_true $__TE)

    # RA and decl are mostly constant over the course of a day but let's be precise :-)
    __right_ascension=$(sun_apparent_right_ascension $__TE $__lambda $__epsilon)
    __declination=$(sun_apparent_declination $__TE $__lambda $__epsilon)

    # But hour angle must be computed from Julian Day (UT)
    __latitude=$2
    __longitude=$3
    __H=$(dt_get_local_hour_angle $__JD $__longitude $__right_ascension)
    __horizontal_coord=$(equatorial_to_horizontal $__H $__latitude $__declination)
    __AZIMUTH=$(echo $__horizontal_coord | cut -d' ' -f1)
    __ALTITUDE=$(echo $__horizontal_coord | cut -d' ' -f2)
    echo -n $(echo "scale=2; $__ALTITUDE/1" | bc -l)
    echo -n ","
    echo $(echo "scale=2; $__AZIMUTH/1" | bc -l)
}

get_sun_coord "$(date +"%Y %m %d %H %M %S")" 43.56 7.12

