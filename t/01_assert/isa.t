use Test2::V0;
use Syntax::Keyword::Assert;

use lib 't/lib';
use TestUtil;

use Test2::Require::Module 'feature' => '1.58';

use experimental 'isa';

my $obj = bless {}, 'Foo';
ok lives { assert($obj isa Foo) };
ok dies { assert($obj isa Bar) }, expected_assert_bin('Foo', 'isa', 'Bar');

done_testing;
