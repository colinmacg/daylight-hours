#!/usr/bin/perl
##################################################################
#
# Name: sunrise_sunset.pl
#
# Description: Calculate the sunrise and sunset times based on lat/long
#	and julian date
#
# WARNING: Longitude is longitude west! Standard recording is long east
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
use POSIX "floor";

use constant DEBUG => 0;

sub date2julian{
	my @today_date;
	
	# If no date is provided, then we use today
	if (scalar(@_) == 0){
		# get today's date and store as year, month, day in an array
		@today_date = split(/-/, `date --utc +%Y-%m-%d`);
	}
	elsif (scalar(@_) == 1){
		@today_date = split(/-/,$_[0]);
	}
	else {
		print "ERROR - only single argument supported. YYYY-MM-DD\n";
		return -1;
	}

	my $c = int(($today_date[1] -3)/12);
	my $x4 = $today_date[0] + $c;
	my $x3 = int($x4 / 100);
	my $x2 = $x4 % 100;
	my $x1 = $today_date[1] - (12 * $c) -3;

	# $JD_int will contain today as the Julian day number at midday
	my $JD_int = int((146097 * $x3) / 4) + int((36525 * $x2) / 100) + int((153 * $x1 + 2) / 5) + $today_date[2] +1721119;

	print "Julian Day: $JD_int\n" if DEBUG;
	return $JD_int;

} # End of date2julian


sub julian2date {
	my $julian_day;

        # If no date is provided, then something is wrong
        if (scalar(@_) == 0){
                print "ERROR - Julian date must be provided as argument\n";
		return -1;
        }
        elsif (scalar(@_) == 1){
                $julian_day = $_[0];
        }
        else {
                print "ERROR - only single argument supported\n";
                return -1;
        }
	print "input Julian day: $julian_day\n";

#	my $p = floor($julian_day + 68569);
#	my $q = floor( (4 * $p) / 146097 );
#	my $r = $p - floor(( 146097 * $q + 3 ) / 4 );
#	my $s = floor( 4000 * ($r + 1) / 1461001 );
#	my $t = $r - floor((1461 * $s) / 4) + 31 ;
#	my $u = floor( (80 * $t) / 2447);
#	my $v = floor( $u / 11);

#	my $Y = floor(100 * ($q - 49) + $s + $v );
#	my $M = floor( $u + 2 - (12 * $v) );
#	my $D = $t - (2447 * floor($u / 80 ));


# Source: http://www.hermetic.ch/cal_stud/jdn.htm
	my $l = floor($julian_day + 68569);
	my $n = floor ( (4 * $l) / 146097);
	$l = $l - floor( (146097 * $n + 3) / 4);
	my $i = floor( 4000 * ( $l + 1) / 1461001 );
	$l = $l - floor ( (1461 * $i) / 4) + 31;
	my $j = floor( (80 * $l) / 2447);
	my $D = $l - floor( (2447 * $j) / 80);
	$l = floor($j / 11);
	my $M = $j + 2 - ( 12 * $l);
	my $Y = 100 * ($n - 49) + $i + $l;

#	my $L = $julian_day + 68569;
#	my $N = floor(4 * $L / 146097);
#	$L = floor( $L - (146097 * $N +3 ) / 4);
#	my $I = floor(4000 * ($L + 1) / 1461001);
#	$L = floor($L - 1461 * $I / 4 + 31);
#	my $J = floor(80 * $L / 2447);
#	my $K = floor($L - 2447 * $J / 80);
#	$L = floor($J / 11);
#	$J = floor($J + 2 - 12 * $L);
#	$I = floor(100 * ($N - 49) + $I + $L);

#	my $Y = $I;
#	my $M = $J;
#	my $D = $K;

####### Worky #######
#	my $a = $julian_day + 32044;
#	my $b = floor( (($a * 4 + 3) / 146097));
#	my $c = $a - floor( ( ($b * 146097) / 4 ) );
#	my $d = floor( ( 4 * $c +3) / 1461);
#	my $e = $c - floor( ((1461 * $d) / 4) );
#	my $m = floor( (5 * $e + 2) / 153);
	
#	my $D = $e - floor( ((153 * $m + 2) / 5)) + 1;
#	my $M = $m + 3 - 12*floor($m/10);
#	my $Y = $b * 100 + $d - 4800 + floor($m/10);
	if( $M <= 9 ){
		return "$Y-0$M-$D";
	}
	else {
		return "$Y-$M-$D";
	}


} #End of julian2date






# longitude is longitude west e.g. west is positive, east is negative
my $latitude = 53.4759;
my $longitude = 9.8949;

my $j_date = date2julian();
my $yearrr = julian2date($j_date);

print "Date: $yearrr\n";

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
