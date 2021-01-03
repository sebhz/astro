An implementation of some of the cabalistic formulas from Jan Meeus, in his [Astronomical Algorithms (Willman-Bell, 2nd edition)][1].

This was written to create monitors for tiling window managers, hence the odd choice of languages:
- I used the Lua code with [Notion][2]. It can probably work also with [Awesome][3] or another WM using lua-based configuration and monitors,
- I use the bash code with [dwm][4].

For a recent and more complete implementation of Meeus formulas in a fashionable language, [pymeeus][6], seems to be very decent !

The code comes with a few examples. See README.md under the `prg` subdirectories.

The original Lua code was heavily based on Bill Mc Clain astrolabe python library. Astrolabe is not available anymore. It was forked by Tim Cera, creating the [astronomia library][5] which seems to have evolved into something larger than just Meeus formulas implementation. The bash code came mostly out of boredom, to check what could be done using only shell and [bc][7].

[1]:https://www.willbell.com/mathmc1.htm
[2]:http://notion.sourceforge.net
[3]:https://awesomewm.org
[4]:https://dwm.suckless.org
[5]:https://pypi.python.org/pypi/astronomia
[6]:https://pypi.org/project/PyMeeus
[7]:https://www.gnu.org/software/bc
