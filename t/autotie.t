#!/usr/bin/perl -w
use strict; 

use Test::More tests => 4;

use Params::Style;
ok( 1, "loading module");


is(  ps( foo_bar => 'fooBar', totoTata => 'titiTutu'),
    "ps( foo_bar => 'fooBar', toto_tata => 'titiTutu')",
    "perl_style with regular hash"
  );

is(  js( foo_bar => 'fooBar', totoTata => 'titiTutu'),
    "js( fooBar => 'fooBar', totoTata => 'titiTutu')",
    "java_style with regular hash"
  );

is(  ps2( { foo_bar => 'fooBar', totoTata => 'titiTutu'}),
    "ps2( {foo_bar => 'fooBar', toto_tata => 'titiTutu'})",
    "perl_style with hashref"
  );


sub ps
    { my %params : ParamsStyle( 'perl_style')= @_;
      return "ps( " . params_string( %params) . ")";
    }

sub ps2
    { my %params : ParamsStyle( 'perl_style');
      %params= %{shift()};
      return "ps2( {" . params_string( %params) . "})";
    }


sub js
    { my %params : ParamsStyle( 'javaStyle')= @_;
      return "js( " . params_string( %params) . ")";
    }



sub params_string
  { my %params= @_;
    return join( ", ", map { qq{$_ => '$params{$_}'} } sort keys %params);
  }
