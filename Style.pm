package Params::Style;

# $Id: Style.pm,v 1.4 2003/12/05 17:50:04 mrodrigu Exp $

use strict;
use warnings;
use Carp;

require Exporter;

use vars qw( @ISA %EXPORT_TAGS @EXPORT_OK @EXPORT $VERSION);

@ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration use Params::Style ':all';
%EXPORT_TAGS = ( all => [ qw( &perl_style_params &javaStyleParams &JavaStyleParams &replace_keys) ] );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} },  &replace_keys,
               &perl_style_params, &javaStyleParams, &JavaStyleParams
             );

$VERSION = '0.03';


my( $uc, $UC);

BEGIN 
  { if( $] >= 5.007) { $uc  = qr/\p{UppercaseLetter}/;
                       $UC  = qr/\P{UppercaseLetter}/;
                     }
    else             { $uc= qr/[A-Z]/; 
                       $UC= qr/[^A-Z]/;
                     }
  }

################################################################
#                                                              #
#                   functional interface                       #
#                                                              #
################################################################

sub replace_keys
  { my $replace_keys = shift; # sub call to use on each key
    if( @_ == 1)
      { # should be a reference
        my $options= shift @_;
        if( UNIVERSAL::isa( $options, 'ARRAY'))
          { if( scalar @$options % 2) { carp_odd_arg_nb(); }
            my @options; my $flip= 0;
            foreach (@$options)
              { if( $flip=1-$flip) { push @options, $replace_keys->( $_); }
                else               { push @options, $_;              } 
              }
            return \@options;
          }
        elsif( UNIVERSAL::isa( $options, 'HASH'))
          { my %options= map { $replace_keys->($_) => $options->{$_} } keys %$options;
            return \%options;
          }
        else
          { carp_wrong_arg_type( ref $options); }
    
          }
    else
      { my @options;
        while( my $key= shift @_) { push @options, $replace_keys->( $key), shift( @_); }
        return @options;
      }
  }

sub perl_style_params { return replace_keys( \&perl_style, @_); }
sub javaStyleParams   { return replace_keys( \&javaStyle, @_); }
sub JavaStyleParams   { return replace_keys( \&JavaStyle, @_); }


################################################################
#                                                              #
#                   basic replace style                        #
#                                                              #
################################################################

sub javaStyle { my $name= shift; $name=~ s{_(\w)}{\U$1}g; return $name; }
sub JavaStyle { my $name= shift; $name=~ s{(?:_|^)(\w)}{\U$1}g; return $name; }

sub perl_style
  { my $name= shift;
    return $name if( $name=~ m{_});
    $name=~ s{(?<!_)($uc)($UC)}{_\L$1$2}g;
    $name=~ s{(?<!_|$uc)($uc+)}{_$1}g;
    $name=~ s{_($uc)$}{_\L$1};
    $name=~ s{^_}{};
    return $name;
  }
    
sub carp_odd_arg_nb
  { my $pn_sub= (caller(2))[3];
    my ($package, $filename, $line)= (caller(3))[0..2];
    warn "odd number of arguments passed to $pn_sub at $filename line $line\n";
  }
  
sub carp_wrong_arg_type
  { my $type= shift;
    my $pn_sub= (caller(2))[3];
    my ($package, $filename, $line)= (caller(3))[0..2];
    warn "wrong arguments type $type passed to $pn_sub at $filename line $line ",
         "should be hash, hashref, array or array ref\n";
  }
  
################################################################
#                                                              #
#                   tied hash interface                        #
#                                                              #
################################################################

my $replace_keys;
my %replace_func;

use Attribute::Handlers autotie => { '__CALLER__::ParamsStyle' => __PACKAGE__ };

use vars qw(@ISA);
use Tie::Hash;
unshift @ISA, 'Tie::StdHash';

BEGIN
  { %replace_func= ( perl_style => \&Params::Style::perl_style,
                     javaStyle  => \&Params::Style::javaStyle,
                     JavaStyle  => \&Params::Style::JavaStyle,
                   );
  }

sub TIEHASH
  { my( $class, $style)= @_;
    if( UNIVERSAL::isa( $style, 'CODE'))
      { $replace_keys= $style; }
    else
      { $replace_keys= $replace_func{$style}
        or die "wrong style $style\n";
      } 
    return bless {}, $class;
  }


sub STORE
  { my( $hash, $key, $value)= @_;
    $hash->{$replace_keys->($key)}= $value;
  }

sub EXISTS
  { my( $hash, $key)= @_;
    return exists $hash->{$key};
  }

1;
__END__
=head1 NAME

Params::Style - Perl extension for converting named parameters to
perl_style or javaStyle

=head1 SYNOPSIS

  use Params::Style qw( perl_style_params);
  ...
  my_sub( $arg, camelCasedOption => 'fooBar', hideousIMHO => 1, badBADBad => 'foo');
  ...
  sub my_sub
    { my( $arg, @opts)= @_;
      my %opts= perl_style_params( @opts); 
      # %opts is now:
      # camel_case_option => 'fooBar',
      # hideous_IMHO      => 1,
      # bad_BAD_bad       => 'foo'
      ...
    }

  or

  sub my_sub
    { my $arg= shift;
      my %opts : ParamsStyle( 'perl_style')= @_;
      ...
    }

=head1 ABSTRACT

Params::Style offers functions to convert named parameters from perl_style
to javaStyle and vice-versa

=head1 DESCRIPTION

=head2 Functional Interface

=over 4

=item perl_style_params C<< <params> >>

Converts the keys in C<< <params> >> into perl_style keys

C<E<lt>params<gt>> can be either an array, an array reference or a hash reference

The return value as the same type as C<< <params> >>:

  my @params= perl_style_params( myArg1 => 1, myArg2 => 1);
  my %params= perl_style_params( myArg1 => 1, myArg2 => 1);
  my $params= perl_style_params( [myArg1 => 1, myArg2 => 1]); # $params is an array reference
  my $params= perl_style_params( {myArg1 => 1, myArg2 => 1}); # $params is a hash reference

=item javaStyleParams C<< <params> >>

Converts the keys of C<< <params> >> into javaStyle keys 

=item JavaStyleParams C<< <params> >>

Converts the keys of C<< <params> >> into JavaStyle keys 

=item replace_keys C<< <coderef> >> C<< <params> >>

Applies C<< <coderef> >> to the keys in C<< <params> >>

=back

=head2 EXPORT

None by default.

=over 4

=item :all

Exports perl_style_params, javaStyleParams, JavaStyleParams and replace_keys

=back

=head2 Autotied hash interface

Instead of calling a function it is also possible to use an autotied hash, in which
all the keys will be converted to the proper style:

  sub foo
    { my %params: ParamStyle( 'perl_style')= @_;
    }

The extra parameter to C<tie> is either the name of a style (C<perl_style>,
C<javaStyle> or C<JavaStyle>) or a code reference, that will be applied to
all keys to the hash.

=head1 SEE ALSO

perl

=head1 AUTHOR

Michel Rodriguez, E<lt>mirod@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Michel Rodriguez

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 
