use Test2::V0;

BEGIN {
    $ENV{SYNTAX_KEYWORD_ASSERT_STRICT} = 1;
}

use Syntax::Keyword::Assert;

subtest 'simple cases' => sub {
    ok dies {
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

    ok dies {
        $hello->(undef);
    };
};

done_testing;
