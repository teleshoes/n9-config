#!/usr/bin/perl
use strict;
use warnings;

my $repoName="home-rzr-harmattan";

my $url = ''
  . "http://repo.pub.meego.com/home:"
  . "/rzr:"
  . "/harmattan/MeeGo_1.2_Harmattan_Maemo.org_MeeGo_1.2_Harmattan_standard/"
  ;

my $line = "deb $url ./";
my $file = "/etc/apt/sources.list.d/$repoName.list";

system 'n9', '-s', "
  killall pkgmgrd && killall pkgmgrd
  echo '$line' | tee $file
  apt-get update
";


my @packages = qw( n9tweak rsync vim );
system 'n9', '-s', 'apt-get', 'install', @packages;
