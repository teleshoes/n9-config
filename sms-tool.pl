#!/usr/bin/perl
use strict;
use warnings;

my $cutoffDate = "60 days ago";

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
  my @okArgs = qw(split join commit);
  my $ok = join "|", @okArgs;
  die "Usage: $0 $ok\n" if $arg !~ /^($ok)$/ or @_ > 0;

  if($arg eq 'split'){
    my @messages = (getMessagesFromDir($smsDir), getMessagesFromDir($repoDir));
    @messages = removeDupes @messages;
    system "mkdir -p $repoDir";
    system "rm $repoDir/*.sms";
    writeContactsFiles @messages, $repoDir;
  }elsif($arg eq 'join'){
    my @messages = getMessagesFromDir $repoDir;
    @messages = removeDupes @messages;
    @messages = filterMessages @messages;
    writeMessageFile @messages, "$smsDir/filtered.sms";
  }elsif($arg eq 'commit'){
    chdir $repoDir;
    system "git add *.sms";
    system "git --no-pager diff --cached";
    system "git commit -m 'automatic commit'";
  }
}

sub filterMessages(\@){
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
