#!/usr/bin/perl
#Copyright 2012 Elliot Wolk
#Licensed under the GPLv3
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
use strict;
use warnings;

my $file = '/var/lib/aegis/refhashlist';

my $bakFile = "/tmp/refhashlist-backup-" . `date +%s`;
print "backing up $file to $bakFile\n";
system "cp $file $bakFile";

my @lines = `cat $file`;

my $newOutput;
my @changed;
for my $line(@lines){
  if($line =~ /^
       (.*)
       ([0-9a-f]{40})
       (\s+ [A-Z] \s+
         \d+ \s+ \d+ \s+ \d+ \s+
         [A-Z] \s+ \d+ \s+
         .*
         \s+ [A-Z] \s+ \d+ \s+ )
       (.*)
  $/x){
    my ($start, $oldsha1, $middle, $path) = ($1, $2, $3, $4);
    my $quotedPath = $path;
    $quotedPath =~ s/'/'\\''/g;
    $quotedPath = "'$path'";
    my $newsha1 = `sha1sum /$quotedPath`;
    chomp $newsha1;
    $newsha1 =~ s/^([0-9a-f]{40})  \/$path$/$1/;
    if($newsha1 =~ /^[0-9a-f]{40}$/){
      if($oldsha1 ne $newsha1){
        push @changed, "sha1 changed for file: $path\n$oldsha1 => $newsha1\n";
      }
      $newOutput .= "$start$newsha1$middle$path\n";
    }else{
      $newOutput .= $line;
    }
  }else{
    $newOutput .= $line;
  }
}

print "\n\n";
print @changed;

my $tmpFile = "/tmp/refhashlist-new";
open FH, "> $tmpFile" or die "couldnt write to $tmpFile";
print FH $newOutput;
close FH;

print "replacing $file\n";
system "mv $tmpFile $file";
system "chmod a+w $file";

print "signing $file\n";
system "accli -c tcb-sign -F $file < $file";
