#!/usr/bin/env perl

use strict;
use warnings;

use English qw( -no_match_vars );  # Avoids regex performance penalty

use Test::More;
BEGIN{ use_ok( 'MyUtils' ); }  # test #1: check to see if module can be compiled
my $test_count = 1;            # 1 for the use_ok() in BEGIN

use MyUtils qw( touch );       # import the touch() function

use File::Basename;
( my $self = basename( $0 )) =~ s{ \. .* \z }{}msx;

use File::Spec;
my $tmp_dir = File::Spec->tmpdir();

my $file_1 = "$tmp_dir/${self}_file_1_$PID.tmp";
my $dir_1  = "$tmp_dir/${self}_dir_1_$PID.tmp";

# remove the files when done
END {
  unlink $file_1;
}

# Test 1: touch a non-existing file
# isolate the localization of the special variables
{
  local $EVAL_ERROR;

  my $expected = "touch(): could not touch $file_1\n";
  eval {
    touch( $file_1 )
  };
  my $actual = substr( $EVAL_ERROR, 0, length( $expected ));

  is( $actual, $expected, 'test non-existing file' );
  $test_count ++;
}

# Test 2: Creating a non-existing file
# isolate the localization of the special variables
{
  local $EVAL_ERROR;

  my $expected = '';
  eval {
    touch( { -create => 1, }, $file_1 )
  };
  my $actual = $EVAL_ERROR;

  is( $actual, $expected, 'create non-existing file, part 1' );
  $test_count ++;

  $expected = 1;
  $actual   = -f $file_1;
  is( $actual, $expected, 'create non-existing file, part 2' );
  $test_count ++;
}

# Test 3: Attempting to Create an Invalid File
# isolate the localization of the special variables
{
  local $EVAL_ERROR;

  my $file = "$dir_1/tmp.tmp";

  my $expected = "touch(): could not create $file";
  eval {
    touch( { -create => 1, }, $file )
  };
  my $actual = substr( $EVAL_ERROR, 0, length( $expected ));

  is( $actual, $expected, 'creating an invalid file' );
  $test_count ++;
}

# Test 4: test set to now
my $old_mtime = (stat( $file_1 ))[9];
sleep 2;
touch( $file_1 );
my $new_mtime = (stat( $file_1 ))[9];

isnt( $old_mtime, $new_mtime, "test changing mtime: $old_mtime, $new_mtime" );
$test_count ++;

# tell Test::More we're done
done_testing( $test_count );
