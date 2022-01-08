#!/usr/bin/env python3


def get_vsop87_include(body, vsop_name_root):
    fname = vsop_name_root.upper() + "." + body[0:3]
    with open("raw" + "/" + fname) as f:
        buf = f.readlines()

    triplets = list()
    num_series = [0, 0, 0]
    terms_per_series = [list(), list(), list()]
    for line in buf:
        v = line.split()
        if v[0] == "VSOP87":  # Start of series
            coord = int(v[5]) - 1
            num_series[coord] += 1  # increment series count for this coordinate
            terms_per_series[coord].append(int(v[8]))
        else:  # Series value - very simple, just add the coord triplet to the list
            triplets.append(tuple(v[-3:]))

    # We now have all that we need - let's write the .h.
    # We could use ninja templating - but let's make it simple.
    include_str = "struct vsop_planetary_components %s_%s_pc = {\n" % (
        vsop_name_root,
        body,
    )
    include_str += "    .num_series = { %d, %d, %d },\n" % tuple(num_series)
    include_str += "    .terms_per_series = {\n"
    for term_per_serie in terms_per_series:
        include_str += "        (int[]){ "
        for v in term_per_serie:
            include_str += "%d, " % (v)
        include_str += "},\n"
    include_str += "        },\n"
    include_str += "    .coefs = *(double[][3]) {\n"
    for coefs in triplets:
        include_str += "        { %.11f, %.11f, %.11f },\n" % tuple(
            [float(i) for i in coefs]
        )
    include_str += "    }\n};\n\n"

    return include_str


bodys = ("mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune")
str_i = """#ifndef _VSOP87_H
#define _VSOP87_H
struct vsop_planetary_components {
    int num_series[3];
    int *terms_per_series[3];
    double *coefs;
};

"""

#for vsop_version in ("vsop87a", "vsop87b", "vsop87c", "vsop87d", "vsop87e"):
for vsop_version in ("vsop87d",):  # Only one in Meeus astronomical algorithms
    for body in bodys:
        str_i += get_vsop87_include(body, vsop_version)

    str_i += "struct vsop_planetary_components *%s_planetary_components[%d] = {\n" % (
        vsop_version,
        len(bodys),
    )
    for body in bodys:
        str_i += "    &%s_%s_pc,\n" % (vsop_version, body)
    str_i += "};\n\n#endif"

print(str_i)
