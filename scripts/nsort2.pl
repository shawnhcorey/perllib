#!/usr/bin/env perl

use strict;
use warnings;

# --------------------------------------
#       Name: nsort
#      Usage: @numbers = nsort( @numbers );
#    Purpose: Sort a list of numbers using recursion
# Parameters: @numbers -- unsorted
#    Returns: @numbers -- ascending sorted
#
sub nsort {
  my @numbers = @_;

  # step 1: check degenerate case(s)
  if( @numbers <= 1 ){
    return @numbers;
  }

  # step 2: reduce the problem by split the given set into two
  my $midpt = int( @numbers / 2 );

  # step 3: use recursion to get the partial results
  my @partial1 = nsort( @numbers[ 0 .. $midpt-1 ] );
  my @partial2 = nsort( @numbers[ $midpt .. $#numbers ] );

  # step 4: combine partial results to get full results
  # use a merge sort to combine the partial results
  @numbers = ();
  while( @partial1 && @partial2 ){
    if( $partial1[0] <= $partial2[0] ){
      push @numbers, shift @partial1;
    }else{
      push @numbers, shift @partial2;
    }
  }

  # add any remaining
  # at least one of the lists is empty
  push @numbers, @partial1, @partial2;

  return @numbers;
}

# --------------------------------------
# Main

# create a list
my @numbers = ();

# fill list with random numbers
for my $count ( 1 .. ( $ARGV[0] || 2 )){
  push @numbers, int( rand( 100 ));
}

# before and after images
print "before: @numbers\n";
@numbers = nsort( @numbers );
print "after:  @numbers\n";
