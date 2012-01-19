#!/usr/bin/perl
use strict;
use warnings;

my $DIR = '/opt/CONFIG_FILES';
my @files = `ls -d $DIR/%*`;

for my $file(@files){
  chomp $file;
  $file =~ s/^.*\///;
  my $src = "$DIR/$file";
  my $dest = $file;
  $dest =~ s/%/\//g;
  if(-d $src){
    system "rsync -av --del $src/ $dest";
  }else{
    system "rsync -av --del $src $dest";
  }
  if($dest =~ /^\/home\/user/){
    system "chown -R user.users $dest";
  }else{
    system "chown -R root.root $dest";
  }
}

for my $file(`cat $DIR/config-files-to-remove`){
  chomp $file;
  if(-e $file){
    system "rm -r $file";
  }
}
