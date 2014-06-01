#!/usr/bin/perl
use strict;
use warnings;

my $hostName = "wolke-n9";

my $DIR = '/opt/CONFIG_FILES';
my $user = 'user';
my $group = 'users';
my $binTarget = '/usr/bin';

my @rsyncOpts = qw(
  -a  --no-owner --no-group
  --del
  --out-format=%n
);

my $bgDir = '/usr/share/themes/blanco/meegotouch/images/backgrounds';
my %symlinksToReplace = map {$_ => 1} (
  "$bgDir/meegotouch-desktop-bg.jpg",
);

my %changedTriggers = (
  "/usr/share/backgrounds" =>  'reload-wallpaper',
  "$bgDir/meegotouch-desktop-bg.jpg" => 'reload-wallpaper',
  "/home/user/.config/ProfileMatic/rules.conf" =>
    "initctl restart apps/profilematicd",
);

sub overwriteFile($$);
sub removeFile($);
sub md5sum($);

sub main(@){
  my $type = shift;
  $type = 'all' if not defined $type;
  my $okTypes = join "|", qw(boing bin remove all);
  die "Usage: $0 [$okTypes]\n" if @_ > 0 or $type !~ /^($okTypes)$/;
  die "hostname must be $hostName" if `hostname` ne "$hostName\n";

  my @boingFiles = `cd $DIR; ls -d %*`;
  chomp foreach @boingFiles;
  my @binFiles = `cd $DIR/bin; ls -d *`;
  chomp foreach @binFiles;
  my @filesToRemove = `cat $DIR/config-files-to-remove`;
  chomp foreach @filesToRemove;

  my %triggers;

  if($type =~ /^(boing|all)$/){
    print "\n ---handling boing files...\n";
    for my $file(@boingFiles){
      my $dest = $file;
      $dest =~ s/%/\//g;
      my ($old, $new);
      if(defined $changedTriggers{$dest}){
        $old = md5sum $dest;
      }
      overwriteFile "$DIR/$file", $dest;
      if(defined $changedTriggers{$dest}){
        $new = md5sum $dest;
        if($old ne $new){
          print "   ADDED TRIGGER: $changedTriggers{$dest}\n";
          $triggers{$changedTriggers{$dest}} = 1;
        }
      }
    }
  }

  if($type =~ /^(bin|all)$/){
    print "\n ---handling bin files...\n";
    for my $file(@binFiles){
      overwriteFile "$DIR/bin/$file", "$binTarget/$file";
    }
  }

  if($type =~ /^(remove|all)$/){
    print "\n ---removing files to remove...\n";
    for my $file(@filesToRemove){
      chomp $file;
      removeFile $file;
    }
  }

  print "\n ---running triggers...\n";
  for my $trigger(keys %triggers){
    print "  $trigger: \n";
    system $trigger;
  }
  system "chmod", "0440", "/etc/sudoers";
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

  if(defined $symlinksToReplace{$dest} and -l $dest){
    my $realDest = readlink $dest;
    system "cp", $realDest, $dest;
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

sub md5sum($){
  my $file = shift;
  my $out;
  if(-d $file){
    $out = `find "$file" -type f -exec md5sum {} \\; 2>/dev/null | sort`;
  }else{
    $out = `md5sum $file 2>/dev/null`;
    chomp $out;
  }
  return $out;
}
&main(@ARGV);
