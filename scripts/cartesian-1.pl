#!/usr/bin/env perl

use 5.16.0;
use strict;
use warnings;

use Data::Dumper;
use Storable qw( dclone );

# Make Data::Dumper pretty
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent   = 1;

# Set maximum depth for Data::Dumper, zero means unlimited
local $Data::Dumper::Maxdepth = 0;

# --------------------------------------
#       Name: cartesian_product
#      Usage: $products = cartesian_product( \@sets );
#    Purpose: Generate the Cartesian products of the given sets via recursion.
# Parameters:    \@sets -- an AoA of the sets
#    Returns: $products -- an AoA of the products
#
sub cartesian_product {
  my $sets = shift @_;

  # step 1: handle the degenerate case(s)
  return [[]] unless @$sets;

  # step 2: reduce the problem by one
  my $first_set = shift @$sets;

  # step 3: recurse to get the partial results
  my $partial_products = cartesian_product( $sets );

  # step 4: combine the partial results to get the full results
  my $products = [];
  for my $item ( @$first_set ){
    for my $product ( @$partial_products ){
      push @$products, [ $item, @$product ];
    }
  }

  return $products;
}

# --------------------------------------
# Main

my @sets = (
  [qw( foo bar )],
  [qw( 1 2 3 )],
);

my $products = cartesian_product( dclone( \@sets ));

print Dumper \@sets, $products;
