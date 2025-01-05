#!/usr/bin/env python3
""" Computations to create a planar sundial """
import argparse
import sundial

DEFAULT_A = 15.0
PARSER = argparse.ArgumentParser()
PARSER.add_argument(
    "--phi",
    "-p",
    help="Latitude of the sundial in degrees. Positive towards north",
    type=float,
    required=True,
)
PARSER.add_argument(
    "--declination",
    "-D",
    help="Declination of the sundial plane perpendicular in degrees",
    type=float,
    required=True,
)
PARSER.add_argument(
    "--zenithal-distance",
    "-z",
    help="Zenithal distance of the stylus in degrees",
    type=float,
    required=True,
)
PARSER.add_argument(
    "--stylus-length",
    "-s",
    help=f"Length of the stylus (default: {DEFAULT_A:0.4f})",
    type=float,
    default=DEFAULT_A,
)
PARSER.add_argument(
    "--longitude",
    "-l",
    help="Longitude of the sundial in degrees.",
    type=float,
    default=0.0,
)
ARGS = PARSER.parse_args()

SD = sundial.Sundial(**vars(ARGS))
SD.compute_hour_lines()
print(SD)
