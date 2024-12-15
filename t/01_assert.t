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

    ok lives { $hello->('world') };
    ok dies { $hello->(undef) };

    like dies { assert( undef ) }, qr/\AAssertion failed \(got undef\)/;
    like dies { assert( 0 ) }, qr/\AAssertion failed \(got 0\)/;
    like dies { assert( '0' ) }, qr/\AAssertion failed \(got "0"\)/;
    like dies { assert( '' ) }, qr/\AAssertion failed \(got ""\)/;
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
    ok lives { assert( $x + $y == 3 ) };

    my $message = 'hello';
    ok lives { assert( $message eq 'hello' ) };

    my $undef = undef;

    like dies { assert( $x + $y == 100 ) },   qr/\AAssertion failed \(got 3, expected 100\)/;
    like dies { assert( $x == 100 ) },        qr/\AAssertion failed \(got 1, expected 100\)/;

    my $warnings = warnings {
        like dies { assert( $message == 100 ) },  qr/\AAssertion failed \(got "hello", expected 100\)/;
        like dies { assert( $undef == 100 ) },    qr/\AAssertion failed \(got undef, expected 100\)/;

        like dies { assert( $message eq 'world' ) }, qr/\AAssertion failed \(got "hello", expected "world"\)/;
        like dies { assert( $x eq 'world' ) },       qr/\AAssertion failed \(got 1, expected "world"\)/;
        like dies { assert( $undef eq 'world' ) },   qr/\AAssertion failed \(got undef, expected "world"\)/;
    };

    # Suppressed warnings, first string comparison by numeric eq, other undef comparison
    is scalar @$warnings, 3;
};

done_testing;
