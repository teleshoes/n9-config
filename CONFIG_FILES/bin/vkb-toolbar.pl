#!/usr/bin/perl
use strict;
use warnings;

my @buttons = (
  ['t'       => 'tab'     => 'default' => 'Tab'],
  ['c'       => 'ctrl'    => 'default' => 'Ctrl+Shift+Alt+C'],
  ['a'       => 'alt'     => 'default' => 'Ctrl+Shift+Alt+A'],
  ['e'       => 'escape' => 'default'  => 'Esc'],
  ['&#9653;' => 'up'      => 'default' => 'Up'],
  ['&#9663;' => 'down'    => 'default' => 'Down'],
  ['&#9667;' => 'left'    => 'default' => 'Left'],
  ['&#9657;' => 'right'   => 'default' => 'Right'],
  ['TOGGLE'  => '&#8635;' => 'default' => 'more'],

  ['$'       => 'dollar'  => 'more' => "\$"],
  ['&lt;'    => 'less'    => 'more' => "&lt;"],
  ['>'       => 'greater' => 'more' => ">"],
  ['|'       => 'pipe'    => 'more' => "|"],
  ['/'       => 'slash'   => 'more' => "/"],
  ['*'       => 'star'    => 'more' => "*"],
  ['H'       => 'home'    => 'more' => 'Home'],
  ['E'       => 'end'     => 'more' => 'End'],
  ['TOGGLE'  => '&#8634;' => 'more' => 'default'],
  ['&amp;'   => 'amp'     => 'more' => "&amp;"],
  ['-'       => 'hyphen'  => 'more' => "-"],
);

my $toolbarFile = "toolbar.xml";

sub getButtons();
sub getItems();
sub getXml();

my $usage = "Usage:
  $0 generate a vkb toolbar for meego-terminal or variants";

sub main(@){
  open FH, "> $toolbarFile" or die "Couldnt write $toolbarFile\n";
  print FH getXml();
  close FH;
}

sub getButtons(){
  my $buttonXml = '';
  for my $btn(@buttons){
    if($$btn[0] eq 'TOGGLE'){
      my ($type, $text, $fromGroup, $toGroup) = @$btn;
      my $name = "$fromGroup-to-$toGroup";
      $buttonXml .= ''
        . "      <button name=\"_$name\" text=\"$text\" group=\"$fromGroup\">\n"
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
    if($$btn[0] eq 'TOGGLE'){
      my ($type, $text, $fromGroup, $toGroup) = @$btn;
      my $name = "$fromGroup-to-$toGroup";
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
