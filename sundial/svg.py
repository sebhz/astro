#!/usr/bin/env python3
"""SVG output from a sundial JSON description"""
import argparse
import json
from math import copysign, sqrt, dist
import sys
from jinja2 import Environment, FileSystemLoader
import sundial


def push_point(point, center, radius):
    """Push 'point' on the circle of radius 'radius' centered on origin,
    in the direction given by the 'center->point' vector"""
    if center[0] == point[0]:
        return (
            0,
            copysign(radius, point[1]),
        )

    dir_coef = (point[1] - center[1]) / (point[0] - center[0])
    offset = center[1] - center[0] * dir_coef
    delta = radius * radius * (1 + dir_coef * dir_coef) - offset * offset
    if delta < 0:  # Should never happen if radius is big enough
        print("ERROR: radius is too small. Increase it.", file=sys.stderr)
        sys.exit(-1)
    _x1 = (-dir_coef * offset - sqrt(delta)) / (1 + dir_coef * dir_coef)
    _x2 = (-dir_coef * offset + sqrt(delta)) / (1 + dir_coef * dir_coef)
    # Vectors are colinear - check only X coord
    if (point[0] - center[0]) * (_x1 - center[0]) >= 0:
        return (
            _x1,
            dir_coef * _x1 + offset,
        )
    return (
        _x2,
        dir_coef * _x2 + offset,
    )


def get_svg(s_dict, unit, max_radius):
    """Generate an SVG showing the sundial"""

    def revert_y(x):
        return (
            x[0],
            -x[1],
        )

    scale_factor = 1.1  # Must be > 1

    if s_dict["hour_lines"] is None:
        return None

    env = Environment(loader=FileSystemLoader("./templates"))

    # First, remove all points on the hour lines that are further than the radius
    if max_radius is not None:
        for hour, decl in enumerate(s_dict["hour_lines"]):
            _oob = []
            for declination in decl:
                if dist((0, 0), decl[declination]) > max_radius:
                    _oob.append(declination)
            for oob in _oob:
                decl.pop(oob)

    # Then get a list of all points in the diagram,
    # and derive a temporary bounding box
    points = []
    for line in s_dict["hour_lines"]:
        for v in line.values():
            points.append(revert_y(v))
    (minx, miny) = list(map(min, zip(*points)))
    (maxx, maxy) = list(map(max, zip(*points)))
    if max_radius is not None:
        (minx, miny) = (min(minx, -max_radius), min(miny, -max_radius))
        (maxx, maxy) = (max(maxx, max_radius), max(maxy, max_radius))

    if scale_factor < 1.0:
        scale_factor = 1.1
    height = maxy - miny
    height_scaled = height * scale_factor

    # We have 5 lines of legend, that we want to span over 1/8th of the height
    font_size = height_scaled / 8 / 5

    # Find furthest point along the hour line
    # lines_h is a list of (x, y, h) tuple, with h being the
    # index of the hour line (from 0 to 23) and
    # x, y the point of the furthest declination on the hour line
    lines_h = []
    for hour, decl in enumerate(s_dict["hour_lines"]):
        if not decl:
            continue
        tmp = None
        for declination, coordinate in decl.items():
            if tmp is None:
                tmp = revert_y(coordinate)
                continue
            if dist((0, 0), coordinate) > dist((0, 0), tmp):
                tmp = revert_y(coordinate)
        lines_h.append(tmp + (hour,))

    # If we trace a max radius circle, push the furthest points on the circle
    if max_radius is not None:
        _tmp = []
        for _i, hour_point in enumerate(lines_h):
            _tmp.append(
                (
                    *push_point(hour_point, revert_y(s_dict["center"]), max_radius),
                    hour_point[2],
                )
            )
        lines_h = _tmp

    # Coordinates of the text next to each hour line. Offset a bit the coordinates
    # of the furthest point on the hour line in the correct direction from the
    # origin. Recompute our bounding box as the text may spread outside
    hours_t = []
    for furthest_point in lines_h:
        hours_t.append(
            (
                furthest_point[0] - 0.8 * font_size,
                furthest_point[1] + copysign(1.3 * font_size, furthest_point[1]),
                furthest_point[2],
            )
        )
        (minx, miny) = (
            min(minx, furthest_point[0] - 0.8 * font_size),
            min(
                miny,
                furthest_point[1] + copysign(1.3 * font_size, furthest_point[1]),
            ),
        )
        (maxx, maxy) = (
            max(
                maxx,
                furthest_point[0]
                + (1 if furthest_point[2] >= 10 else 2)
                + 0.2 * font_size,
            ),
            max(
                maxy,
                furthest_point[1]
                + font_size
                + copysign(1.3 * font_size, furthest_point[1]),
            ),
        )

    # This is a dict of lists of (x1, y1, x2, y2) tuples giving the segments
    # on each declinations, indexed by declination names
    lines_d = {}
    for declination in sundial.declinations:
        tmp = None
        declination_segments = []
        for line in s_dict["hour_lines"]:  # Fortunately, those are ordered !
            decl = str(declination)
            if decl in line:
                if tmp is None:
                    tmp = revert_y(line[decl])
                    continue
                if tmp is not None:
                    declination_segments.append(tmp + revert_y(line[decl]))
                    tmp = revert_y(line[decl])
        # We now have a list of segments for the current declination. If we
        # draw a circle, add two segments to connect the declination line
        # to the bounding circle.
        if max_radius is not None:
            if not declination_segments:  # Possible if we have a small radius
                continue
            first_point = push_point(
                (declination_segments[0][0:2]),
                declination_segments[0][2:4],
                max_radius,
            )
            declination_segments.insert(
                0,
                (
                    *first_point,
                    *declination_segments[0][0:2],
                ),
            )
            last_point = push_point(
                (declination_segments[-1][2:4]),
                declination_segments[-1][0:2],
                max_radius,
            )
            declination_segments.append(
                (
                    *declination_segments[-1][2:4],
                    *last_point,
                )
            )
        lines_d[sundial.declinations_dict[declination]] = declination_segments

    # Final binding box computation
    width = maxx - minx
    height = maxy - miny

    width_scaled = width * scale_factor
    height_scaled = height * scale_factor
    x_offset = (width_scaled - width) / 2
    y_offset = (height_scaled - height) / 2

    # Arrow length: 1% of the smallest dimension
    # Arrow width: 1% of the smallest dimension
    arrow_shape = (min(width, height) / 100, min(width, height) / 100)

    sundial_map = {
        "phi": s_dict["phi"],
        "D": s_dict["declination"],
        "z": s_dict["zenithal_distance"],
        "a": s_dict["stylus_length"],
        "l": s_dict["longitude"],
        "center": revert_y(s_dict["center"]),
        "minx": minx - x_offset,
        "miny": miny - y_offset,
        "maxx": maxx + x_offset,
        "maxy": maxy + y_offset,
        "width": width_scaled,
        "height": height_scaled,
        "points": points,
        "lines_h": lines_h,
        "lines_d": lines_d,
        "hours_t": hours_t,
        "max_radius": max_radius,
        "show_coord": False,
        "font_size": font_size,
        "arrow_shape": arrow_shape,
        "unit": unit,
    }
    # Fill the template
    template = env.get_template("sundial.svg")
    return template.render(sundial_map)


PARSER = argparse.ArgumentParser()
PARSER.add_argument(
    "json_file", nargs="?", default=None, help="JSON file describing the sundial"
)
PARSER.add_argument(
    "--radius",
    "-r",
    help="Maximum radius of the sundial - erase everything outside for SVG output",
    type=float,
)
PARSER.add_argument(
    "--unit",
    "-u",
    help="Units of the coordinates (optional)",
    choices=("cm", "mm", "in", "pt", "px"),
    default="",
)
ARGS = PARSER.parse_args()

if ARGS.json_file is not None:
    with open(ARGS.json_file, encoding="utf8") as jsf:
        sundial_dict = json.load(jsf)
else:
    sundial_dict = json.load(sys.stdin)

print(get_svg(sundial_dict, ARGS.unit, ARGS.radius))
