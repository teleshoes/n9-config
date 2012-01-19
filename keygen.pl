#!/usr/bin/perl
use strict;
use warnings;

chdir "$ENV{HOME}/.ssh";

my $host = `n9`;
chomp $host;
my $pubKeyName = 'n9.pub';

sub keygen($){
  my $user = shift;
  my $group = $user eq 'user' ? 'users' : $user;
  system 'ssh', "$user\@$host", "
    set -x
    mkdir -p ~/.ssh
    chmod go-w ~/.ssh
    chown $user.$group ~/
    rm ~/.ssh/*
    ssh-keygen -t rsa -N \"\" -q -f ~/.ssh/id_rsa
    mv ~/.ssh/id_rsa.pub ~/.ssh/$pubKeyName
  ";
  system "scp $user\@$host:~/.ssh/$pubKeyName .";
  system "scp *.pub $user\@$host:~/.ssh";

  system 'ssh', "$user\@$host", "
    cat ~/.ssh/*.pub > ~/.ssh/authorized_keys
  ";
}


print "removing previous rsa host key from known hosts for $host\n\n";
system "ssh-keygen -f ~/.ssh/known_hosts -R $host";

print "add a user password so we dont have to fuss (we'll delete it later)\n\n";
system 'ssh', "root\@$host", 'passwd user';

print "setting up root\n\n";
keygen 'root';
print "setting up user\n\n";
keygen 'user';

print "deleting user password\n\n";
system 'ssh', "root\@$host", 'passwd -d user';

system "cat *.pub > authorized_keys";

