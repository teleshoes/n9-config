#!/usr/bin/perl
use strict;
use warnings;

my $DIR = '/opt/CONFIG_FILES';
my $user = 'user';
my $group = 'users';
my $binTarget = '/usr/local/bin';

my @rsyncOpts = qw(
  -a  --no-owner --no-group
  --del
  --out-format=%n
);

sub overwriteFile($$);
sub removeFile($);

sub main(@){
  die "Usage: $0\n" if @_ > 0;
  my @boingFiles = `cd $DIR; ls -d %*`;
  chomp foreach @boingFiles;
  my @binFiles = `cd $DIR/bin; ls -d *`;
  chomp foreach @binFiles;
  my @filesToRemove = `cat $DIR/config-files-to-remove`;
  chomp foreach @filesToRemove;

  print "\n ---handling boing files...\n";
  for my $file(@boingFiles){
    my $dest = $file;
    $dest =~ s/%/\//g;
    overwriteFile "$DIR/$file", $dest;
  }

  print "\n ---handling bin files...\n";
  for my $file(@binFiles){
    overwriteFile "$DIR/bin/$file", "$binTarget/$file";
  }

  print "\n ---removing files to remove...\n";
  for my $file(@filesToRemove){
    chomp $file;
    removeFile $file;
  }
}

sub overwriteFile($$){
  my ($src, $dest) = @_;
  my $destDir = `dirname $dest`;
  chomp $destDir;
  system "mkdir -p $destDir";
  print "\n%%% $dest\n";
  if(-d $src){
    system 'rsync', @rsyncOpts, "$src/", "$dest";
  }else{
    system 'rsync', @rsyncOpts, "$src", "$dest";
  }
  if($destDir =~ /^\/home\/$user/){
    system "chown -R $user.$group $dest";
    system "chown $user.$group $destDir";
  }else{
    system "chown -R root.root $dest";
    system "chown root.root $destDir";
  }
}

sub removeFile($){
  my $file = shift;
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

&main(@ARGV);
