#!/usr/bin/perl
use strict;
use warnings;

my $sshDir = "$ENV{HOME}/.ssh";
my $host = `n9`;
chomp $host;

sub run(@){
  print "@_\n";
  system @_;
}

#makes the keys on the host, and appends to local .pub {local=>remote}
sub keygen($){
  my $user = shift;
  my $group = $user eq 'user' ? 'users' : $user;

  run 'ssh', "$user\@$host", "
    set -x
    mkdir -p ~/.ssh
    chmod go-w ~/.ssh
    chown $user.$group ~/
    rm ~/.ssh/*
    ssh-keygen -t rsa -N \"\" -q -f ~/.ssh/id_rsa
  ";

  run "ssh $user\@$host 'cat ~/.ssh/id_rsa.pub' >> $sshDir/$host.pub";
}

#copies the local pub keys and authorizes them {remote=>local}
sub keyCopy($){
  run "scp $sshDir/*.pub $_[0]\@$host:~/.ssh";
  run 'ssh', "$_[0]\@$host", "cat ~/.ssh/*.pub > ~/.ssh/authorized_keys";
}

sub main(@){
  die "Usage: $0\n" if @_ > 0;

  run 'rm', "$sshDir/$host.pub";
  run 'ssh', "root\@$host", 'passwd user';

  keygen 'root';
  keygen 'user';
  keyCopy 'root';
  keyCopy 'user';

  run 'ssh', "root\@$host", 'passwd -d user';
  run "cat $sshDir/*.pub > $sshDir/authorized_keys";
}

&main(@ARGV)
