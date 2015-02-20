#!/usr/bin/perl
use strict;
use warnings;

sub main(@){
  if(`whoami` ne "user\n"){
    print "rerunning as user\n";
    exec "udo", $0, @_;
  }
  exec "/opt/qtemail/bin/email.pl";
}

&main(@ARGV);
