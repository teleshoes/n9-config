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
  if($destDir =~ /^\/home\/user/){
    system "chown -R user.users $dest";
    system "chown user.users $destDir";
  }else{
    system "chown -R root.root $dest";
    system "chown root.root $destDir";
  }
}

for my $file(`cat $DIR/config-files-to-remove`){
  chomp $file;
  if(-e $file){
    if(-d $file){
      $file =~ s/\/$//;
      $file .= '/';
      print "\nremoving these files in $file:\n";
      system "find $file";
    }else{
      print "\nremoving $file\n";
    }
    system "rm -r $file";
  }
}
