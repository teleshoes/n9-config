#!/usr/bin/perl
#n9-calls-tool v0.1
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
my $LAST_EACH_FILTER = 3;
my $LAST_EACH_DATE_CUTOFF = "1 year ago";

my $callsDir = "$ENV{HOME}/Code/n9/backup/backup-calls";
my $repoDir = "$ENV{HOME}/Code/n9/backup/backup-calls/repo";

sub filterMessages(\@);
sub getMessagesFromDir($);
sub getMessages($);
sub messageToString($);
sub writeMessageFile(\@$);
sub writeContactsFiles(\@$);
sub removeUSCountryCode(\@);
sub removeDupes(\@);

sub run(@){
  print "@_\n";
  system @_;
}

sub main(@){
  my $arg = shift;
  $arg = '' if not defined $arg;
  my @okArgs = qw(split join commit backup);
  my $ok = join "|", @okArgs;
  die "Usage: $0 $ok\n" if $arg !~ /^($ok)$/ or @_ > 0;

  if($arg eq 'split'){
    run "mkdir $repoDir -p";
    my @messages = (
      getMessagesFromDir($callsDir),
      getMessagesFromDir($repoDir));
    @messages = removeDupes @messages;
    run "mkdir -p $repoDir";
    run "rm $repoDir/*.calls";
    writeContactsFiles @messages, $repoDir;
  }elsif($arg eq 'join'){
    my @messages = getMessagesFromDir $repoDir;
    @messages = filterMessages @messages;
    writeMessageFile @messages, "$callsDir/filtered.calls";
  }elsif($arg eq 'commit'){
    chdir $repoDir;
    if(not -d '.git'){
      run "git init";
    }
    run "git add *.calls";
    run "git --no-pager diff --cached";
    run "git commit -m 'automatic commit'";
  }elsif($arg eq 'backup'){
    run "mkdir $callsDir -p";
    chdir $callsDir;
    run "callsbackuprestore", "export", time . ".calls";
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
  my $total = @newMessages + 0;
  print "All messages since $cutoffDate: $total\n";
  return @newMessages;
}

sub getLastEachMessages($$\@){
  my $count = shift;
  my $cutoffDate = shift;
  my $targetDate = `date --date="$cutoffDate" '+%Y-%m-%d %H:%M:%S'`;
  chomp $targetDate;
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
      my $msg = $msgs[$i];
      my $date = $$msg[2];
      if($date gt $targetDate){
        push @newMessages, $msg;
      }
    }
  }
  my $total = @newMessages + 0;
  print "Last $count messages for each contact since $cutoffDate: $total\n";
  return @newMessages;
}

sub filterMessages(\@){
  my @messages = @{shift()};
  @messages = removeDupes @messages;
  my @newMessages = (
    getNewMessages($DATE_FILTER, @messages),
    getLastEachMessages($LAST_EACH_FILTER, $LAST_EACH_DATE_CUTOFF, @messages),
  );
  @newMessages = removeDupes @newMessages;

  my $total = @newMessages + 0;
  print "Total after removing dupes: $total\n";
  return @newMessages;
}

sub getMessagesFromDir($){
  my $dir = shift;
  my $content = '';
  for my $file(`ls $dir/*.calls`){
    $content .= `cat $file`;
    $content .= "\n";
  }
  return getMessages($content);
}

sub getMessages($){
  my $content = shift;
  my @messages;
  while($content =~ /^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)\n+/gm){
    my ($telepathyKey, $phone, $dir, $start, $end) = ($1,$2,$3,$4,$5);
    push @messages, [$phone, $dir, $start, $end, $telepathyKey];
  }
  @messages = removeUSCountryCode @messages;
  return @messages;
}

sub messageToString($){
  my ($phone, $dir, $start, $end, $telepathyKey) = @{$_[0]};
  $end =~ s/\n//g;
  return "$telepathyKey, $phone,$dir,$start,$end\n";
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
    my $file = "$dir/$phone.calls";
    $file =~ s@:/org/freedesktop/Telepathy/Account/ring/tel/ring@@;
    my @messages = @{$byContact{$phone}};
    writeMessageFile @messages, $file;
  }
}

sub removeUSCountryCode(\@){
  my @messages = @{shift()};
  for my $msg(@messages){
    my $phone = $$msg[0];
    $phone =~ s/^\s*//;
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
