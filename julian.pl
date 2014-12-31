#!/usr/bin/perl
##################################################################
#
# Name: julian.pl
#
# Description: Get the current date and time and calculate the
# Julian (astronomical) date from that
#
# Created on: 31/12/2014
#
# Author: Colin MacGiollaEain
# Contact: colinmac AT flat-planet DOT net
#
# References:
#     http://aa.quae.nl/en/reken/juliaansedag.html
#     http://www.tondering.dk/claus/cal/julperiod.php
#
##################################################################

use warnings;
use strict;


# get today's date and store as year, month, day in an array
my @today_date = split(/\//, `date --utc +%Y/%m/%d`);
# and the current time
my @cur_time = split(/:/, `date --utc +%H:%M:%S`);
# Obviously these values could be overwritten to calculate for a specific date
# and time

my $c = int(($today_date[1] -3)/12);
my $x4 = $today_date[0] + $c;
my $x3 = int($x4 / 100);
my $x2 = $x4 % 100;
my $x1 = $today_date[1] - (12 * $c) -3;

# $JD_int will contain today as the Julian day number at midday
my $JD_int = int((146097 * $x3) / 4) + int((36525 * $x2) / 100) + int((153 * $x1 + 2) / 5) + $today_date[2] +1721119;


# Time HH:MM:SS
# 12:00:00 UTC is considered to be the start of the Julian day, so we need to calculate offsets of that in
# terms of fractions of the Julian day

# 12 hours in seconds
my $zero_hour = 43200;
# Current time converted to seconds
my $current_time = ($cur_time[0] * 3600) + ($cur_time[1] * 60) + $cur_time[2];
# Delta between the two - we want any time before 12:00:00 to be a negative number
my $delta_t = ($current_time - $zero_hour);

# Work out what 1 second is in Julian day fractions by 1/86400
# Then multiply by delta_t to find the adjustment we make e.g. delta_t * (1/86400)
my $j_adjust = $delta_t * (1 / 86400);

printf("Julian Day: %.5f\n",($JD_int + $j_adjust));
