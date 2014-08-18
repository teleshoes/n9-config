#!/usr/bin/perl
use strict;
use warnings;

my $dir = "/home/wolke/.cache/backgrounds";

my %backgrounds = (
  "ada.jpg"                  => "$dir/n9/artwork/ada_crop9x16.jpg",
  "ascii_starry_night.jpg"   => "$dir/n9center/artwork/ascii_starry_night.jpg",
  "dawn_bouguereau.jpg"      => "$dir/n9/erotic/dawn_bouguereau_crop9x16.jpg",
  "flowers.jpg"              => "$dir/n9/artwork/flowers.jpg",
  "ghibli_poster.jpg"        => "$dir/n9/ghibli/ghibliposter_black.jpg",
  "howls_moving_castle.jpg"  => "$dir/n9/ghibli/howls_moving_castle.jpg",
  "kiki_poster.jpg"          => "$dir/n9/ghibli/kiki_poster.jpg",
  "kiki_sweets.jpg"          => "$dir/n9/ghibli/kiki_sweets_edited_crop9x16.jpg",
  "kushana_nausicaa.jpg"     => "$dir/n9/ghibli/kushana_nausicaa_crop9x16.jpg",
  "meatloaf_bw.jpg"          => "$dir/n9/stephenfry_meatloaf/meatloaf_edited_crop9x16.jpg",
  "meatloaf_color.jpg"       => "$dir/n9/stephenfry_meatloaf/meatloaf_classic_performance_cover_edited_crop9x16.jpg",
  "mononoke_poster.jpg"      => "$dir/n9/ghibli/mononoke_poster.jpg",
  "neko_bluesequins.jpg"     => "$dir/n9/neko/neko_bluesequins.jpg",
  "sarah_rabdau.jpg"         => "$dir/n9/sarah/sarah_crop9x16.jpg",
  "stephen_fry.jpg"          => "$dir/n9/stephenfry_meatloaf/stephen_fry_crop9x16.jpg",
  "valerie_thompson.jpg"     => "$dir/n9center/val/valerie.jpg",
  "vessela_stoyanova.jpg"    => "$dir/n9/vess/vess_crop9x16.jpg",
);

sub main(@){
  for my $file(sort keys %backgrounds){
    system "cp", "-a", $backgrounds{$file}, $file;
    die "Error: $file does not exist\n" if not -f $file;
  }
}

&main(@ARGV);
