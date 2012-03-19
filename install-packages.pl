#!/usr/bin/perl
use strict;
use warnings;

my $repoDir = 'repos';
my $debDir = 'debs-custom';
my $debDestPrefix = '/opt';

my @packagesToRemove = qw( wxapp );

my $env = 'AEGIS_FIXED_ORIGIN=com.nokia.maemo';

my %pkgGroups = (
  '1' => [qw(
    bash vim rsync wget git openvpn
  )],
  '2' => [qw(
    perl bash-completion python python-apt
    mcetools bzip2 sqlite3
    x11-utils xresponse
    imagemagick
    python-pyside.qtgui python-qmsystem python-pyside.qtdeclarative
  )],
  '3' => [qw(
    linux-kernel-headers
    gcc make
  )],
);

sub installPackages();
sub removePackages();
sub setupRepos();
sub installDebs($);

sub main(@){
  my $arg = shift;
  $arg = 'all' if not defined $arg;
  if(@_ > 0 or $arg !~ /^(all|repos|packages|remove|debs)$/){
    die "Usage: $0 [all|repos|packages|remove|debs]\n";
  }
  if($arg =~ /^(all|repos)$/){
    if(setupRepos()){
      system 'n9', '-s', $env, 'apt-get', 'update';
    }
  }
  installPackages() if $arg =~ /^(all|packages)$/;
  removePackages() if $arg =~ /^(all|remove)$/;
  installDebs($arg eq 'debs') if $arg =~ /^(all|debs)$/;
}


sub getRepos(){
  #important to sort the files and not the lines
  my $cmd = 'ls /etc/apt/sources.list.d/*.list | sort | xargs cat';
  return `n9 -s '$cmd'`;
}

sub setupRepos(){
  my $before = getRepos();
  my $host = `n9`;
  chomp $host;

  my @repos = `ls $repoDir/*.list`;
  foreach my $repo(@repos){
    chomp $repo;
    print "copying $repo:\n";
    print "====\n";
    system 'cat', $repo;
    print "====\n\n";
  }

  system 'scp', @repos, "root\@$host:/etc/apt/sources.list.d/";
  
  my $after = getRepos();
  return $before ne $after;
}

sub installPackages(){
  print "\n\n";
  for my $pkgGroup(sort keys %pkgGroups){
    my @packages = @{$pkgGroups{$pkgGroup}}; 
    print "Installing group[$pkgGroup]:\n----\n@packages\n----\n";
    my @cmd = ('n9', '-s', $env, 'apt-get',
      'install', @packages,
      '-y', '--allow-unauthenticated',
    );
    system @cmd;
  }
}

sub removePackages(){
  print "\n\n";
  my $pkgs = join ' ', @packagesToRemove;
  my $cmd = "$env apt-get remove --purge $pkgs -y";
  print "$cmd\n";
  system 'n9', '-s', $cmd;
}

sub getCustomDebsHash(){
  my $cmd = ''
    . "if [ -e \"$debDestPrefix/$debDir/\" ]; then"
    . "  ls $debDestPrefix/$debDir/*.deb | sort | xargs md5sum;"
    . "fi"
    ;
  return `n9 -s '$cmd'`;
}

sub installDebs($){
  my $force = shift;
  my $before = getCustomDebsHash();
  my @debs = `cd $debDir; ls *.deb`;
  chomp foreach @debs;
  print "\n\nSyncing $debDestPrefix/$debDir to $debDestPrefix on dest:\n";
  print "---\n@debs\n---\n";
  system "rsync $debDir root@`n9`:$debDestPrefix -av --progress --delete";
  my $after = getCustomDebsHash();
  my $changed = $before ne $after;
  my @commands;
  for my $deb(@debs){
    push @commands, ''
      . "$env dpkg -i -E $debDestPrefix/$debDir/$deb"
      . " || $env apt-get -f install -y --allow-unauthenticated";
  }
  if($changed or $force){
    my $cmd = join ";", map {"echo; echo ---; echo $_; $_"} @commands;
    system 'n9', '-s', $cmd;
  }else{
    print "#NOT CHANGED\n";
    print join("\n", @commands) . "\n";
    print "#NOT CHANGED\n";
  }
  print "fennec may need reinstall, gotta fix this later\n";
}


&main(@ARGV);
