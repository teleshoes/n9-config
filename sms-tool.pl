#!/usr/bin/perl
use strict;
use warnings;

my $smsDir = "$ENV{HOME}/Code/n9/backup/backup-sms";
my $repoDir = "$ENV{HOME}/Code/n9/backup/backup-sms/repo";

sub main(@){
  my $arg = shift;
  $arg = '' if not defined $arg;
  die "Usage: $0 split|join\n" if $arg !~ /^(split|join)$/ or @_ > 0;

  if($arg eq 'split'){
    my @messages = getMessagesFromDir($smsDir);
    system "mkdir -p $repoDir";
    system "rm $repoDir/*.sms";
    writeContactsFiles(\@messages, $repoDir);
  }elsif($arg eq 'join'){
    my @messages = getMessagesFromDir($repoDir);
    filterMessages(\@messages);
  }
}

sub filterMessages(\@){
  my @messages = @{shift()};
  my @newMessages
}

sub getMessagesFromDir($){
  my $dir = shift;
  my $content = '';
  for my $file(`ls $dir/*.sms`){
    $content .= `cat $file`;
  }
  return getMessages($content);
}

sub getMessages($){
  my $content = shift;
  my @messages;
  while($content =~ /^([^,]+),([^,]+),([^,]+),("(?:[^"]|"")*")\n/gm){
    my ($phone, $dir, $datetime, $msg) = ($1,$2,$3,$4);
    push @messages, [$1,$2,$3,$4];
  }
  @messages = removeUSCountryCode(\@messages);
  @messages = removeDupes(\@messages);
  return @messages;
}

sub messageToString($){
  my ($phone, $dir, $datetime, $msg) = @{$_[0]};
  return "$phone,$dir,$datetime,$msg\n";
}

sub writeContactsFiles(\@$){
  my @messages = @{shift()};
  my $dir = shift;

  my %byContact;

  for my $msg(@messages){
    my $phone = $$msg[0];
    $byContact{$phone} = [] if not defined $byContact{$phone};
    push @{$byContact{$phone}}, $msg;
  }
  for my $phone(keys %byContact){
    my $file = "$dir/$phone.sms";
    $file =~ s@:/org/freedesktop/Telepathy/Account/ring/tel/ring@@;
    open FH, "> $file" or die "Could not open $file\n";
    my @messages = @{$byContact{$phone}};
    @messages = sort {$$a[2] cmp $$b[2]} @messages;
    for my $msg(@messages){
      print FH messageToString $msg;
    }
    close FH;
  }
}

sub removeUSCountryCode(\@){
  my @messages = @{shift()};
  for my $msg(@messages){
    my $phone = $$msg[0];
    $phone =~ s/^\+?1(\d\d\d\d\d\d\d\d\d\d)$/$1/;
    $$msg[0] = $phone;
  }
  return @messages;
}

sub removeDupes(\@){
  my @messages = @{shift()};
  my %strings;
  my %onelineStrings;
  for my $msg(@messages){
    my $str = messageToString $msg;
    
    my $oneline = $str;
    $oneline =~ s/[\n\r]+//g;
    if(defined $strings{$str}){
      print "skipped dupe: $str";
      next;
    }elsif(defined $onelineStrings{$oneline}){
      print "skipped a newline dupe: $str";
      my $prevMsg = $onelineStrings{$oneline};
      my $prevStr = messageToString $prevMsg;

      my $strLines = @{[$str =~ /([\n\r])/g]};
      my $prevStrLines = @{[$prevStr =~ /([\n\r])/g]};
      if($strLines > $prevStrLines){
        #previous one is no good, missing newlines
        delete $strings{$prevStr};
      }elsif($prevStrLines > $strLines){
        #this one is no good, missing newlines
        next;
      }else{
        print "WEIRD: newline count is the same, not skipping\n";
      }
    }
    
    $strings{$str} = $msg;
    $onelineStrings{$oneline} = $msg;
  }
  return values %strings;
}

&main(@ARGV);
