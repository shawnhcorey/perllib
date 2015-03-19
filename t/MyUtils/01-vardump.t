#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
BEGIN{ use_ok( 'MyUtils' ); } # test #1: check to see if module can be compiled
my $test_count = 1; # 1 for the use_ok() in BEGIN

use MyUtils qw( vardump ); # import the vardump() function
use Data::Dumper;

# Scalar test
# block for isolation of variables
{
  my $var = 'test';

  my $actual   = vardump( scalar => $var );
  my $expected = Data::Dumper->Dump( [ $var ], [ 'scalar' ] );

  is( $actual, $expected, 'scalar test' );
  $test_count ++;
}

# Array test
{
  my @var = qw{ fee fie foe fue };

  my $actual = vardump( array => \@var );

  local $Data::Dumper::Indent = 1;
  my $expected = Data::Dumper->Dump( [ \@var ], [ '*array' ] );

  is( $actual, $expected, 'array test' );
  $test_count ++;
}

# Hash test
{
  my %var = qw{ fee fie foe fue };

  my $actual = vardump( hash => \%var );

  local $Data::Dumper::Indent   = 1;
  local $Data::Dumper::Sortkeys = 1;
  my $expected = Data::Dumper->Dump( [ \%var ], [ '*hash' ] );

  is( $actual, $expected, 'hash test' );
  $test_count ++;
}

# Depth option test
{
  my @var = ( 0, [ 1, [ 2, [ 3 ]]] );

  my $actual = vardump( { -depth=>2, }, depth => \@var );

  local $Data::Dumper::Indent   = 1;
  local $Data::Dumper::Sortkeys = 1;
  local $Data::Dumper::Maxdepth = 2;
  my $expected = Data::Dumper->Dump( [ \@var ], [ '*depth' ] );

  is( $actual, $expected, 'depth option test' );
  $test_count ++;
}

# tell Test::More we're done
done_testing( $test_count );
