#!/usr/bin/env python3
""" Computations to create a planar sundial """
import argparse
from math import radians, degrees, cos, sin, tan, asin, fmod, copysign
from prettytable import PrettyTable
from jinja2 import Environment, FileSystemLoader


class Sundial:
    """ Sundial creation and rendering methods """

    declinations = (-23.44, -20.15, -11.47, 0, 11.47, 20.15, 23.44)
    declinations_names = (
        "Winter Sol.",
        "-20.15",
        "-11.47",
        "Equinox",
        "11.47",
        "20.15",
        "Summer Sol.",
    )

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
        """ Compute all points on the sundial
            (intersections of hour lines and sun declinations) """
        MODULUS = lambda x, y: x * x + y * y
        self.hour_lines = list()
        phi_r = radians(self.phi)
        D_r = radians(self.D)
        z_r = radians(self.z)
        for H in range(-12, 12):
            H_r = radians(H * 15 + fmod(self.l, 15))
            H_coordinates = dict()
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
                if MODULUS(*p) < 900 * self.a * self.a:
                    H_coordinates[delta] = p
            self.hour_lines.append(H_coordinates)

    def get_svg(self):
        """ Generate an SVG showing the sundial """
        REVERT_Y = lambda x: (x[0], -x[1])
        MODULUS = lambda x, y: x * x + y * y
        SCALE_FACTOR = 1.1

        if self.hour_lines is None:
            return None

        env = Environment(loader=FileSystemLoader("./templates"))

        points = list()
        for line in self.hour_lines:
            for v in line.values():
                points.append(REVERT_Y(v))
        (minx, miny) = list(map(min, zip(*points)))
        (maxx, maxy) = list(map(max, zip(*points)))
        width = maxx - minx
        height = maxy - miny

        width_scaled = width * SCALE_FACTOR
        height_scaled = height * SCALE_FACTOR
        x_offset = (width_scaled - width) / 2
        y_offset = (height_scaled - height) / 2
        lines_h = list()
        # Find furthest point along the hour line
        for hour, declinations in enumerate(self.hour_lines):
            if not declinations:
                continue
            tmp = None
            for declination, coordinate in declinations.items():
                if tmp is None:
                    tmp = REVERT_Y(coordinate)
                    continue
                if MODULUS(*coordinate) > MODULUS(*tmp):
                    tmp = REVERT_Y(coordinate)
            lines_h.append(tmp + (hour,))

        lines_d = list()
        for declination in Sundial.declinations:
            tmp = None
            for line in self.hour_lines:  # Fortunately, those are ordered !
                if declination in line:
                    if tmp is None:
                        tmp = REVERT_Y(line[declination])
                        continue
                    lines_d.append(tmp + REVERT_Y(line[declination]))
                    tmp = REVERT_Y(line[declination])

        hours_t = list()
        for furthest_point in lines_h:
            hours_t.append(
                (
                    furthest_point[0],
                    furthest_point[1] + copysign(5, furthest_point[1]),
                    furthest_point[2],
                )
            )

        sundial_map = {
            "phi": self.phi,
            "D": self.D,
            "z": self.z,
            "a": self.a,
            "l": self.l,
            "center": REVERT_Y(self.center),
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
            "show_coord": False,
        }
        # Fill the template
        template = env.get_template("sundial.svg")
        return template.render(sundial_map)

    def __str__(self):
        def get_coord_string(coordinates, c):
            if c not in coordinates:
                return "-"
            return "{0[0]:0.4f},{0[1]:0.4f}".format(coordinates[c])

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
        table.field_names = ["Angle", "Time", *Sundial.declinations_names]
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
    help="Length of the stylus (default: {:0.4f})".format(DEFAULT_A),
    type=float,
    default=DEFAULT_A,
)
PARSER.add_argument(
    "--l", help="Longitude of the sundial in degrees.", type=float, default=0.0
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
    print(SD.get_svg())
