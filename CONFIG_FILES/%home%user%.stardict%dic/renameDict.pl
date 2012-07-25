#!/usr/bin/perl
use strict;
use warnings;

for my $dir(`ls -dA *`){
  chomp $dir;
  my $ifo = `ls '$dir'/*ifo 2>/dev/null`;
  chomp $ifo;
  if(-e $ifo){
    my $out = `cat '$ifo'`;
    if($out =~ /^bookname=(.*)$/m){
      my $old = $1;
      my $new = $dir;
      if($old ne $new){
        print "renamed $old => $new\n";
        $out =~ s/bookname=.*/bookname=$new/;
      }
    }
    open FH, "> $ifo";
    print FH $out;
    close FH;
  }
}
