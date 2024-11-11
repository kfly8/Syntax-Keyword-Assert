use Test2::V0;

use Syntax::Keyword::Assert;

subtest 'Test `assert` keyword' => sub {
    like dies {
        assert( 0 );
    }, qr/\AAssertion failed/;

    ok lives {
        assert( 1 );
    };

    my $hello = sub {
        my ($message) = @_;
        assert( defined $message );
        return "Hello, $message!";
    };

    ok lives {
        $hello->('world');
    };

    like dies {
        $hello->(undef);
    }, qr/\AAssertion failed/;


};

subtest 'Test `assert(binary)` keyword' => sub {
    like dies {
        assert( 1 == 0 );
    }, qr/\AAssertion failed/;

    ok lives {
        assert( 1 == 1 );
    };

    my $x = 1;
    my $y = 2;

    like dies {
        assert( $x + $y == 100 );
    }, qr/\AAssertion failed/;

    ok lives {
        assert( $x + $y == 3 );
    };

    like dies {
        assert( 'hello' eq 'world' );
    }, qr/\AAssertion failed/;

    ok lives {
        assert( 'hello' eq 'hello' );
    };
};

done_testing;
