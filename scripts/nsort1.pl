#!/usr/bin/env perl

use strict;
use warnings;

# --------------------------------------
#       Name: first_ge
#      Usage: $index = first_ge( $n, @numbers );
#    Purpose: Return the index of the first number in the list greater then or
#             equal to the given number.
# Parameters:       $n -- given number
#             @numbers -- ascending sorted list of numbers
#    Returns:   $index -- first index or just beyond end of list
#
sub first_ge {
  my $n       = shift @_;
  my @numbers = @_;

  # set to just beyond end of list
  my $index = @numbers;

  # scan the list
  for my $i ( 0 .. $#numbers ){

    # As $i increases, exit at the first number greater than or equal to $n
    if( $numbers[$i] >= $n ){
      $index = $i;
      last;
    }

  } # end scan

  return $index;
}

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

  # step 2: reduce the problem by one
  my $n = shift @numbers;

  # step 3: use recursion to get the partial results
  @numbers = nsort( @numbers );

  # step 4: combine partial results to get full results
  my $index = first_ge( $n, @numbers );
  splice( @numbers, $index, 0, $n );

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
