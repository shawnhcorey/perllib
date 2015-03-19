#!/usr/bin/env perl

use strict;
use warnings;

my @tests = (
  {
    arguments => [ 'The quick brown fox jumped over the lazy dogs.', ],
    expected  => 'The quick brown fox jumped over the lazy dogs.',
    test_name => 'no change',
  },
  {
    arguments => [ '               The quick brown fox jumped over the lazy dogs.', ],
    expected  => 'The quick brown fox jumped over the lazy dogs.',
    test_name => 'remove leading spaces',
  },
  {
    arguments => [ 'The quick brown fox jumped over the lazy dogs.               ', ],
    expected  => 'The quick brown fox jumped over the lazy dogs.',
    test_name => 'remove trailing spaces',
  },
  {
    arguments => [ '               The quick brown fox jumped over the lazy dogs.               ', ],
    expected  => 'The quick brown fox jumped over the lazy dogs.',
    test_name => 'remove leading & trailing spaces',
  },
  {
    arguments => [ 'The            quick            brown            fox            jumped            over            the            lazy            dogs.', ],
    expected  => 'The quick brown fox jumped over the lazy dogs.',
    test_name => 'many internal spaces',
  },
  {
    arguments => [ '               The            quick            brown            fox            jumped            over            the            lazy            dogs.               ', ],
    expected  => 'The quick brown fox jumped over the lazy dogs.',
    test_name => 'spaces all over the place',
  },
  {
    arguments => [
                   'The quick brown fox jumped over the lazy dogs.',
                   '               The quick brown fox jumped over the lazy dogs.',
                   'The quick brown fox jumped over the lazy dogs.               ',
                   '               The quick brown fox jumped over the lazy dogs.               ',
                   'The            quick            brown            fox            jumped            over            the            lazy            dogs.',
                   '               The            quick            brown            fox            jumped            over            the            lazy            dogs.               ',
                 ],
    expected  => [
                    'The quick brown fox jumped over the lazy dogs.',
                    'The quick brown fox jumped over the lazy dogs.',
                    'The quick brown fox jumped over the lazy dogs.',
                    'The quick brown fox jumped over the lazy dogs.',
                    'The quick brown fox jumped over the lazy dogs.',
                    'The quick brown fox jumped over the lazy dogs.',
                 ],
    test_name => 'array inferface.',
  },
);

use Test::More;
BEGIN{ use_ok( 'MyUtils' ); } # test #1: check to see if module can be compiled

use MyUtils qw( trim ); # import the trim() function

# do each test
for my $test ( @tests ){

  # if expected is not a scalar, then test in list context
  if( my $ref =  ref( $test->{expected} )){

    # tested function returns an array
    if( $ref eq 'ARRAY' ){
      my @actual = trim( @{ $test->{arguments} } );
      is_deeply( \@actual, $test->{expected}, $test->{test_name} );

    # only arrays can be tested (so far)
    }else{
      die "cannot handle $ref references\n";

    } # end if ref eq 'ARRAY'

  # test in scalar context
  }else{
    my $actual = trim( @{ $test->{arguments} } );
    is_deeply( \$actual, \$test->{expected}, $test->{test_name} );

  } # end if ref()
}

# add 1 for use_ok() in BEGIN
done_testing( 1 + scalar( @tests ) );
