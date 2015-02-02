#!/usr/bin/perl
use strict;
use warnings;
use Mail::IMAPClient;
use IO::Socket::SSL;
use MIME::Parser;

sub mergeUnreadCounts($);
sub readUnreadCounts();
sub writeUnreadCounts($);
sub readUidFile($$);
sub writeUidFile($$@);
sub cacheAllHeaders($$$);
sub cacheBodies($$@);
sub getBody($$$);
sub hasWords($);
sub parseBody($$);
sub getCachedHeaderUids($);
sub readCachedHeader($$);
sub examineFolder($$);
sub getClient($);
sub getSocket($);
sub readSecrets();

my $secretsFile = "$ENV{HOME}/.secrets";
my @configKeys = qw(user password server port folder);
my @extraConfigKeys = qw(ssl);

my @headerFields = qw(Date Subject From);
my $unreadCountsFile = "$ENV{HOME}/.unread-counts";
my $emailDir = "$ENV{HOME}/.cache/email";

my $VERBOSE = 0;

my $settings = {
  Peek => 1,
  Uid => 1,
};

my $okCmds = join "|", qw(
  --update --body --body-html
  --print --summary --unread-line
  --has-error --has-new-unread --has-unread
);

my $usage = "
  $0 -h|--help
    show this message

  $0 [--update] [ACCOUNT_NAME ACCOUNT_NAME ...]
    -for each account specified, or all if none are specified:
      -login to IMAP server, or create file $emailDir/ACCOUNT_NAME/error
      -fetch and write all message UIDs to
        $emailDir/ACCOUNT_NAME/all
      -fetch and cache all message headers in
        $emailDir/ACCOUNT_NAME/headers/UID
      -fetch all unread messages and write their UIDs to
        $emailDir/ACCOUNT_NAME/unread
      -write all message UIDs that are now in unread and were not before
        $emailDir/ACCOUNT_NAME/new-unread
    -update global unread counts file $unreadCountsFile
      ignored or missing accounts are preserved in $unreadCountsFile

      write the unread counts, one line per account, to $unreadCountsFile
      e.g.: 3:AOL
            6:GMAIL
            0:WORK_GMAIL

  $0 --body ACCOUNT_NAME UID
    download, format and print the body of message UID in account ACCOUNT_NAME
    if body is cached, skip download

  $0 --body-html ACCOUNT_NAME UID
    same as --body, but prefer HTML instead of plaintext

  $0 --print [ACCOUNT_NAME ACCOUNT_NAME ...]
    format and print cached unread message headers and bodies

  $0 --summary [ACCOUNT_NAME ACCOUNT_NAME ...]
    format and print cached unread message headers

  $0 --unread-line [ACCOUNT_NAME ACCOUNT_NAME ...]
    does not fetch anything, merely reads $unreadCountsFile
    format and print $unreadCountsFile
    the string is a space-separated list of the first character of
      each account name followed by the integer count
    no newline character is printed
    if the count is zero for a given account, it is omitted
    if accounts are specified, all but those are omitted
    e.g.: A3 G6

  $0 --has-error [ACCOUNT_NAME ACCOUNT_NAME ...]
    checks if $emailDir/ACCOUNT_NAME/error exists
    print \"yes\" and exit with zero exit code if it does
    otherwise, print \"no\" and exit with non-zero exit code

  $0 --has-new-unread [ACCOUNT_NAME ACCOUNT_NAME ...]
    does not fetch anything, merely reads $unreadCountsFile
    checks for any NEW unread emails, in any account
      {UIDs in $emailDir/ACCOUNT_NAME/new-unread}
    if accounts are specified, all but those are ignored
    print \"yes\" and exit with zero exit code if there are new unread emails
    otherwise, print \"no\" and exit with non-zero exit code

  $0 --has-unread [ACCOUNT_NAME ACCOUNT_NAME ...]
    does not fetch anything, merely reads $unreadCountsFile
    checks for any unread emails, in any account
      {UIDs in $emailDir/ACCOUNT_NAME/unread}
    if accounts are specified, all but those are ignored
    print \"yes\" and exit with zero exit code if there are unread emails
    otherwise, print \"no\" and exit with non-zero exit code
";

sub main(@){
  my $cmd = shift if @_ > 0 and $_[0] =~ /^($okCmds)$/;
  $cmd = "--update" if not defined $cmd;

  die $usage if @_ > 0 and $_[0] =~ /^(-h|--help)$/;

  my $accounts = readSecrets();

  if($cmd =~ /^(--update)$/){
    $VERBOSE = 1;
    my @accNames = @_ == 0 ? sort keys %$accounts : @_;
    my $counts = {};
    for my $accName(@accNames){
      my $acc = $$accounts{$accName};
      die "Unknown account $accName\n" if not defined $acc;
      my $errorFile = "$emailDir/$accName/error";
      system "rm", "-f", $errorFile;
      my $c = getClient($acc);
      if(not defined $c){
        my $msg = "Could not authenticate $$acc{name} ($$acc{user})\n";
        warn $msg;
        open FH, "> $errorFile";
        print FH $msg;
        close FH;
        next;
      }
      my $f = examineFolder($acc, $c);
      if(not defined $f){
        my $msg = "Error getting folder $$acc{folder}\n";
        warn $msg;
        open FH, "> $errorFile";
        print FH $msg;
        close FH;
        next;
      }

      cacheAllHeaders($acc, $c, $f);

      my @unread = $c->unseen;
      $$counts{$accName} = @unread;

      cacheBodies($acc, $c, @unread);

      my %oldUnread = map {$_ => 1} readUidFile $accName, "unread";
      writeUidFile $accName, "unread", @unread;
      my @newUnread = grep {not defined $oldUnread{$_}} @unread;
      writeUidFile $accName, "new-unread", @newUnread;
    }
    mergeUnreadCounts $counts;
  }elsif($cmd =~ /^(--body|--body-html)$/){
    die $usage if @_ != 2;
    my $preferHtml = $cmd =~ /body-html/;
    my $accName = shift;
    my $uid = shift;
    my $acc = $$accounts{$accName};
    my $body = readCachedBody($accName, $uid);
    if(not defined $body){
      die "Unknown account $accName\n" if not defined $acc;
      my $c = getClient($acc);
      die "Could not authenticate $accName ($$acc{user})\n" if not defined $c;
      my $f = examineFolder($acc, $c);
      die "Error getting folder $$acc{folder}\n" if not defined $f;
      cacheBodies($acc, $c, $uid);
      $body = readCachedBody($accName, $uid);
    }
    die "No body found for $accName $uid\n" if not defined $body;
    my $mimeParser = MIME::Parser->new();
    my $fmt = getBody($mimeParser, $body, $preferHtml);
    chomp $fmt;
    print "$fmt\n";
  }elsif($cmd =~ /^(--print)$/){
    my @accNames = @_ == 0 ? sort keys %$accounts : @_;
    my $mimeParser = MIME::Parser->new();
    for my $accName(@accNames){
      my @unread = readUidFile $accName, "unread";
      for my $uid(@unread){
        my $hdr = readCachedHeader($accName, $uid);
        my $body = getBody($mimeParser, readCachedBody($accName, $uid), 0);
        $body = "" if not defined $body;
        $body = "[NO BODY]\n" if $body =~ /^\s*$/;
        $body =~ s/^/  /mg;
        print "\n"
          . "ACCOUNT: $accName\n"
          . "UID: $uid\n"
          . "DATE: $$hdr{Date}\n"
          . "FROM: $$hdr{From}\n"
          . "SUBJECT: $$hdr{Subject}\n"
          . "BODY:\n$body\n"
          . "\n"
          ;
      }
    }
  }elsif($cmd =~ /^(--summary)$/){
    my @accNames = @_ == 0 ? sort keys %$accounts : @_;
    for my $accName(@accNames){
      my @unread = readUidFile $accName, "unread";
      for my $uid(@unread){
        my $hdr = readCachedHeader($accName, $uid);
        print "$accName $$hdr{Date} $$hdr{From}\n  $$hdr{Subject}\n";
      }
    }
  }elsif($cmd =~ /^(--unread-line)$/){
    my @accNames = @_ == 0 ? sort keys %$accounts : @_;
    my $counts = readUnreadCounts();
    my @fmts;
    for my $accName(@accNames){
      die "Unknown account $accName\n" if not defined $$counts{$accName};
      my $count = $$counts{$accName};
      my $errorFile = "$emailDir/$accName/error";
      my $fmt = substr($accName, 0, 1) . $count;
      if(-f $errorFile){
        push @fmts, "$fmt!err";
      }else{
        push @fmts, $fmt if $count > 0;
      }
    }
    print "@fmts";
  }elsif($cmd =~ /^(--has-error)$/){
    my @accNames = @_ == 0 ? sort keys %$accounts : @_;
    for my $accName(@accNames){
      if(-f "$emailDir/$accName/error"){
        print "yes\n";
        exit 0;
      }
    }
    print "no\n";
    exit 1;
  }elsif($cmd =~ /^(--has-new-unread)$/){
    my @accNames = @_ == 0 ? sort keys %$accounts : @_;
    my @fmts;
    for my $accName(@accNames){
      my @unread = readUidFile $accName, "new-unread";
      if(@unread > 0){
        print "yes\n";
        exit 0;
      }
    }
    print "no\n";
    exit 1;
  }elsif($cmd =~ /^(--has-unread)$/){
    my @accNames = @_ == 0 ? sort keys %$accounts : @_;
    my @fmts;
    for my $accName(@accNames){
      my @unread = readUidFile $accName, "unread";
      if(@unread > 0){
        print "yes\n";
        exit 0;
      }
    }
    print "no\n";
    exit 1;
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

sub readUidFile($$){
  my ($accName, $fileName) = @_;
  my $dir = "$emailDir/$accName";

  if(not -f "$dir/$fileName"){
    return ();
  }else{
    my @uids = `cat "$dir/$fileName"`;
    chomp foreach @uids;
    return @uids;
  }
}

sub writeUidFile($$@){
  my ($accName, $fileName, @uids) = @_;
  my $dir = "$emailDir/$accName";
  system "mkdir", "-p", $dir;

  open FH, "> $dir/$fileName" or die "Could not write $dir/$fileName\n";
  print FH "$_\n" foreach @uids;
  close FH;
}

sub cacheAllHeaders($$$){
  my ($acc, $c, $f) = @_;
  print "fetching all message ids\n" if $VERBOSE;
  my @messages = $c->messages;
  print "fetched " . @messages . " ids\n" if $VERBOSE;

  my $dir = "$emailDir/$$acc{name}";
  writeUidFile $$acc{name}, "all", @messages;

  my $headersDir = "$dir/headers";
  system "mkdir", "-p", $headersDir;

  my %toSkip = map {$_ => 1} getCachedHeaderUids($acc);

  @messages = grep {not defined $toSkip{$_}} @messages;
  print "caching headers for " . @messages . " messages\n" if $VERBOSE;

  my $headers = $c->parse_headers(\@messages, @headerFields);
  for my $uid(keys %$headers){
    my $hdr = $$headers{$uid};
    open FH, "> $headersDir/$uid";
    for my $field(sort @headerFields){
      my $vals = $$hdr{$field};
      my $val = "";
      if(not defined $vals or @$vals == 0){
        warn "WARNING: $uid has no field $field\n";
      }else{
        $val = $$vals[0];
      }
      if($val =~ s/\n/\\n/){
        warn "WARNING: newlines in $uid $field {replaced with \\n}\n";
      }
      print FH "$field: $val\n";
    }
    close FH;
  }
}

sub cacheBodies($$@){
  my ($acc, $c, @messages) = @_;
  my $bodiesDir = "$emailDir/$$acc{name}/bodies";
  system "mkdir", "-p", $bodiesDir;

  my %toSkip = map {$_ => 1} getCachedBodyUids($acc);
  @messages = grep {not defined $toSkip{$_}} @messages;
  print "caching bodies for " . @messages . " messages\n" if $VERBOSE;

  for my $uid(@messages){
    my $body = $c->message_string($uid);
    $body = "" if not defined $body;
    if($body =~ /^\s*$/){
      warn "WARNING: no body found for $$acc{name} $uid\n" if $body =~ /^\s*$/;
    }else{
      open FH, "> $bodiesDir/$uid" or die "Could not write $bodiesDir/$uid\n";
      print FH $body;
      close FH;
    }
  }
}

sub getBody($$$){
  my ($mimeParser, $bodyString, $preferHtml) = @_;
  my $mimeBody = $mimeParser->parse_data($bodyString);

  for my $isHtml($preferHtml ? (1, 0) : (0, 1)){
    my $fmt = join "\n", parseBody($mimeBody, $isHtml);
    if(hasWords $fmt){
      $mimeParser->filer->purge;
      return $fmt;
    }
  }

  $mimeParser->filer->purge;
  return undef;
}

sub hasWords($){
  my $msg = shift;
  $msg =~ s/\W+//g;
  return length($msg) > 0;
}

sub parseBody($$){
  my ($entity, $html) = @_;
  my $count = $entity->parts;
  if($count > 0){
    my @parts;
    for(my $i=0; $i<$count; $i++){
      my @subParts = parseBody($entity->parts($i - 1), $html);
      @parts = (@parts, @subParts);
    }
    return @parts;
  }else{
    my $type = $entity->effective_type;
    if(not $html and $type eq "text/plain"){
      return ($entity->bodyhandle->as_string);
    }elsif($html and $type eq "text/html"){
      return ($entity->bodyhandle->as_string);
    }else{
      return ();
    }
  }
}


sub getCachedHeaderUids($){
  my $acc = shift;
  my $headersDir = "$emailDir/$$acc{name}/headers";
  my @cachedHeaders = `cd "$headersDir"; ls`;
  chomp foreach @cachedHeaders;
  return @cachedHeaders;
}
sub getCachedBodyUids($){
  my $acc = shift;
  my $bodiesDir = "$emailDir/$$acc{name}/bodies";
  my @cachedBodies = `cd "$bodiesDir"; ls`;
  chomp foreach @cachedBodies;
  return @cachedBodies;
}

sub readCachedBody($$){
  my ($accName, $uid) = @_;
  my $bodyFile = "$emailDir/$accName/bodies/$uid";
  if(not -f $bodyFile){
    return undef;
  }
  return `cat "$bodyFile"`;
}

sub readCachedHeader($$){
  my ($accName, $uid) = @_;
  my $hdrFile = "$emailDir/$accName/headers/$uid";
  if(not -f $hdrFile){
    return undef;
  }
  my $header = {};
  my @lines = `cat "$hdrFile"`;
  for my $line(@lines){
    if($line =~ /^(\w+): (.*)$/){
      $$header{$1} = $2;
    }else{
      warn "WARNING: malformed header line: $line\n";
    }
  }
  return $header;
}

sub examineFolder($$){
  my ($acc, $c) = @_;
  my @folders = $c->folders($$acc{folder});
  if(@folders != 1){
    return undef;
  }

  my $f = $folders[0];
  $c->examine($f);
  return $f;
}

sub getClient($){
  my ($acc) = @_;
  my $network;
  if(defined $$acc{ssl} and $$acc{ssl} =~ /^false$/){
    $network = {
      Server => $$acc{server},
      Port => $$acc{port},
    };
  }else{
    my $socket = getSocket($acc);
    return undef if not defined $socket;

    $network = {
      Socket => $socket,
    };
  }
  print "$$acc{name}: logging in\n" if $VERBOSE;
  my $c = Mail::IMAPClient->new(
    %$network,
    User     => $$acc{user},
    Password => $$acc{password},
    %$settings,
  );
  return undef if not $c->IsAuthenticated();
  return $c;
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
