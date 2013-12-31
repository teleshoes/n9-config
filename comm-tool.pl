#!/usr/bin/perl
#n9-comm-tool v0.1
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

my $okArgs = join "|", qw(split join commit backup);
my $usage = "Usage: $0 sms|call $okArgs\n";

my $DATE_FILTER = "30 days ago";
my $LAST_EACH_FILTER = 3;
my $LAST_EACH_DATE_CUTOFF = "1 year ago";

my $backupRoot = "$ENV{HOME}/Code/n9/backup";

sub run(@);
sub msgSort($$$);
sub filterMessages($\@);
sub getMessagesFromDir($$);
sub getMessages($$);
sub messageToString($$);
sub writeMessageFile($\@$);
sub writeContactsFiles($\@$);
sub alterPhoneNums($$);
sub removeUSCountryCode($);
sub removeDupes($\@);
sub writeByNameSymlinks($$$);
sub getLatestVcfFile($);
sub parseContactsVcf($);
sub formatContact($);
sub parseVcard($$);

sub main(@){
  my $type = shift;
  $type = '' if not defined $type;
  my $arg = shift;
  $arg = '' if not defined $arg;
  die $usage if $type !~ /^(sms|call)$/ or $arg !~ /^($okArgs)$/ or @_ > 0;
  my $bakDir = "$backupRoot/backup-$type";
  my $repoDir = "$backupRoot/backup-$type/repo";
  my $vcfDir = "$backupRoot/backup-contacts";

  if($arg eq 'split'){
    run "mkdir $repoDir -p";
    my @messages = (
      getMessagesFromDir($type, $bakDir),
      getMessagesFromDir($type, $repoDir));
    @messages = removeDupes $type, @messages;
    run "mkdir -p $repoDir";
    run "rm $repoDir/*.$type";
    writeContactsFiles $type, @messages, $repoDir;
    writeByNameSymlinks $type, getLatestVcfFile($vcfDir), $repoDir;
  }elsif($arg eq 'join'){
    my @messages = getMessagesFromDir($type, $repoDir);
    @messages = filterMessages $type, @messages;
    writeMessageFile $type, @messages, "$bakDir/filtered.$type";
  }elsif($arg eq 'commit'){
    chdir $repoDir;
    if(not -d '.git'){
      run "git init";
    }
    run "git add *.$type";
    run "git --no-pager diff --cached";
    run "git commit -m 'automatic commit'";
  }elsif($arg eq 'backup'){
    run "mkdir $bakDir -p";
    chdir $bakDir;
    run "${type}backuprestore", "export", time . ".$type";
  }
}

sub run(@){
  print "@_\n";
  system @_;
}

sub msgSort($$$){
  my ($type, $a, $b) = @_;
  my ($dir, $date, $endDate, $msg);
  $dir = $$a[1] cmp $$b[1];
  $date = $$a[2] cmp $$b[2];
  if($type eq 'call'){
    $endDate = $$a[3] cmp $$b[3];
    $msg = 0;
  }elsif(@$a == 4 and @$b == 4){
    $endDate = 0;
    $msg = $$a[3] cmp $$b[3];
  }
  return $date || $endDate || $dir || $msg;
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

sub filterMessages($\@){
  my $type = shift;
  my @messages = @{shift()};
  @messages = removeDupes $type, @messages;
  my @newMessages = (
    getNewMessages($DATE_FILTER, @messages),
    getLastEachMessages($LAST_EACH_FILTER, $LAST_EACH_DATE_CUTOFF, @messages),
  );
  @newMessages = removeDupes $type, @newMessages;

  my $total = @newMessages + 0;
  print "Total after removing dupes: $total\n";
  return @newMessages;
}

sub getMessagesFromDir($$){
  my $type = shift;
  my $dir = shift;
  my $content = '';
  for my $file(`ls $dir/*.$type`){
    $content .= `cat $file`;
    $content .= "\n";
  }
  return getMessages($type, $content);
}

sub getMessages($$){
  my $type = shift;
  my $content = shift;
  my @messages;
  if($type eq 'sms'){
    while($content =~ /^([^,]+),([^,]+),([^,]+),("(?:[^"]|"")*")\n+/gm){
      my ($phone, $dir, $datetime, $msg) = ($1,$2,$3,$4);
      push @messages, [$phone, $dir, $datetime, $msg];
    }
  }elsif($type eq 'call'){
    while($content =~ /^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)\n+/gm){
      my ($telepathyKey, $phone, $dir, $start, $end) = ($1,$2,$3,$4,$5);
      push @messages, [$phone, $dir, $start, $end, $telepathyKey];
    }
  }
  alterPhoneNums \&removeUSCountryCode, \@messages;
  return @messages;
}

sub messageToString($$){
  my $type = shift;
  if($type eq 'sms'){
    my ($phone, $dir, $datetime, $msg) = @{$_[0]};
    return "$phone,$dir,$datetime,$msg\n";
  }elsif($type eq 'call'){
    my ($phone, $dir, $start, $end, $telepathyKey) = @{$_[0]};
    $end =~ s/\n//g;
    return "$telepathyKey, $phone,$dir,$start,$end\n";
  }
}

sub writeMessageFile($\@$){
  my $type = shift;
  my @messages = @{shift()};
  my $file = shift;
  open FH, "> $file" or die "Could not open $file\n";
  @messages = sort {msgSort $type, $a, $b} @messages;
  for my $msg(@messages){
    print FH messageToString($type, $msg);
  }
  close FH;
}

sub writeContactsFiles($\@$){
  my $type = shift;
  my @messages = @{shift()};
  my $dir = shift;

  my %byContact;
  for my $msg(@messages){
    my $phone = $$msg[0];
    $byContact{$phone} = [] if not defined $byContact{$phone};
    push @{$byContact{$phone}}, $msg;
  }

  for my $phone(keys %byContact){
    my $file = "$dir/$phone.$type";
    $file =~ s@:/org/freedesktop/Telepathy/Account/ring/tel/ring@@;
    my @messages = @{$byContact{$phone}};
    writeMessageFile $type, @messages, $file;
  }
}

sub alterPhoneNums($$){
  my ($sub, $messages) = @_;
  for my $msg(@$messages){
    $$msg[0] = &$sub($$msg[0]);
  }
}

sub removeUSCountryCode($){
  my $num = shift;
  $num =~ s/^\s*//;
  $num =~ s/^\+?1?(\d{10})$/$1/;
  return $num;
}

sub removeDupes($\@){
  my $type = shift;
  my @messages = @{shift()};
  my %strings;
  my %onelineStrings;
  for my $msg(@messages){
    my $str = messageToString $type, $msg;

    my $oneline = $str;
    $oneline =~ s/[\n\r]+//g;
    if(defined $strings{$str}){
      next;
    }elsif(defined $onelineStrings{$oneline}){
      my $prevMsg = $onelineStrings{$oneline};
      my $prevStr = messageToString $type, $prevMsg;

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

sub writeByNameSymlinks($$$){
  my ($type, $vcfFile, $repoDir) = @_;
  my $contacts = parseContactsVcf $vcfFile;
  for my $num(keys %$contacts){
    my $contact = $$contacts{$num};
    my $numFile = "$repoDir/$num.$type";
    my $fmt = formatContact $contact;
    my $byNameFile = "$repoDir/$fmt.$type";
    if(-e $numFile){
      system "ln", "-s", "$num.$type", $byNameFile;
    }
  }
}

sub getLatestVcfFile($){
  my $dir = shift;
  my @files = `ls -t "$dir"/*.vcf`;
  return undef if @files == 0;
  my $f = $files[0];
  chomp $f;
  return $f if -e $f;
}

sub parseContactsVcf($){
  my $vcfFile = shift;
  my $contacts = {};
  if(defined $vcfFile and -e $vcfFile){
    my $vcard;
    open FH, "< $vcfFile" or die "Couldnt read $vcfFile\n";
    while(my $line = <FH>){
      if($line =~ /^\s*BEGIN:VCARD\s*$/){
        $vcard = '';
      }elsif($line =~ /^\s*END:VCARD\s*$/){
        parseVcard $contacts, $vcard;
      }else{
        $vcard .= $line;
      }
    }
    close FH;
  }
  return $contacts;
}

sub formatContact($){
  my $c = shift;
  my @names = @{$$c{names}};
  my $nameStr = join ' ', grep{$_ !~ /^\s*$/} reverse @names;
  $nameStr = lc $nameStr;
  $nameStr =~ s/'s(?![a-z0-9])/s/g;
  $nameStr =~ s/[^a-z0-9]+/_/g;
  return "$nameStr-$$c{number}";
}

sub parseVcard($$){
  my ($contacts, $vcard) = @_;
  my $info = {};
  my $nums = {};
  for my $line(split /[\n\r]+/, $vcard){
    if($line =~ /^TEL;/){
      my $type = undef;
      $type = 'cell' if $line =~ /TYPE=CELL/;
      $type = 'home' if $line =~ /TYPE=HOME/;
      my $num = $line;
      $num =~ s/[^0-9\+]//g;
      $$nums{$num} = $type;
    }elsif($line =~ /^N:/){
      $line =~ s/^N://;
      my @names = split /;/, $line;
      $$info{names} = \@names;
    }
  }

  for my $num(keys %$nums){
    my %numInfo = (%$info);
    $numInfo{type} = $$nums{$num};
    my $number = removeUSCountryCode $num;
    $numInfo{number} = $number;
    $$contacts{$number} = \%numInfo;
  }
}

&main(@ARGV);
