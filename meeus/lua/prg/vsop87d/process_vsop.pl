print "_planets = {\n";
my $current_planet = "none";
my $current_dim    = "none";

while(<>)
{
    chomp;
    if (/(Mercury)\s+([LBR])/ || /(Venus)\s+([LBR])/  || /(Earth)\s+([LBR])/  || /(Mars)\s+([LBR])/ ||
        /(Jupiter)\s+([LBR])/ || /(Saturn)\s+([LBR])/ || /(Uranus)\s+([LBR])/ || /(Neptune)\s+([LBR])/) {
        if ($current_planet ne $1) { # change planet
            if ($current_planet ne "none") { # not for the first time : close the series, dimension and planet brace
                print "\t\t\t}, -- End of table for $current_series\n";
                print "\t\t},   -- End of table for $current_dim\n";
                print "\t},     -- End of table for $current_planet\n";
            }
            #in all cases, update the planet, dimension, series, then switch to next line
            $current_planet = $1;
            $current_dim    = $2;
            print "\t[\"$current_planet\"] = {\n";
            print "\t\t[\"$current_dim\"] = {\n";
            print "\t\t\t{\n";
            next;
        }
        if ($current_dim ne $2) { # change dimension (but not planet)
            #close the series and dimension brace
            print "\t\t\t},\n";
            print "\t\t},\n";
            # then reopen a series and dimension brace
            $current_dim = $2;
            print "\t\t[\"$current_dim\"] = {\n";
            print "\t\t\t{\n";
        }
        else { # Same dimension : we just changed of series
            print "\t\t\t},\n"; # So we close the previous series and reopen a new one
            print "\t\t\t{\n";
        }
    }
    else {
        # add a new triplet
        m/(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)/;
        print "\t\t\t\t{$1, $2, $3},\n"
    }
}
    # Properly close the table
    print "\t\t\t} -- End of table for $current_series\n";
    print "\t\t}   -- End of table for $current_dim\n";
    print "\t}     -- End of table for $current_planet\n";
    print "}\n";

