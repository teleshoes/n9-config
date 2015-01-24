#!/usr/bin/perl
use strict;
use warnings;
use Mail::IMAPClient;
use IO::Socket::SSL;

sub mergeUnreadCounts($);
sub readUnreadCounts();
sub writeUnreadCounts($);
sub getUnreadHeaders($);
sub getClient($);
sub getSocket($);
sub readSecrets();

my $secretsFile = "$ENV{HOME}/.secrets";
my @configKeys = qw(user password server port folder);
my @extraConfigKeys = qw(ssl);

my @headerFields = qw(Date Subject From);
my $unreadCountsFile = "$ENV{HOME}/.unread-counts";

my $settings = {
  Peek => 1,
  Uid => 1,
};

my $usage = "
  $0 -h|--help
    show this message

  $0 [--update] [ACCOUNT_NAME ACCOUNT_NAME ...]
    print unread message headers, and write unread counts to $unreadCountsFile
    if accounts are specified, all but those are ignored
    {ignored or missing accounts are preserved in $unreadCountsFile}

    write the unread counts, one line per account, to $unreadCountsFile
    e.g.: 3:AOL
          6:GMAIL
          0:WORK_GMAIL

  $0 --print [ACCOUNT_NAME ACCOUNT_NAME ...]
    does not fetch anything, merely reads $unreadCountsFile
    format and print $unreadCountsFile
    the string is a space-separated list of the first character of
      each account name followed by the integer count
    no newline character is printed
    if the count is zero for a given account, it is omitted
    if accounts are specified, all but those are omitted
    e.g.: A3 G6

  $0 --is-empty [ACCOUNT_NAME ACCOUNT_NAME ...]
    does not fetch anything, merely reads $unreadCountsFile
    checks for any unread emails
    if accounts are specified, all but those are ignored
    print \"empty\" and exit with zero exit code if there are no unread emails
    otherwise, print \"not empty\" and exit with non-zero exit code
";

sub main(@){
  my $cmd = shift if @_ > 0 and $_[0] =~ /^(--update|--print|--is-empty)$/;
  $cmd = "--update" if not defined $cmd;

  die $usage if @_ > 0 and $_[0] =~ /^(-h|--help)$/;

  my @accNames = @_;
  my $accounts = readSecrets();
  @accNames = sort keys %$accounts if @accNames == 0;

  if($cmd =~ /^(--update)$/){
    my $counts = {};
    for my $accName(@accNames){
      die "Unknown account $accName\n" if not defined $$accounts{$accName};
      my $unread = getUnreadHeaders $$accounts{$accName};
      $$counts{$accName} = keys %$unread;
      for my $uid(sort keys %$unread){
        my $hdr = $$unread{$uid};
        print "$accName $uid $$hdr{Date} $$hdr{Subject}\n"
      }
    }
    mergeUnreadCounts $counts;
  }elsif($cmd =~ /^(--print)/){
    my $counts = readUnreadCounts();
    my @fmts;
    for my $accName(@accNames){
      die "Unknown account $accName\n" if not defined $$counts{$accName};
      my $count = $$counts{$accName};
      push @fmts, substr($accName, 0, 1) . $count if $count > 0;
    }
    print "@fmts";
  }elsif($cmd =~ /^(--is-empty)/){
    my $counts = readUnreadCounts();
    my @fmts;
    for my $accName(@accNames){
      die "Unknown account $accName\n" if not defined $$counts{$accName};
      my $count = $$counts{$accName};
      if($count > 0){
        print "not empty\n";
        exit 1;
      }
    }
    print "empty\n";
    exit 0;
  }
}

sub mergeUnreadCounts($){
  my $counts = shift;
  $counts = {%{readUnreadCounts()}, %$counts};
  writeUnreadCounts($counts);
}
sub readUnreadCounts(){
  my $counts = {};
  if(not -e $unreadCountsFile){
    return $counts;
  }
  open FH, "< $unreadCountsFile" or die "Could not read $unreadCountsFile\n";
  for my $line(<FH>){
    if($line =~ /^(\d+):(.*)/){
      $$counts{$2} = $1;
    }else{
      die "malformed $unreadCountsFile line: $line";
    }
  }
  return $counts;
}
sub writeUnreadCounts($){
  my $counts = shift;
  open FH, "> $unreadCountsFile" or die "Could not write $unreadCountsFile\n";
  for my $accName(sort keys %$counts){
    print FH "$$counts{$accName}:$accName\n";
  }
  close FH;
}

sub getUnreadHeaders($){
  my $acc = shift;
  my $c = getClient $acc;

  if(not defined $c or not $c->IsAuthenticated()){
    warn "Could not authenticate $$acc{name} ($$acc{user})\n";
    return;
  }
  my @folders = $c->folders($$acc{folder});
  if(@folders != 1){
    warn "Error getting folder $$acc{folder}\n";
    return;
  }

  my $f = $folders[0];
  $c->select($f);

  my $unread = {};
  for my $uid($c->unseen){
    $$unread{$uid} = {uid => $uid};
    my $hdr = $c->parse_headers($uid, @headerFields);
    for my $field(@headerFields){
      $$unread{$uid}{$field} = ${$$hdr{$field}}[0];
    }
  }


  return $unread;
}

sub getClient($){
  my $acc = shift;
  my $network;
  if(defined $$acc{ssl} and $$acc{ssl} =~ /^false$/){
    $network = {
      Server => $$acc{server},
      Port => $$acc{port},
    };
  }else{
    $network = {
      Socket => getSocket($acc),
    };
  }
  return Mail::IMAPClient->new(
    %$network,
    User     => $$acc{user},
    Password => $$acc{password},
    %$settings,
  );
}

sub getSocket($){
  my $acc = shift;
  return IO::Socket::SSL->new(
    PeerAddr => $$acc{server},
    PeerPort => $$acc{port},
  );
}

sub readSecrets(){
  my @lines = `cat $secretsFile 2>/dev/null`;
  my $accounts = {};
  my $okConfigKeys = join "|", (@configKeys, @extraConfigKeys);
  for my $line(@lines){
    if($line =~ /^email\.(\w+)\.($okConfigKeys)\s*=\s*(.+)$/){
      $$accounts{$1} = {} if not defined $$accounts{$1};
      $$accounts{$1}{$2} = $3;
    }
  }
  for my $accName(keys %$accounts){
    my $acc = $$accounts{$accName};
    $$acc{name} = $accName;
    for my $key(sort @configKeys){
      die "Missing '$key' for '$accName' in $secretsFile\n" if not defined $$acc{$key};
    }
  }
  return $accounts;
}

&main(@ARGV);
