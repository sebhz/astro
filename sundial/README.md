# Planar sundials
Script to help creating a planar sundial, with stylus perpendicular to the sundial plane.
Can either output a table giving points on each hour line of the sundial, or an svg showing the sundial.

## Dependencies
This script depends on python-prettytable for text output formatting, and python-jinja2 for svg templating.

## Parameters
This script takes the following parameters
- `phi`: latitude of the sundial in degrees (e.g. 46.5044339, if sundial located in Tarvisio, IT)
- `D`: gnomonic declination. This is the azimuth of the perpendicular to the sundial plane, measured from the southern meridian, towards west. In degrees.
    - D=0 -> sundial is "due south".
    - D=270 -> sundial is "due east".
- `z`: zenithal distance of the stylus, in degrees.
    - z=0 -> horizontal sundial.
    - z=90 -> vertical sundial.
- `a`: length of the stylus (in an arbitrary unit - same unit is used for all the coordinates).
- `l`: longitude of the sundial in degrees. Positive towards east, negative towards west. Used to rotate the sundial so that it displays "shifted GMT". Use 0 for true solar time.

## Getting points for other sun declinations
Modify the `Sundial.declinations` and the `Sundial.declinations_names` tables.

## Interpreting the output
Coordinates are measured in an orthogonal coordinate system, situated in the sundial plane.
The origin of the system is the base of the stylus. The x-axis is horizontal, measured positively towards the right.
Per the definition of D, the x-axis makes an angle of -D degrees with the west-east direction.
The y-axis coincides with the line of greatest slope of the sundial, and positive upwards.
The center of the sundial is the convergence point of all hour lines.

## Perpendicular vs polar stylus
The perpendicular stylus has length `a`, is perpendicular to the sundial's plane and located at the origin of the coordinate system.
The current time is indicated by the *tip* of the perpendicular stylus.

One can also use a *polar stylus*. Its base is located at the center of the sundial, its tip is the tip of the perpendicular stylus.
The current time is indicated by the *shadow* of the polar stylus. Note that the polar stylus does not always exist (`z=phi` case). If z=phi, the script will (incorrectly) set the sundial center to 0.

## Special cases
- Equatorial sundial: the plane of the sundial is parallel to the equator plane. The sundial has two sides: northern side serves for positive declinations (spring/summer) and the southern side for negative declinations.
    - Northern side: z=90-phi, D=180
    - Southern side: z=90+phi, D=0
- Horizontal sundial: z=0. D is undefined, so one can choose the x-axis direction. To simplify computation, use D=0 (x-axis towards east), but any value will yield the same result.
- Vertical sundial: z=90. x-axis is horizontal, y-axis directed towards the zenith.

## Acknowledgements
Equations were taken from Jan Meeus "Astronomical Algorithms" book, chapter 58. This chapter acknowledges the work of R. Sagot and D. Savoie.

## References
[Astronomical Algorithms](https://www.willbell.com/math/mc1) - Jan Meeus - Willmann-Bell second Edition 1998, with corrections as of June 15 2005

[The mathematics of sundials](https://files.eric.ed.gov/ltext/EJ802706.pdf) - Jill Vincent

[Analemmatic sundials: how to build one and why they work](https://plus.maths.org/content/os/issue11/features/sundials/index) - Chris Sangwin and Chris Budd
