#!/usr/bin/perl
use strict;
use warnings;

sub fixSize($$$);

my $profiles = {
  ringing => 'general',
  beep => 'meeting',
  silent => 'silent',
};

my $conf = {
  ringtone => 'ringing.alert.tone',
  alarm => 'clock.alert.tone',
  internetCallAlert => 'voip.alert.tone',
  mailAlertTone => 'email.alert.tone',
  messageAlertTone => 'sms.alert.tone',
  chatAlertTone => 'im.alert.tone',
  calendarAlarmTone => 'calendar.alert.tone',

  systemSoundLevel => 'system.sound.level',
  ringingVolume => 'ringing.alert.volume',
  vibrationProfile => 'vibrating.alert.enabled', #Off
};

my $s = "# custom profile values
[general]

clock.alert.tone=/usr/share/sounds/ring-tones/Bubbles.mp3

[meeting]

clock.alert.tone=/usr/share/sounds/ring-tones/Bubbles.mp3

[outdoors]

clock.alert.tone=/usr/share/sounds/ring-tones/Bubbles.mp3

[silent]

clock.alert.tone=/usr/share/sounds/ring-tones/Bubbles.mp3

";

my $ringingVolumes = [40, 60, 80, 100];
sub main(@){
  $s = fixSize $s, 4096, 78;
  open FH, "> a";
  print FH $s;
  close FH;
}

sub fixSize($$$){
  my ($s, $size, $perLine) = @_;
  my $target = $size - length $s;
  while($target > $perLine){
    $s .= ("#"x($perLine - 1)) . "\n";
    print "$target\n";
    $target = $size - length $s;
  }
  $s .= ("#"x($target - 1)) . "\n";
  return $s;
}
&main(@ARGV);
