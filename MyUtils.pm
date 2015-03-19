#!/
# --------------------------------------
#
#   Title: My Utilities
# Purpose: Some simple utility subs.
#
#    Name: MyUtils
#    File: MyUtils.pm
# Created: July  7, 2013
#
# Copyright: Copyright 2013 by Shawn H Corey.  All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

# --------------------------------------
# Package
package MyUtils;

# --------------------------------------
# Pragmatics

use strict;
use warnings;
use feature qw( :all );

# UTF-8 for everything
use utf8;
use warnings   qw( FATAL utf8 );
use open       qw( :encoding(UTF-8) :std );
use charnames  qw( :full :short );
binmode( DATA, qw( :encoding(UTF-8) ));

# --------------------------------------
# Version
our $VERSION = v1.0.0;

# --------------------------------------
# Exports
use base qw( Exporter );
our @EXPORT = qw( );
our @EXPORT_OK = qw(
    trim
    vardump
    out_of_date
    touch
);
our %EXPORT_TAGS = (
  all  => [ @EXPORT, @EXPORT_OK ],
);

# --------------------------------------
# Modules

# Standard modules
use Carp;
use English      qw( -no_match_vars ) ;  # Avoids regex performance penalty
use File::Glob   qw( :bsd_glob );
use List::Util;
use POSIX;
use Scalar::Util;
use Storable      qw( dclone );

# CPAN modules
use List::MoreUtils;
use Const::Fast;
use Regexp::Common;

# --------------------------------------
# Configuration Parameters

# --------------------------------------
# Variables

# --------------------------------------
# Subroutines

# --------------------------------------
#       Name: trim
#      Usage: $text | @text = trim( @text );
#    Purpose: Remove excess white space.
# Parameters: @text -- A list of text to modify
#    Returns: $text -- A line of text to be returned in scalar context
#             @text -- A list of text to be returned in list context
#
sub trim {
    my @text = @_;

    for my $text ( @text ){
        $text =~ s{ \A \s+ }{}msx;
        $text =~ s{ \s+ \z }{}msx;
        $text =~ s{ \s+ }{ }gmsx;
    } # end for text

    return wantarray ? @text : $text[0];
} # end sub trim

# --------------------------------------
#       Name: vardump
#      Usage: $text = vardump( ?%options, $tag => \$value, ... );
#    Purpose: A simply interface to Data::Dumper->Dump
# Parameters: ?%options -- optional hash ref of options
#                  $tag -- A variable name or other tag
#                $value -- A scalar or a reference
#                   ... -- repeat tag-value pairs as needed
#    Returns:     $text -- dumped variables
#

# create a block to limit scoping
{
  use Data::Dumper;

  my %default_options = (
    -depth    => 0,  # for $Data::Dumper::Maxdepth
    -indent   => 1,  # for $Data::Dumper::Indent
    -purity   => 0,  # for $Data::Dumper::Purity
    -sortkeys => 1,  # for $Data::Dumper::Sortkeys
  );

  sub vardump {

    # Check for optional options
    my %options = %default_options;
    if( ref( $_[0] ) && ref( $_[0] ) eq 'HASH' ){
      my %given_options = %{ shift @_ };

      # use a slice to copy
      @options{ keys %given_options } = values %given_options;
    } # end if

    # create two arrays for Data::Dumper->Dump
    my @tags   = ();
    my @values = ();

    # process all the remaining arguments
    while( @_ ){
      my $tag   = shift @_;
      my $value = shift @_;

      # if value is a ref, make Dump() conform to correct type
      $tag = "*$tag" if ref( $value );

      # add them to the lists
      push @tags,   $tag;
      push @values, $value;
    } # end while

    # localize Data::Dumper options
    local $Data::Dumper::Indent   = $options{ -indent   };
    local $Data::Dumper::Maxdepth = $options{ -depth    };
    local $Data::Dumper::Purity   = $options{ -purity   };
    local $Data::Dumper::Sortkeys = $options{ -sortkeys };

    return Data::Dumper->Dump( \@values, \@tags );

  } # end sub vardump

} # end scoping block

# --------------------------------------
#       Name: out_of_date
#      Usage: $is_out_of_date = out_of_date( $target, @sources );
#    Purpose: To determine if the target file is out of date with respect to the sources.
# Parameters:         $target -- Full path to target file.
#                    @sources -- Full path to the sources files.
#    Returns: $is_out_of_date -- TRUE if the target should be recreated.
#
sub out_of_date {
  my $target  = shift @_;
  my @sources = @_;

  # check if all sources available
  my @missing = ();

  for my $source ( @sources ){

    # if the source file does not exists, add its name to the missing list
    if( ! -e $source ){
      push @missing, $source;
    } # end if

  } # end for $source

  # if any missing, throw an exception
  if( @missing ){
    croak "out_of_date(): could not find the source(s): @missing\n";
  } # end if

  # check if target exists
  if( ! -e $target ){
    return 1; # not exists == out of date
  } # end if

  # save the target's mtime
  my $target_mtime = (stat( $target ))[9];

  # compare mtimes of sources to target's
  for my $source ( @sources ){
    if( (stat( $source ))[9] >= $target_mtime ){
      return 1;
    } # end if
  } # end for source

  # target must be up to date.
  return 0;
} # end sub out_of_date

# --------------------------------------
#       Name: touch
#      Usage: touch( ?%options, @files );
#    Purpose: Updates the atime & mtime of the files.
# Parameters: \%options -- optional options
#                @files -- paths to files
#    Returns: (none)
#

# create a block to limit scoping
{
  my %default_options = (
    -atime  => undef,  # undef will use system time
    -mtime  => undef,  # undef will use system time
    -create => 0,      # create file if it doesn't exist
    -set    => '',     # set atime & mtime to "now" or "system",
                       #   overrides -atime, -mtime options
  );

  sub touch {

    # Start with defaults
    my %options = %default_options;

    # look for developer's options
    if( ref( $_[0] ) && ref( $_[0] ) eq 'HASH' ){
      my %given_options = %{ shift @_ };

      # use a slice to copy
      @options{ keys %given_options } = values %given_options;

    } # end if

    # check for set, overrides -atime & -mtime options
    if( $options{-set} eq 'now' ){
      $options{-atime} = $options{-mtime} = time;

    }elsif( $options{-set} eq 'system' ){
      $options{-atime} = $options{-mtime} = undef;

    } # end if

    # because of a bug in utime,
    # set undef times to now
    my $now = time;
    if( ! defined $options{-atime} ){
      $options{-atime} = $now;
    } # end if
    if( ! defined $options{-mtime} ){
      $options{-mtime} = $now;
    } # end if

    # check files one at a time
    for my $file ( @_ ){

      # create missing file?
      if( $options{-create} && ! -e $file ){

        # create via append, which does not destroy existing file
        open  my $fh, '>>', $file or croak "touch(): could not create $file: $OS_ERROR\n";
        close    $fh              or croak "touch(): could not create $file: $OS_ERROR\n";

      } # end if

      if( ! utime( $options{-atime}, $options{-mtime}, $file )){
        croak "touch(): could not touch $file\n";
      } # end if

    } # end for file

    return;

  } # end sub touch
} # end isolation block


1;
__DATA__
__END__

=head1 NAME

MyUtils - Some simple utility subs.

=head1 VERSION

This document refers to MyUtils version v1.0.0

=head1 SYNOPSIS

  use MyUtils;

=head1 DESCRIPTION

Some simple utility subs.

=for comments TBD

=head1 EXPORTS

=for comments TBD

=head1 REQUIREMENTS

(none)

=head1 SUBROUTINES

=for comments TBD

(none)

=head1 DIAGNOSTICS

(none)

=head1 CONFIGURATION AND ENVIRONMENT

(none)

=head1 INCOMPATIBILITIES

(none)

=head1 BUGS AND LIMITATIONS

(none known)

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MyUtils

=head1 SEE ALSO

(none)

=head1 ORIGINAL AUTHOR

Shawn H Corey  C<< <SHCOREY at cpan dot org> >>

=head2 Contributing Authors

(Insert your name here if you modified this program or its documentation.
 Do not remove this comment.)

=head1 ACKNOWLEDGEMENTS

(none)

=head1 COPYRIGHT & LICENCES

Copyright 2013 by Shawn H Corey.  All rights reserved.

=head2 Software Licence

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

=head2 Document Licence

Permission is granted to copy, distribute and/or modify this document under the
terms of the GNU Free Documentation License, Version 1.2 or any later version
published by the Free Software Foundation; with the Invariant Sections being
ORIGINAL AUTHOR, COPYRIGHT & LICENCES, Software Licence, and Document Licence.

You should have received a copy of the GNU Free Documentation Licence
along with this document; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

=cut
