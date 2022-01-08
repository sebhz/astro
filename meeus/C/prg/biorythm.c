#define _XOPEN_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "meeus.h"

double
mrand (double x)
{
    srand ((unsigned) time (NULL));
    return ((double) rand ()) / RAND_MAX;
}

/* A "rythm" is a function having a frequency (in days) */
struct rythm
{
    char *id;
    double frequency;
    double (*f) (double);
};

struct rythm rythms[] = {
    {.id = "Physical",
     .frequency = 2 * M_PI / 23.0,
     .f = sin},
    {.id = "Emotional",
     .frequency = 2 * M_PI / 28.0,
     .f = sin},
    {.id = "Intellectual",
     .frequency = 2 * M_PI / 33.0,
     .f = sin},
    {.id = "H2G2",
     .frequency = 2 * M_PI / 42.0,
     .f = sin},
    {.id = "Uh ?",
     .frequency = 0,
     .f = mrand}
};

int
main (int argc, char **argv)
{
    struct tm td;
    double jd_birth, jd_now, delta_jd;

    if (argc != 2) {
        printf
            ("Usage: %s [birthdate]\n\n[birthdate format]: YYYY-MM-DDThh:mm:ss\nBirth hour expected UTC.\n",
             argv[0]);
        return -1;
    }

    strptime (argv[1], "%Y-%m-%dT%T", &td);
    if (dt_date_to_jd (&td, &jd_birth)) {
        printf
            ("Cannot compute JD for birth date. Would result in negative JD\n");
        return -1;
    }
    dt_get_current_jd (0, &jd_now);
    delta_jd = jd_now - jd_birth;

    for (int i = 0; i < (sizeof rythms) / (sizeof rythms[0]); i++) {
        printf ("%s: %4.2f\n", rythms[i].id,
                rythms[i].f (delta_jd * rythms[i].frequency));
    }

    return 0;
}
