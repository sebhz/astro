#!/usr/bin/env python3
""" Computations to create a planar sundial """
import json
from math import radians, cos, sin, tan, fmod, dist
import sys

declinations_dict = {
    -23.44: "Winter Sol.",
    -20.15: "-20.15",
    -11.47: "-11.47",
    0: "Equinox",
    11.47: "11.47",
    20.15: "20.15",
    23.44: "Summer Sol.",
}
declinations = sorted(list(declinations_dict.keys()))


class Sundial:
    """Sundial creation and rendering methods"""

    def __init__(self, **kwargs):
        if kwargs is not None:
            for _ in (
                "phi",
                "declination",
                "zenithal_distance",
                "stylus_length",
                "longitude",
            ):
                _args = kwargs.get(_)
                if _args is None:
                    print(f"ERROR: missing mandatory parameter {_args} (from {_}).")
                    sys.exit()
                setattr(self, _, kwargs.get(_))
        else:
            print("ERROR: missing mandatory parameters.")
            sys.exit()
        phi_r = radians(self.phi)
        D_r = radians(self.declination)
        z_r = radians(self.zenithal_distance)
        self.P = sin(phi_r) * cos(z_r) - cos(phi_r) * sin(z_r) * cos(D_r)
        try:
            self.center = (
                self.stylus_length * cos(phi_r) * sin(D_r) / self.P,
                -self.stylus_length
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
        D_r = radians(self.declination)
        z_r = radians(self.zenithal_distance)
        for H in range(-12, 12):
            H_r = radians(H * 15 + fmod(self.longitude, 15))
            H_coordinates = {}
            for delta in declinations:
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
                p = (self.stylus_length * Nx / Q, self.stylus_length * Ny / Q)
                if dist((0, 0), p) < 30 * self.stylus_length:
                    H_coordinates[delta] = p
            self.hour_lines.append(H_coordinates)

    def to_json(self):
        """Serialize all attributes to JSON"""
        jdict = {}
        for attribute in (
            "phi",
            "declination",
            "zenithal_distance",
            "stylus_length",
            "longitude",
            "center",
            "hour_lines",
            "P",
        ):
            jdict[attribute] = getattr(self, attribute, None)
        return json.dumps(jdict, indent=4)

    def __str__(self):
        return self.to_json()
