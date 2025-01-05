#!/usr/bin/env python3
"""Text output of a sundial JSON description"""
import argparse
import json
from math import degrees, asin
import sys
from prettytable import PrettyTable
import sundial


def get_txt(s_dict):
    """Outputs the text file"""

    def get_coord_string(coordinates, c):
        if str(c) not in coordinates:
            return "-"
        return f"{coordinates[str(c)][0]:0.4f},{coordinates[str(c)][1]:0.4f}"

    d_str = """Sundial latitude (degrees): {phi:0.4f}
Sundial longitude (degrees): {l:0.4f}
Sundial gnomonic declination (degrees): {D:0.4f}
Sundial stylus zenithal distance (degrees): {z:0.4f}
Sundial stylus length: {a:0.4f}
Sundial center: ({center[0]:0.4f},{center[1]:0.4f})
Angle of the polar stylus with sundial plane (degrees): {P:0.4f}
x-axis direction: positive towards {d:0.4} degrees compared to east
""".format(
        phi=s_dict["phi"],
        l=s_dict["longitude"],
        D=s_dict["declination"],
        z=s_dict["zenithal_distance"],
        a=s_dict["stylus_length"],
        center=s_dict["center"],
        P=degrees(asin(abs(s_dict["P"]))),
        d=-s_dict["declination"],
    )

    if s_dict["hour_lines"] is None:
        return d_str

    table = PrettyTable()
    table.field_names = [
        "Angle",
        "Time",
        *[sundial.declinations_dict[x] for x in sundial.declinations],
    ]
    table.align = "l"
    for hour, coordinates in enumerate(s_dict["hour_lines"]):
        coord_str = [get_coord_string(coordinates, x) for x in sundial.declinations]
        table.add_row([15 * (hour - 12), hour, *coord_str])
    return d_str + table.get_string()


PARSER = argparse.ArgumentParser()
PARSER.add_argument("json_file", nargs="?", help="JSON file describing the sundial")
ARGS = PARSER.parse_args()
if ARGS.json_file is not None:
    with open(ARGS.json_file, encoding="utf8") as jsf:
        sundial_dict = json.load(jsf)
else:
    sundial_dict = json.load(sys.stdin)
print(get_txt(sundial_dict))
