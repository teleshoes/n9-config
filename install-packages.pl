#!/usr/bin/perl
use strict;
use warnings;

system 'n9', '-s', 'apt-get', 'update';

my @packages = qw( bash python parted );
for my $pkg(@packages){
  system 'n9', '-s', 'apt-get', 'install', $pkg;
}
