#!/usr/bin/perl
use strict;
use warnings;

my $repoDir = 'repos';
my $debDir = 'debs-custom';
my $debDestPrefix = '/opt';

my %pkgGroups = (
  '1' => [qw(
    bash vim rsync wget git
  )],
  '2' => [qw(
    perl bash-completion python python-apt
    mcetools bzip2
    libpurple0
  )],
  '3' => [qw(
    kernel-source linux-kernel-headers
    gcc make libc6-dev libc-dev intltool
  )],
);

sub installPackages();
sub setupRepos();
sub installDebs();

sub main(@){
  die "Usage: $0\n" if @_ > 0;
  if(setupRepos()){
    system 'n9', '-s', 'apt-get', 'update';
  }
  installPackages();
  installDebs();
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
  for my $pkgGroup(sort keys %pkgGroups){
    my @packages = @{$pkgGroups{$pkgGroup}}; 
    print "Installing $pkgGroup:\n----\n@packages----\n";
    my @cmd = ('n9', '-s', 'apt-get',
      'install', @packages,
      '-y', '--force-yes',
    );
    system @cmd;
  }
}

sub getCustomDebsHash(){
  my $cmd = ''
    . "if [ -e \"$debDestPrefix/$debDir/\" ]; then"
    . "  ls $debDestPrefix/$debDir/*.deb | sort | xargs md5sum;"
    . "fi"
    ;
  return `n9 -s '$cmd'`;
}

sub installDebs(){
  my $before = getCustomDebsHash();
  my @debs = `cd $debDir; ls *.deb`;
  chomp foreach @debs;
  print "\n\nSyncing $debDestPrefix/$debDir to $debDestPrefix on dest:\n";
  print "---\n@debs\n---\n";
  system "rsync $debDir root@`n9`:$debDestPrefix -av --progress --delete";
  my $after = getCustomDebsHash();
  if($before eq $after){
    print "not running the below commands because nothing changed:\n";
  }
  for my $deb(@debs){
    my $cmd = ''
      . "dpkg -i $debDestPrefix/$debDir/$deb"
      . " || apt-get -f install -y --force-yes";
    print "$cmd\n";
    system 'n9', '-s', $cmd unless $before eq $after;
  }
}

&main(@ARGV);
