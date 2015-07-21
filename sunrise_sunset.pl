#!/usr/bin/perl
##################################################################
#
# Name: julian.pl
#
# Description: Get the current date and time and calculate the
# Julian (astronomical) date from that
#
# Created on: 21/07/2015
#
# Author: Colin MacGiollaEain
# Contact: colinmac AT flat-planet DOT net
#
# References:
#	https://en.wikipedia.org/wiki/Sunrise_equation#Calculate_sunrise_and_sunset
#	http://users.electromagnetic.net/bu/astro/sunrise-set.php
#
##################################################################

use warnings;
use strict;
use Math::Trig;
# Perls MOD operator assumes it is working on integers which causes issues
use POSIX "fmod";

use constant DEBUG => 0;

# longitude is longitude west e.g. west is positive, east is negative
my $latitude = 53.4759;
my $longitude = 9.8949;

my $j_date = 2457225;


# Julian Cycle
my $n_star = $j_date - 2451545.0009 - ( $longitude / 360 );
my $n = int($n_star + 0.5);
print "N value: $n\n" if DEBUG;

# Solar Noon - approximation
my $j_star = 2451545.0009 + ($longitude / 360) + $n;
print "Solar Noon: $j_star\n" if DEBUG;

#Solar Mean Anomoly
my $M = fmod( (357.5291 + ( 0.98560028 * ($j_star - 2451545))),360);
print "Solar Mean Anomoly: $M\n" if DEBUG;

#Equation of the center (note that Perl math functions use radians)
my $C = 1.9148 *  sin(deg2rad($M)) + 0.0200 * sin(deg2rad( 2 * $M )) + 0.0003 * sin(deg2rad( 3 * $M ));
print "Equation of Center: $C\n" if DEBUG;

# Ecliptic longitude of the sun
my $lambda = fmod( ( $M + 102.9372 + $C + 180 ),360);
print "Ecliptic longitude: $lambda\n" if DEBUG;

# Solar Transit
my $J_transit = $j_star + 0.0053 * sin(deg2rad($M)) - 0.0069 * sin(deg2rad( 2 * $lambda ));
print "Solar Transit: $J_transit\n" if DEBUG;


# Refine the transit times forther with an iterative loop
# All testing has it converging in 2 iterations, so 5 is more then enough
for (my $i =0; $i < 5; $i++){
	$M = fmod( (357.5291 + ( 0.98560028 * ($J_transit - 2451545))),360);
	$C = 1.9148 *  sin(deg2rad($M)) + 0.0200 * sin(deg2rad( 2 * $M )) + 0.0003 * sin(deg2rad( 3 * $M ));
	$lambda = fmod( ( $M + 102.9372 + $C + 180 ),360);
	$J_transit = $j_star + 0.0053 * sin(deg2rad($M)) - 0.0069 * sin(deg2rad( 2 * $lambda ));
	print "I$i: M = $M, C = $C, lambda = $lambda, J-transit = $J_transit\n" if DEBUG;
}

# Declination of the Sun
my $sin_decSun = sin(deg2rad( $lambda )) * sin(deg2rad( 23.45 ));
my $decSun = rad2deg( asin_real( $sin_decSun ) );
print "Sin (declination): $sin_decSun\n" if DEBUG;
print "Declination of the Sun: $decSun\n" if DEBUG;

# Hour angle
my $cos_W = ( sin(deg2rad( -0.83 )) - ( sin(deg2rad( $latitude )) * $sin_decSun)) / (  cos(deg2rad( $latitude )) *  cos(deg2rad( $decSun ))  );
my $W = rad2deg( acos_real( $cos_W ) );
print "Hour Angle: $W\n" if DEBUG;

# Calculate sunrise and sunset
#my $j_set = $J_transit + ( $W / 15 );
#my $j_rise = $J_transit - ( $W  / 15);

my $J_starStar = 2451545 + 0.0009 + (($W + $longitude)/360) + $n;
print "Refined J = $J_starStar\n" if DEBUG;

my $j_set = $J_starStar + (0.0053 *  sin(deg2rad($M)) ) - ( 0.0069 *  sin(deg2rad( 2 * $lambda )) );
my $j_rise = $J_transit - ($j_set - $J_transit);

print "Sunset: $j_set\n";
print "Sunrise: $j_rise\n";
