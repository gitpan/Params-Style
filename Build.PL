# $Id: Build.PL,v 1.3 2003/12/05 17:50:04 mrodrigu Exp $
use Module::Build;

Module::Build->new
      ( module_name => 'Params::Style',
        license => 'perl',
        requires => { Test::More          => 0,
                      Attribute::Handlers => 0,
                      Tie::Hash           => 0,
                    },
      )->create_build_script;

