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

my @test = qw( this is a test. This Is A Test. );
say vardump presort => \@test;

my %Counts = ();
sub my_cmp {
  $Counts{ $a } ++;
  $Counts{ $b } ++;

  lc( $a ) cmp lc( $b );
}

my @sorted = sort my_cmp @test;
say vardump sorted => \@sorted;

say vardump counts => \%Counts;
