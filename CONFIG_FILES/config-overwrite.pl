#!/usr/bin/perl
use strict;
use warnings;

my $DIR = '/opt/CONFIG_FILES';
my @files = `ls -d $DIR/%*`;

my @rsyncOpts = qw(
  -a  --no-owner --no-group
  --del
  --out-format=%n
);

for my $file(@files){
  chomp $file;
  $file =~ s/^.*\///;
  my $src = "$DIR/$file";
  my $dest = $file;
  $dest =~ s/%/\//g;
  my $destDir = `dirname $dest`;
  chomp $destDir;
  system "mkdir -p $destDir";
  print "\n%%% $dest\n";
  if(-d $src){
    system 'rsync', @rsyncOpts, "$src/", "$dest";
  }else{
    system 'rsync', @rsyncOpts, "$src", "$dest";
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
