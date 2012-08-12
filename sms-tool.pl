#!/usr/bin/perl
#n9-sms-tool v0.1
#Copyright 2012 Elliot Wolk
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#See the GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.
#If not, see <http://www.gnu.org/licenses/>.
use strict;
use warnings;

my $DATE_FILTER = "30 days ago";
my $LAST_FILTER = 5;

my $smsDir = "$ENV{HOME}/Code/n9/backup/backup-sms";
my $repoDir = "$ENV{HOME}/Code/n9/backup/backup-sms/repo";

sub filterMessages(\@);
sub getMessagesFromDir($);
sub getMessages($);
sub messageToString($);
sub writeMessageFile(\@$);
sub writeContactsFiles(\@$);
sub removeUSCountryCode(\@);
sub removeDupes(\@);

sub main(@){
  my $arg = shift;
  $arg = '' if not defined $arg;
  my @okArgs = qw(split join commit backup);
  my $ok = join "|", @okArgs;
  die "Usage: $0 $ok\n" if $arg !~ /^($ok)$/ or @_ > 0;

  if($arg eq 'split'){
    system "mkdir $repoDir -p";
    my @messages = (
      getMessagesFromDir($smsDir),
      getMessagesFromDir($repoDir));
    @messages = removeDupes @messages;
    system "mkdir -p $repoDir";
    system "rm $repoDir/*.sms";
    writeContactsFiles @messages, $repoDir;
  }elsif($arg eq 'join'){
    my @messages = getMessagesFromDir $repoDir;
    @messages = filterMessages @messages;
    writeMessageFile @messages, "$smsDir/filtered.sms";
  }elsif($arg eq 'commit'){
    chdir $repoDir;
    if(not -d '.git'){
      system "git init";
    }
    system "git add *.sms";
    system "git --no-pager diff --cached";
    system "git commit -m 'automatic commit'";
  }elsif($arg eq 'backup'){
    system "mkdir $smsDir -p";
    chdir $smsDir;
    system "smsbackuprestore", "export", time . ".sms";
  }
}

sub getNewMessages($\@){
  my $cutoffDate = shift;
  my $targetDate = `date --date="$cutoffDate" '+%Y-%m-%d %H:%M:%S'`;
  chomp $targetDate;

  my @messages = @{shift()};
  my @newMessages;
  for my $msg(@messages){
    my $date = $$msg[2];
    if($date gt $targetDate){
      push @newMessages, $msg;
    }
  }
  return @newMessages;
}

sub getLastMessages($\@){
  my $count = shift;
  my @messages = @{shift()};

  my %byContact;
  for my $msg(@messages){
    my $phone = $$msg[0];
    $byContact{$phone} = [] if not defined $byContact{$phone};
    push @{$byContact{$phone}}, $msg;
  }

  my @newMessages = ();
  for my $contact(keys %byContact){
    my @msgs = @{$byContact{$contact}};
    @msgs = sort {$$b[2] cmp $$a[2]} @msgs;
    for(my $i=0; $i<$count and $i<@msgs; $i++){
      push @newMessages, $msgs[$i];
    }
  }
  return @newMessages;
}

sub filterMessages(\@){
  my @messages = @{shift()};
  @messages = removeDupes @messages;
  @messages = (
    getNewMessages($DATE_FILTER, @messages),
    getLastMessages($LAST_FILTER, @messages),
  );
  @messages = removeDupes @messages;
  return \@messages;
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
  @messages = removeUSCountryCode @messages;
  return @messages;
}

sub messageToString($){
  my ($phone, $dir, $datetime, $msg) = @{$_[0]};
  return "$phone,$dir,$datetime,$msg\n";
}

sub writeMessageFile(\@$){
  my @messages = @{shift()};
  my $file = shift;
  open FH, "> $file" or die "Could not open $file\n";
  @messages = sort {$$a[2] cmp $$b[2]} @messages;
  for my $msg(@messages){
    print FH messageToString $msg;
  }
  close FH;
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
    my @messages = @{$byContact{$phone}};
    writeMessageFile @messages, $file;
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
      next;
    }elsif(defined $onelineStrings{$oneline}){
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
