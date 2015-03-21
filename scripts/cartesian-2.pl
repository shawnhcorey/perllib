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
#    Purpose: Generate the Cartesian products of the given sets via looping.
# Parameters:    \@sets -- an AoA of the sets
#    Returns: $products -- an AoA of the products
#
sub cartesian_product {
  my $sets = shift @_;

  my $products = [[]];
  for my $set ( reverse @$sets ){

    my $partial_products = $products;
    $products = [];

    for my $item ( @$set ){
      for my $product ( @$partial_products ){
        push @$products, [ $item, @$product ];
      }
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
