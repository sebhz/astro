#!/usr/bin/env python3
""" Computations to create a planar sundial """
import argparse
from math import radians, degrees, cos, sin, tan, asin, fmod, copysign, sqrt
import sys
from prettytable import PrettyTable
from jinja2 import Environment, FileSystemLoader


def modulus(x, y):
    """Plain modulus"""
    return x * x + y * y


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


class Sundial:
    """Sundial creation and rendering methods"""

    declinations_dict = {
        -23.44: "Winter Sol.",
        # -20.15: "-20.15",
        # -11.47: "-11.47",
        0: "Equinox",
        # 11.47: "11.47",
        # 20.15: "20.15",
        23.44: "Summer Sol.",
    }
    declinations = sorted(list(declinations_dict.keys()))

    def __init__(self, phi, D, z, a, l=0.0):
        self.phi = phi
        self.D = D
        self.z = z
        self.a = a
        self.l = l
        phi_r = radians(self.phi)
        D_r = radians(self.D)
        z_r = radians(self.z)
        self.P = sin(phi_r) * cos(z_r) - cos(phi_r) * sin(z_r) * cos(D_r)
        try:
            self.center = (
                a * cos(phi_r) * sin(D_r) / self.P,
                -a
                * (sin(phi_r) * sin(z_r) + cos(phi_r) * cos(z_r) * cos(D_r))
                / self.P,
            )
        except ZeroDivisionError:  # Can occur if z = phi
            self.center = (0, 0)
        self.hour_lines = None

    def compute_hour_lines(self):
        """Compute all points on the sundial
        (intersections of hour lines and sun declinations)
        returns an array of dict. The array has one dict per
        hour (from 0 (midnight) to +11 (11 PM).
        Each dict is indexed by declination (see declination array)
        and contains the x, y coordinate of the point for this declination
        for this hour.
        Dict can be empty, or not contain all declinations if
        the sun never indicates the declination"""

        self.hour_lines = []
        phi_r = radians(self.phi)
        D_r = radians(self.D)
        z_r = radians(self.z)
        for H in range(-12, 12):
            H_r = radians(H * 15 + fmod(self.l, 15))
            H_coordinates = {}
            for delta in Sundial.declinations:
                delta_r = radians(delta)
                Q = (
                    sin(D_r) * sin(z_r) * sin(H_r)
                    + (cos(phi_r) * cos(z_r) + sin(phi_r) * sin(z_r) * cos(D_r))
                    * cos(H_r)
                    + self.P * tan(delta_r)
                )
                if Q < 0:  # Sun does not illuminate the plane for this declination
                    continue
                Nx = cos(D_r) * sin(H_r) - sin(D_r) * (
                    sin(phi_r) * cos(H_r) - cos(phi_r) * tan(delta_r)
                )
                Ny = (
                    cos(z_r) * sin(D_r) * sin(H_r)
                    - (cos(phi_r) * sin(z_r) - sin(phi_r) * cos(z_r) * cos(D_r))
                    * cos(H_r)
                    - (sin(phi_r) * sin(z_r) + cos(phi_r) * cos(z_r) * cos(D_r))
                    * tan(delta_r)
                )
                p = (self.a * Nx / Q, self.a * Ny / Q)
                if modulus(*p) < 900 * self.a * self.a:
                    H_coordinates[delta] = p
            self.hour_lines.append(H_coordinates)

    def get_svg(self, max_radius):
        """Generate an SVG showing the sundial"""

        def revert_y(x):
            return (
                x[0],
                -x[1],
            )

        SCALE_FACTOR = 1.1  # Must be > 1

        if self.hour_lines is None:
            return None

        env = Environment(loader=FileSystemLoader("./templates"))

        # First, remove all points on the hour lines that are further than the radius
        if max_radius is not None:
            for hour, decl in enumerate(self.hour_lines):
                _oob = []
                for declination in decl:
                    if modulus(*decl[declination]) > max_radius * max_radius:
                        _oob.append(declination)
                for oob in _oob:
                    decl.pop(oob)

        # Then get a list of all points in the diagram,
        # and derive a temporary bounding box
        points = []
        for line in self.hour_lines:
            for v in line.values():
                points.append(revert_y(v))
        (minx, miny) = list(map(min, zip(*points)))
        (maxx, maxy) = list(map(max, zip(*points)))
        if max_radius is not None:
            (minx, miny) = (min(minx, -max_radius), min(miny, -max_radius))
            (maxx, maxy) = (max(maxx, max_radius), max(maxy, max_radius))

        if SCALE_FACTOR < 1.0:
            SCALE_FACTOR = 1.1
        height = maxy - miny
        height_scaled = height * SCALE_FACTOR

        # We have 5 lines of legend, that we want to span over 1/8th of the height
        font_size = height_scaled / 8 / 5

        # Find furthest point along the hour line
        # lines_h is a list of (x, y, h) tuple, with h being the
        # index of the hour line (from 0 to 23) and
        # x, y the point of the furthest declination on the hour line
        lines_h = []
        for hour, decl in enumerate(self.hour_lines):
            if not decl:
                continue
            tmp = None
            for declination, coordinate in decl.items():
                if tmp is None:
                    tmp = revert_y(coordinate)
                    continue
                if modulus(*coordinate) > modulus(*tmp):
                    tmp = revert_y(coordinate)
            lines_h.append(tmp + (hour,))

        # If we trace a max radius circle, push the furthest points on the circle
        if max_radius is not None:
            _tmp = []
            for _i, hour_point in enumerate(lines_h):
                _tmp.append(
                    (
                        *push_point(hour_point, revert_y(self.center), max_radius),
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

        # This is a simple list of (x1, y1, x2, y2) tuple giving the segment of lines
        # on each declinations
        lines_d = []
        for declination in Sundial.declinations:
            tmp = None
            declination_segments = []
            for line in self.hour_lines:  # Fortunately, those are ordered !
                if declination in line:
                    if tmp is None:
                        tmp = revert_y(line[declination])
                        continue
                    if tmp is not None:
                        declination_segments.append(tmp + revert_y(line[declination]))
                        tmp = revert_y(line[declination])
            # We now have a list of segments for the current declination. If we
            # draw a circle, add two segments to connect the declination line
            # to the bounding circle.
            if max_radius is not None:
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
            lines_d += declination_segments

        # Final binding box computation
        width = maxx - minx
        height = maxy - miny

        width_scaled = width * SCALE_FACTOR
        height_scaled = height * SCALE_FACTOR
        x_offset = (width_scaled - width) / 2
        y_offset = (height_scaled - height) / 2

        # Arrow length: 1% of the smallest dimension
        # Arrow width: 1% of the smallest dimension
        arrow_shape = (min(width, height) / 100, min(width, height) / 100)

        sundial_map = {
            "phi": self.phi,
            "D": self.D,
            "z": self.z,
            "a": self.a,
            "l": self.l,
            "center": revert_y(self.center),
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
        }
        # Fill the template
        template = env.get_template("sundial.svg")
        return template.render(sundial_map)

    def __str__(self):
        def get_coord_string(coordinates, c):
            if c not in coordinates:
                return "-"
            return f"{coordinates[c][0]:0.4f},{coordinates[c][1]:0.4f}"

        d_str = """Sundial latitude (degrees): {phi:0.4f}
Sundial longitude (degrees): {l:0.4f}
Sundial gnomonic declination (degrees): {D:0.4f}
Sundial stylus zenithal distance (degrees): {z:0.4f}
Sundial stylus length: {a:0.4f}
Sundial center: ({center[0]:0.4f},{center[1]:0.4f})
Angle of the polar stylus with sundial plane (degrees): {P:0.4f}
x-axis direction: positive towards {d:0.4} degrees compared to east
""".format(
            phi=self.phi,
            l=self.l,
            D=self.D,
            z=self.z,
            a=self.a,
            center=self.center,
            P=degrees(asin(abs(self.P))),
            d=-self.D,
        )

        if self.hour_lines is None:
            return d_str

        table = PrettyTable()
        table.field_names = [
            "Angle",
            "Time",
            *[Sundial.declinations_dict[x] for x in Sundial.declinations],
        ]
        table.align = "l"
        for hour, coordinates in enumerate(self.hour_lines):
            coord_str = [get_coord_string(coordinates, x) for x in Sundial.declinations]
            table.add_row([15 * (hour - 12), hour, *coord_str])
        return d_str + table.get_string()


DEFAULT_A = 15.0
PARSER = argparse.ArgumentParser()
PARSER.add_argument(
    "--phi",
    help="Latitude of the sundial in degrees. Positive towards north",
    type=float,
    required=True,
)
PARSER.add_argument(
    "--D",
    help="Declination of the sundial plane perpendicular in degrees",
    type=float,
    required=True,
)
PARSER.add_argument(
    "--z", help="Zenithal distance of the stylus in degrees", type=float, required=True
)
PARSER.add_argument(
    "--a",
    help=f"Length of the stylus (default: {DEFAULT_A:0.4f})",
    type=float,
    default=DEFAULT_A,
)
PARSER.add_argument(
    "--l", help="Longitude of the sundial in degrees.", type=float, default=0.0
)
PARSER.add_argument(
    "--r",
    help="Maximum radius of the sundial - erase everything outside for SVG output",
    type=float,
)
PARSER.add_argument(
    "--svg",
    help="Displays SVG rather than plain text",
    action="store_true",
    default=False,
)
ARGS = PARSER.parse_args()

SD = Sundial(ARGS.phi, ARGS.D, ARGS.z, ARGS.a, ARGS.l)
SD.compute_hour_lines()
if not ARGS.svg:
    print(SD)
else:
    print(SD.get_svg(ARGS.r))
