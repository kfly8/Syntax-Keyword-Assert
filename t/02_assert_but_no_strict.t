use Test2::V0;

BEGIN {
    $ENV{SYNTAX_KEYWORD_ASSERT_STRICT} = 0;
}

use Syntax::Keyword::Assert;

subtest 'simple cases' => sub {
    ok lives {
        assert { 0 };
    };

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

    like warning {
        $hello->(undef);
    }, qr/\AUse of uninitialized value \$message in concatenation/;
};

done_testing;
