#!/usr/bin/perl
use strict;
use warnings;

my @buttons = (
  ['t'       => 'tab'     => 'default' => 'Tab'],
  ['c'       => 'ctrl'    => 'default' => 'Ctrl+Shift+Alt+C'],
  ['a'       => 'alt'     => 'default' => 'Ctrl+Shift+Alt+A'],
  ['e'       => 'escape ' => 'default' => 'Esc'],
  ['&#9653;' => 'up'      => 'default' => 'Up'],
  ['&#9663;' => 'down'    => 'default' => 'Down'],
  ['&#9667;' => 'left'    => 'default' => 'Left'],
  ['&#9657;' => 'right'   => 'default' => 'Right'],
  ['SHOW'    => 'default' => 'more'],

  ['*'       => 'star'    => 'more'    => "*"],
  ['/'       => 'slash'   => 'more'    => "/"],
  ['|'       => 'pipe'    => 'more'    => "|"],
  ['$'       => 'dollar'  => 'more'    => "\$"],
  ['&amp;'   => 'amp'     => 'more'    => "&amp;"],
  ['&lt;'    => 'less'    => 'more'    => "&lt;"],
  ['>'       => 'greater' => 'more'    => ">"],
  ['-'       => 'hyphen'  => 'more'    => "-"],
  ['HIDE'    => 'more'    => 'default'],
);

my $toolbarDir = '/opt/mtermite/toolbars';
my $toolbarFile = "main.xml";

sub getButtons();
sub getItems();
sub getXml();

my $usage = "Usage: $0   overwrites $toolbarFile\n";

sub main(@){
  system "n9", "-s", "rm $toolbarDir/*";
  my $tmpFile = "/tmp/vkb-toolbar-tmp.xml";
  open FH, "> $tmpFile" or die "Couldnt write $tmpFile\n";
  print FH getXml();
  close FH;
  my $host = `n9`;
  chomp $host;
  system "scp", $tmpFile, "root\@$host:$toolbarDir/$toolbarFile";
}

sub getButtons(){
  my $buttonXml = '';
  for my $btn(@buttons){
    if(@$btn == 3){
      my ($name, $fromGroup, $toGroup) = @$btn;
      $buttonXml .= ''
        . "      <button name=\"_$name\" text=\"?\" group=\"$fromGroup\">\n"
        . "        <actions>\n"
        . "          <hidegroup group=\"$fromGroup\"/>\n"
        . "          <showgroup group=\"$toGroup\"/>\n"
        . "        </actions>\n"
        . "      </button>\n"
        ;
    }else{
      my ($text, $name, $group, $key) = @$btn;
      $buttonXml .= ''
        . "      <button name=\"_$name\" text=\"$text\" group=\"$group\">\n"
        . "        <actions> <sendkeysequence keysequence=\"$key\"/> </actions>\n"
        . "      </button>\n"
        ;
    }
  }
  return $buttonXml;
}
sub getItems(){
  my $itemXml = '';
  for my $btn(@buttons){
    if(@$btn == 3){
      my ($name, $fromGroup, $toGroup) = @$btn;
      $itemXml .= ''
        . "      <item name=\"_$name\"/>\n"
        ;

    }else{
      my ($text, $name, $group, $key) = @$btn;
      $itemXml .= ''
        . "      <item name=\"_$name\"/>\n"
        ;
    }
  }
  return $itemXml;
}
sub getXml(){
  return ''
    . "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    . "<!DOCTYPE MEEGO_INPUT_METHOD SYSTEM 'VirtualKeyboardToolbarDTD.dtd'>\n"
    . "<input-method version=\"1\">\n"
    . "  <toolbar>\n"
    . "    <items>\n"
    . getButtons()
    . "    </items>\n"
    . "    <layout>\n"
    . getItems()
    . "    </layout>\n"
    . "  </toolbar>\n"
    . "</input-method>\n"
    ;
}

&main(@ARGV);
