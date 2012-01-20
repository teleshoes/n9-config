#!/usr/bin/perl
use strict;
use warnings;

my @packages = qw( bash python parted );
for my $pkg(@packages){
  system 'n9', '-s', 'apt-get', 'install', $pkg;
}
