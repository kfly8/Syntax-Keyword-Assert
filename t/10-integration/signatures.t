use Test2::V0;
use Test2::Require::Perl 'v5.38';

use v5.38;

BEGIN {
    $ENV{PERL_STRICT} = 1;
}

use Syntax::Keyword::Assert;

subtest 'Test `assert` with signatures' => sub {

    my sub hello($name) {
        assert { defined $name };
        return "Hello, $name!";
    }

    ok lives {
        hello('world');
    };

    ok dies {
        hello();
    };
};

done_testing;
