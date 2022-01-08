#!/usr/bin/env python3


def get_vsop87d_test():
    with open("raw/vsop87.chk") as f:
        buf = f.readlines()
    body = "NAB"
    jd = "NAJ"
    test_str = ""
    flag = False

    for line in buf:
        v = line.split()
        if v == []:
            continue
        if v[0] == "VSOP87D":
            body = v[1]
            jd = v[2][2:]
            test_str += "    /* " + line.strip() + " */\n"
            flag = True
            continue
        if v[0] == "l":
            if flag:
                test_str += '    printf("VSOP87D - %s on J%s - ");\n' % (body, jd)
                test_str += "    vso_vsop87d_dyn_coordinates (%s, %s, coord);\n" % (
                    jd,
                    body,
                )
                test_str += "    coord[0] = rerange(coord[0], 2*M_PI);\n"
                test_str += (
                    "    res_coord(coord, (double[]) {%s, %s, %s}, 10, 0);\n\n"
                    % (v[1], v[4], v[7])
                )
                flag = False
    return test_str


c_str = """#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "meeus.h"
#include "test.h"

int success = 1;

int main(int argc, char **argv)
{
    double coord[3];
"""
c_str += get_vsop87d_test()
c_str += """
     printf ("-----------------\\nTEST STATUS: %s\\n",
             success ? "PASS" : "FAIL");
     return 0;
}"""

print(c_str)
