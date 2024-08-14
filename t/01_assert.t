use Test2::V0;

BEGIN {
    $ENV{PERL_STRICT} = 1;
}

use Syntax::Keyword::Assert;

subtest 'Test `assert` keyword with STRICT enabled' => sub {
    like dies {
        assert { 0 };
    }, qr/Assertion failed/;

    ok lives {
        assert { 1 };
    };

    my $hello = sub {
        my ($message) = @_;
        assert { defined $message };
        return "Hello, $message!";
    };

    ok lives {
        $hello->('world');
    };

    ok dies {
        $hello->(undef);
    };
};

done_testing;
