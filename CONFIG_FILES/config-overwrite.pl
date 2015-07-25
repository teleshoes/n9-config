#!/usr/bin/perl
use strict;
use warnings;

my $hostName = "zuserm-n9";

my $DIR = '/opt/CONFIG_FILES';
my $user = "user";
my ($login,$pass,$uid,$gid) = getpwnam($user);
my $binTarget = '/usr/bin';
my $iconsTarget = '/usr/share/themes/blanco/meegotouch/icons';
my $launchersTarget = '/opt/app-launchers';

my @rsyncOpts = qw(
  -a  --no-owner --no-group
  --out-format=%n
);

my $bgDir = '/usr/share/themes/blanco/meegotouch/images/backgrounds';
my %symlinksToReplace = map {$_ => 1} (
  "$bgDir/meegotouch-desktop-bg-events.jpg",
  "$bgDir/meegotouch-desktop-bg-launcher.jpg",
  "$bgDir/meegotouch-desktop-bg-switcher.jpg",
);

my %changedTriggers = (
  "/usr/share/backgrounds" =>  'reload-wallpaper',
  "$bgDir/meegotouch-desktop-bg-events.jpg" => 'reload-wallpaper',
  "$bgDir/meegotouch-desktop-bg-launcher.jpg" => 'reload-wallpaper',
  "$bgDir/meegotouch-desktop-bg-switcher.jpg" => 'reload-wallpaper',
  "/home/user/.config/ProfileMatic/rules.conf" =>
    "initctl restart apps/profilematicd",
  "/var/lib/bluetooth" => "initctl restart xsession/bluetoothd",
  "/home/user/.profiled/custom.ini" => "reload-profile"
);

my $okTypes = join "|", qw(boing bin icons launchers remove all);

my $usage = "Usage: $0 [$okTypes]\n";

sub overwriteFile($$$);
sub removeFile($);
sub md5sum($);

sub main(@){
  my $type = 'all';
  $type = shift if @_ > 0 and $_[0] =~ /^($okTypes)$/;
  die $usage if @_ > 0;

  die "hostname must be $hostName" if `hostname` ne "$hostName\n";

  my @boingFiles = glob "$DIR/%*";
  s/^$DIR\/// foreach @boingFiles;

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
      overwriteFile "$DIR/$file", $dest, 1;
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
    overwriteFile "$DIR/bin/", "$binTarget/", 0;
  }
  if($type =~ /^(icons|all)$/){
    print "\n ---handling icon files...\n";
    overwriteFile "$DIR/icons/", "$iconsTarget/", 0;
  }
  if($type =~ /^(launchers|all)$/){
    print "\n ---handling icon files...\n";
    overwriteFile "$DIR/launchers/", "$launchersTarget/", 0;
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

sub overwriteFile($$$){
  my ($src, $dest, $del) = @_;

  my $parentDir = $dest;
  $parentDir =~ s/\/[^\/]*$//;
  system "mkdir", "-p", $parentDir;

  print "\n%%% $dest\n";
  my @rsyncCmd = ("rsync", @rsyncOpts);
  push @rsyncCmd, "--del" if $del;
  if(-l $src){
    system "rm", $dest if -l $dest;

    my $srcLink = readlink $src;
    if(defined $symlinksToReplace{$dest}){
      system "cp", $srcLink, $dest;
    }elsif(not -e $dest){
      system "ln", "-s", $srcLink, $dest;
    }else{
      die "Cannot replace non-symlink with symlink\n";
    }
  }elsif(-d $src){
    system @rsyncCmd, "$src/", "$dest";
  }else{
    system @rsyncCmd, "$src", "$dest";
  }

  my @chownFiles = ($dest);
  if(not -l $dest and -d $dest){
    @chownFiles = (@chownFiles, glob("$dest/*"));
  }

  my ($chownUid, $chownGid);
  if($dest =~ /^\/home\/$user/){
    ($chownUid, $chownGid) = ($uid, $gid);
  }else{
    ($chownUid, $chownGid) = (0, 0);
  }

  if(not -l $dest){
    chown $chownUid, $chownGid, @chownFiles;
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
