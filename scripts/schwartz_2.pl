#!/usr/bin/env perl

use strict;
use warnings;
use feature   qw( :all );

# --------------------------------------
# # Modules

use English  qw( -no_match_vars );  # Avoids regex performance penalty

use MyUtils  qw( vardump );

# conditional compile DEBUGging statements
# See http://lookatperl.blogspot.ca/2013/07/a-look-at-conditional-compiling-of.html
use constant DEBUG => $ENV{DEBUG};

# --------------------------------------

my $SortKeySeparator = q{ };

sub sortkey {
  my $orig = shift @_;
  my $key1 = lc( $orig );

  my $stringified_key = join( $SortKeySeparator, $key1, $orig );
  say vardump original => $orig, stringified_key => $stringified_key;

  return $stringified_key;
}

my @test = qw( this is a test. This Is A Test. );
say vardump presort => \@test;

my @pairs = map { [ $_, sortkey( $_ ) ] } @test;
say vardump pairs => \@pairs;

my @sorted_pairs = sort { $a->[1] cmp $b->[1] } @pairs;
say vardump sorted_pairs => \@sorted_pairs;

my @final = map { $_->[0] } @sorted_pairs;
say vardump final => \@final;
