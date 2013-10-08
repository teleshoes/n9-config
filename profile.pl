#!/usr/bin/perl
use strict;
use warnings;


my $rtDir = "/usr/share/sounds/ring-tones";
my @profiles = qw(general meeting outdoors silent);
my $ringingVolumes = [40, 60, 80, 100];
my $systemVolumes = [0, 1, 2, 3];

sub generateProfile($$);
sub fixSize($$$);

my $tones = {
  ringing => undef,
  voip => undef,
  email => undef,
  sms => undef,
  im => undef,
  calendar => undef,
  clock => undef,
};

my $ringingVolume = $$ringingVolumes[3];
my $systemVolume= $$systemVolumes[1];

my $vibrate = {
  general => 1,
  meeting => 1,
  outdoors => 1,
  silent => 1,
};

my @attributes = (
  ['ringing.alert.tone'      => "$rtDir/Nokia tune.mp3"],
  ['voip.alert.tone'         => "$rtDir/Nokia tune.mp3"],
  ['email.alert.tone'        => "$rtDir/Email 1.mp3"],
  ['sms.alert.tone'          => "$rtDir/Message 1.mp3"],
  ['im.alert.tone'           => "$rtDir/Chat alert.wav"],
  ['calendar.alert.tone'     => "$rtDir/Calendar 1.mp3"],
  ['clock.alert.tone'        => "$rtDir/Clock 1.mp3"],

  ['system.sound.level'      => 1],
  ['ringing.alert.volume'    => 100],
  ['vibrating.alert.enabled' => undef],
);

my @attNames = map {$$_[0]} @attributes;
my %defaultValues = map{$$_[0] => $$_[1]} @attributes;

sub main(@){
  my $s = "# custom profile values\n";
  for my $profile(@profiles){
    my %props = map {("$_.alert.tone" => $$tones{$_})} keys %$tones;
    $props{'vibrating.alert.enabled'} = "Off" if $$vibrate{$profile} == 0;
    $props{'ringing.alert.volume'} = $ringingVolume if $profile eq "general";
    $props{'system.sound.level'} = $systemVolume if $profile ne "silent";
    $s .= generateProfile $profile, \%props;
  }
  $s = fixSize $s, 4096, 78;
  print $s;
}

sub generateProfile($$){
  my ($profile, $props) = @_;
  my @lines;
  for my $attName(@attNames){
    my $val = $$props{$attName};
    $val = undef if defined $val and $val eq $defaultValues{$attName};
    push @lines, "$attName=$val\n" if defined $val;
  }
  @lines = sort @lines;
  return "" if @lines == 0;
  return "[$profile]\n\n" . (join '', @lines) . "\n";
}

sub fixSize($$$){
  my ($s, $size, $perLine) = @_;
  my $target = $size - length $s;
  while($target > $perLine){
    $s .= ("#"x($perLine - 1)) . "\n";
    $target = $size - length $s;
  }
  $s .= ("#"x($target - 1)) . "\n";
  return $s;
}
&main(@ARGV);
