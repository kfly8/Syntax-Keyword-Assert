use v5;
use strict;
use warnings;

use Module::Build;
use XS::Parse::Keyword::Builder;

my $build = Module::Build->new(
   module_name => "Syntax::Keyword::Assert",
   test_requires => {
      'Test2::V0' => '0.000147',
   },
   configure_requires => {
      'Module::Build' => '0.4004',
      'XS::Parse::Keyword::Builder' => '0.36',
   },
   requires => {
      'perl' => '5.016',
      'XS::Parse::Keyword' => '0.36',
   },
   license => 'perl',
   create_license => 1,
   create_readme  => 1,
   meta_merge => {
      resources => {
      },
   },

   extra_compiler_flags => [qw( -Iinclude -I. )],
);

XS::Parse::Keyword::Builder->extend_module_build( $build );

$build->create_build_script;
