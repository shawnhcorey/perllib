#!/usr/bin/env perl

use strict;
use warnings;

use English       qw( -no_match_vars );  # Avoids regex performance penalty

use Test::More;
BEGIN{ use_ok( 'MyUtils' ); } # test #1: check to see if module can be compiled
my $test_count = 1; # 1 for the use_ok() in BEGIN

use MyUtils qw( out_of_date ); # import the out_of_date() function

use File::Basename;
( my $self = basename( $0 )) =~ s{ \. .* \z }{}msx;;

use File::Spec;
my $tmp_dir = File::Spec->tmpdir();

my $source_1 = "$tmp_dir/${self}_source_1_$PID.tmp";
my $source_2 = "$tmp_dir/${self}_source_2_$PID.tmp";
my $source_3 = "$tmp_dir/${self}_source_3_$PID.tmp";
my $target   = "$tmp_dir/${self}_target_$PID.tmp";

# remove the files when done
END {
  unlink $target, $source_1, $source_2, $source_3;
}

# test 1: all sources missing
{
  my $expected = "out_of_date(): could not find the source(s): $source_1 $source_2 $source_3",

  local $EVAL_ERROR;
  eval {
    my $is_out_of_date = out_of_date( $target, $source_1, $source_2, $source_3 );
  };
  my $actual = substr( $EVAL_ERROR, 0, length( $expected ));

  is( $actual, $expected, "all sources missing" );
  $test_count ++;
}

# Create some of the source files
open my $fh, '>', $source_1 or die "could not open $source_1: $OS_ERROR\n";
close $fh;
open $fh, '>', $source_3 or die "could not open $source_3: $OS_ERROR\n";
close $fh;

# test 2: some sources missing
{
  my $expected = "out_of_date(): could not find the source(s): $source_2",

  local $EVAL_ERROR;
  eval {
    my $is_out_of_date = out_of_date( $target, $source_1, $source_2, $source_3 );
  };
  my $actual = substr( $EVAL_ERROR, 0, length( $expected ));

  is( $actual, $expected, "some sources missing" );
  $test_count ++;
}

# create the remainder of the source files
open $fh, '>', $source_2 or die "could not open $source_2: $OS_ERROR\n";
close $fh;

# test 3: target missing
my $actual = out_of_date( $target, $source_1, $source_2, $source_3 );
is( $actual, 1, "target missing" );
$test_count ++;

# create the target file
sleep 2;
open $fh, '>', $target or die "could not open $target: $OS_ERROR\n";
close $fh;

# test 4: target is up to date
$actual = out_of_date( $target, $source_1, $source_2, $source_3 );
is( $actual, 0, "target is up to date" );
$test_count ++;

# update one of the source files
sleep 2;
open $fh, '>', $source_1 or die "could not open $source_1: $OS_ERROR\n";
close $fh;

# test 5: target is out to date
$actual = out_of_date( $target, $source_1, $source_2, $source_3 );
is( $actual, 1, "target is out to date" );
$test_count ++;

# tell Test::More we're done
done_testing( $test_count );
