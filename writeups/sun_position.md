# Computing Sun path

We want to compute the sun path.
The general problem to solve is to compute a celestial body (here, the Sun) position, at a given *sidereal time*, at our given *latitude*.

The values we need to compute are:
- Sun azimuth `A`
- Sun altitude `h`

![Azimuth/Altitude definition drawing][azimuth_png]

## Getting azimuth and altitude

According to [Meeus][1], chapter 13, azimuth (`A`) and altitude (`h`) are obtained by:
```
tan(A) = sin(H)/(cos(H)*sin(phi) - tan(delta)*cos(phi))
sin(h) = sin(phi)*sin(delta) + cos(phi)*cos(delta)*cos(H)
```

Where:

- `H` is the local hour angle, measured westward from the south.
- `phi` is the observer's latitude, positive in the northern hemisphere, negative in the sourthern hemisphere
- `delta` is the celestial body declination, positive if north of the celestial equator, negative if south.

The actual computations to get to this formula involve spherical trigonometry. See for example the [Astronomical navigation demystified][2] web site for a bit more details. Or [Wikipedia][3] for some gory details.

`phi` is known. So our problem boils down to computing the local hour angle (`H`) and the sun declination (`delta`).

### Getting the local hour angle

If `theta` is the local sidereal time and `alpha` the celestial body right ascension, then we have:

```
H = theta - alpha
```

Let's have `theta0` the sidereal time at Greenwich, and `L` the observer longitude. We have:

```
theta = theta0 -L
```

and so
```
H = theta0 - L - alpha
```

So our problem boils down to getting the sun *equatorial coordinates* `alpha` and `delta`, and the current sidereal time at Greenwich.

### Getting current sidereal time at Greenwich
[Meeus][1], chapter 12.

`theta0` depends on the Julian day for the current date at 0 UT, which can obtained from [Meeus][1], chapter 7.

### Getting equatorial coordinates of the Sun
![Equatorial coordinates][equatorial_png]

[Meeus][1], chapter 25 comes to the rescue.

It gives two methods to compute the Sun mean and apparent equatorial coordinates, with low and high accuracy.
To get the apparent coordinates, one must also compute the Earth nutation in longitude... which is given by Meeus chapter 22.

## In a nutshell
1. Get the Julian Day for the date and time considered (Meeus 7),
2. Get the sidereal time at Greenwich corresponding to our JD (Meeus 12),
3. Compute the sun apparent equatorial coordinates at the considered JD (Meeus 25 and 22),
4. Compute the local hour angle at the observer's longitude, from the Sun's right ascension and the sidereal time at Greenwich,
5. Compute the sun azimuth and elevation at the observer position, from the Sun's apparent equatorial coordinates and the observer latitude and local hour angle (Meeus 13),
6. Possibly correct for atmospheric refraction - if one needs the  apparent (=observed) and not the true (=airless/calculated) position (Meeus 16).

[1]:https://www.willbell.com/math/MC1.HTM
[2]:https://astronavigationdemystified.com/calculating-azimuth-and-altitude-at-the-assumed-position-by-spherical-trigonometry
[3]:https://en.wikipedia.org/wiki/Spherical_trigonometry
[azimuth_png]:https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Azimuth-Altitude_schematic.svg/500px-Azimuth-Altitude_schematic.svg.png
[equatorial_png]:https://upload.wikimedia.org/wikipedia/commons/9/98/Ra_and_dec_on_celestial_sphere.png

