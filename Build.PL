# $Id: Build.PL,v 1.2 2003/06/25 01:05:41 mrodrigu Exp $
use Module::Build;

Module::Build->new
      ( module_name => 'Params::Style',
        license => 'perl',
		prereqs => 'Test::More',
      )->create_build_script;

