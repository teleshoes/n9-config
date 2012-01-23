#!/usr/bin/perl
use strict;
use warnings;

system 'n9', '-s', 'apt-get', 'update';

my @packages = qw(
  bash bash-completion
  parted git
  python perl
  kernel-source linux-kernel-headers
  gcc make libc6-dev libc-dev bzip2);
system 'n9', '-s', 'apt-get', '-y', '--force-yes', 'install', @packages;

my @debs = `ls packages/`;

print "\n\nCopying and installing these debs:\n---\n@debs---\n";
my $dir = '/opt/manual-packages';
system "rsync packages/ root@`n9`:$dir -av --progress --delete";
for my $deb(@debs){
  chomp $deb;
  system 'n9', '-s', 'dpkg', '-i', "$dir/$deb"; 
}
