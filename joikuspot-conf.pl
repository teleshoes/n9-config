#!/usr/bin/perl
use strict;
use warnings;

sub formatSection($$);
sub run(@);

my $hotspotConf = "$ENV{HOME}/Code/n9/hotspot.conf";
my $destDir = "/home/user/.config/Joikusoft";
my $dest = "$destDir/JoikuSpot.conf";

my $joikuConf = {
  wlan => {
    ssid => '',
    CLASS => '2',
    localip => '192.168.20.1',
    channel => '0',
    encmode => '2',
    enckey => '',
  },
  dhcp => {
    minip => '20',
    maxip => '30',
    leasetime => '25',
    dnsip => '255.255.255.255',
    usednsip => '0',
  },
  nat => {
    minport => '61000',
    maxport => '65000',
  },
  wan => {
    iap => '',
    iapid => '',
  },
  '%General' => {
    version => '1',
    eula => 'true',
  },
};

sub main(@){
  die "Usage: $0\n" if @_ != 0;
  my $conf = `cat $hotspotConf 2>/dev/null`;
  my ($ssid, $wep, $ip);
  if($conf =~ /^SSID=(.*)\nWEP=(.*)\nIP=(.*)\n$/){
    ($ssid, $wep, $ip) = ($1, $2, $3);
  }else{
    die "bad conf: $conf\n e.g.:\nssid=<SSID>\nWEP=<WEP>\nIP=<IP>\n";
  }

  $$joikuConf{wlan}{ssid} = $ssid;
  $$joikuConf{wlan}{enckey} = $wep;
  $$joikuConf{wlan}{localip} = $ip;

  my @sectionNames = reverse sort keys %$joikuConf;
  my @sections = map {formatSection $_, $$joikuConf{$_}} @sectionNames;
  my $tmpFile = "/tmp/joiku-spot-" . time . "-conf";

  my $content = join "\n", @sections;
  open FH, "> $tmpFile" or die "Couldnt write $tmpFile\n";
  print FH join "\n", @sections;
  close FH;

  my $host = `n9`;
  chomp $host;

  run "ssh", "user\@$host", "mkdir -p $destDir";

  print $content;
  print "\nCopying above to phone..\n";

  run "scp", $tmpFile, "user\@$host:$dest";
  print "done\n";
}

sub formatSection($$){
  my ($sectionName, $sectionKeys) = @_;
  my $out = '';
  $out .= "[$sectionName]\n";
  for my $key(sort keys %$sectionKeys){
    $out .= "$key=$$sectionKeys{$key}\n";
  }
  return $out;
}

sub run(@){
  print "@_\n";
  system @_;
  die "@_ failed\n" if $? != 0;
}

&main(@ARGV);
