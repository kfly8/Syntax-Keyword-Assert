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

    like dies { assert( undef ) }, qr/\AAssertion failed \(undef\)/;
    like dies { assert( 0 ) }, qr/\AAssertion failed \(0\)/;
    like dies { assert( '0' ) }, qr/\AAssertion failed \("0"\)/;
    like dies { assert( '' ) }, qr/\AAssertion failed \(""\)/;

    my $false = $] >= 5.036 ? 'false' : '""';
    like dies { assert( !1 ) }, qr/\AAssertion failed \($false\)/;
};

subtest 'Test `assert(binary)` keyword' => sub {

    subtest 'NUM_EQ' => sub {
        my $x = 1;
        my $y = 2;
        ok lives { assert( $x + $y == 3 ) };

        like dies { assert( $x + $y == 100 ) },   qr/\AAssertion failed \(3 == 100\)/;
        like dies { assert( $x == 100 ) },        qr/\AAssertion failed \(1 == 100\)/;

        my $true = $] >= 5.036 ? 'true' : '"1"';
        my $false = $] >= 5.036 ? 'false' : '""';
        like dies { assert( !!$x == 100 ) },        qr/\AAssertion failed \($true == 100\)/;
        like dies { assert( !$x == 100 ) },        qr/\AAssertion failed \($false == 100\)/;

        my $message = 'hello';
        my $undef = undef;

        my $warnings = warnings {
            like dies { assert( $message == 100 ) },  qr/\AAssertion failed \("hello" == 100\)/;
            like dies { assert( $undef == 100 ) },    qr/\AAssertion failed \(undef == 100\)/;
        };
        # suppressed warnings
        is scalar @$warnings, 2;
    };

    subtest 'NUM_NE' => sub {
        my $x = 2;
        ok lives { assert( $x != 1 ) };
        like dies { assert( $x != 2 ) }, qr/\AAssertion failed \(2 != 2\)/;
    };

    subtest 'NUM_LT' => sub {
        my $x = 2;
        like dies { assert( $x < 1 ) }, qr/\AAssertion failed \(2 < 1\)/;
        like dies { assert( $x < 2 ) }, qr/\AAssertion failed \(2 < 2\)/;
        ok lives { assert( $x < 3 ) };

        my $x2 = 2.01;
        like dies { assert( $x2 < 2 ) }, qr/\AAssertion failed \(2.01 < 2\)/;
        like dies { assert( $x2 < 2.01 ) }, qr/\AAssertion failed \(2.01 < 2.01\)/;
        ok lives { assert( $x2 < 3 ) };

        my $x3 = -1;
        ok lives { assert( $x3 < 0 ) };
        like dies { assert( $x3 < -1 ) }, qr/\AAssertion failed \(-1 < -1\)/;
        like dies { assert( $x3 < -2 ) }, qr/\AAssertion failed \(-1 < -2\)/;

        my $x4 = -1.01;
        ok lives { assert( $x4 < 0 ) };
        like dies { assert( $x4 < -1.01 ) }, qr/\AAssertion failed \(-1.01 < -1.01\)/;
        like dies { assert( $x4 < -2 ) }, qr/\AAssertion failed \(-1.01 < -2\)/;
    };

    subtest 'NUM_GT' => sub {
        my $x = 2;
        ok lives { assert( $x > 1 ) };
        like dies { assert( $x > 2 ) }, qr/\AAssertion failed \(2 > 2\)/;
        like dies { assert( $x > 3 ) }, qr/\AAssertion failed \(2 > 3\)/;

        my $x2 = 2.01;
        ok lives { assert( $x2 > 2 ) };
        like dies { assert( $x2 > 2.01 ) }, qr/\AAssertion failed \(2.01 > 2.01\)/;
        like dies { assert( $x2 > 3 ) }, qr/\AAssertion failed \(2.01 > 3\)/;

        my $x3 = -1;
        like dies { assert( $x3 > 0 ) }, qr/\AAssertion failed \(-1 > 0\)/;
        like dies { assert( $x3 > -1 ) }, qr/\AAssertion failed \(-1 > -1\)/;
        ok lives { assert( $x3 > -2 ) };

        my $x4 = -1.01;
        like dies { assert( $x4 > 0 ) }, qr/\AAssertion failed \(-1.01 > 0\)/;
        like dies { assert( $x4 > -1.01 ) }, qr/\AAssertion failed \(-1.01 > -1.01\)/;
        ok lives { assert( $x4 > -2 ) };
    };

    subtest 'STR_EQ' => sub {
        my $message = 'hello';

        ok lives { assert( $message eq 'hello' ) };
        like dies { assert( $message eq 'world' ) }, qr/\AAssertion failed \("hello" eq "world"\)/;

        my $x = 1;
        my $undef = undef;

        my $got = $] >= 5.036 ? '1' : '"1"';
        like dies { assert( $x eq 'world' ) }, qr/\AAssertion failed \($got eq "world"\)/;

        my $warnings = warnings {
            like dies { assert( $undef eq 'world' ) },   qr/\AAssertion failed \(undef eq "world"\)/;
        };
        # suppressed warnings
        is scalar @$warnings, 1;
    };

    subtest 'STR_NE' => sub {
        my $message = 'hello';
        ok lives { assert( $message ne 'world' ) };
        like dies { assert( $message ne 'hello' ) }, qr/\AAssertion failed \("hello" ne "hello"\)/;
    };

    subtest 'STR_LT' => sub {
        my $message = 'b';
        like dies { assert( $message lt 'a' ) }, qr/\AAssertion failed \("b" lt "a"\)/;
        like dies { assert( $message lt 'b' ) }, qr/\AAssertion failed \("b" lt "b"\)/;
        ok lives { assert( $message lt 'c' ) };

        my $unicode = "い";
        like dies { assert( $unicode lt 'あ' ) }, qr/\AAssertion failed \("い" lt "あ"\)/;
        like dies { assert( $unicode lt 'い' ) }, qr/\AAssertion failed \("い" lt "い"\)/;
        ok lives { assert( $unicode lt 'う' ) };
    };

    subtest 'STR_GT' => sub {
        my $message = 'b';
        ok lives { assert( $message gt 'a' ) };
        like dies { assert( $message gt 'b' ) }, qr/\AAssertion failed \("b" gt "b"\)/;
        like dies { assert( $message gt 'c' ) }, qr/\AAssertion failed \("b" gt "c"\)/;

        my $unicode = "い";
        ok lives { assert( $unicode gt 'あ' ) };
        like dies { assert( $unicode gt 'い' ) }, qr/\AAssertion failed \("い" gt "い"\)/;
        like dies { assert( $unicode gt 'う' ) }, qr/\AAssertion failed \("い" gt "う"\)/;
    };

    subtest 'STR_LE' => sub {
        my $message = 'b';
        like dies { assert( $message le 'a' ) }, qr/\AAssertion failed \("b" le "a"\)/;
        ok lives { assert( $message le 'b' ) };
        ok lives { assert( $message le 'c' ) };

        my $unicode = "い";
        like dies { assert( $unicode le 'あ' ) }, qr/\AAssertion failed \("い" le "あ"\)/;
        ok lives { assert( $unicode le 'い' ) };
        ok lives { assert( $unicode le 'う' ) };
    };

    subtest 'STR_GE' => sub {
        my $message = 'b';
        ok lives { assert( $message ge 'a' ) };
        ok lives { assert( $message ge 'b' ) };
        like dies { assert( $message ge 'c' ) }, qr/\AAssertion failed \("b" ge "c"\)/;

        my $unicode = "い";
        ok lives { assert( $unicode ge 'あ' ) };
        ok lives { assert( $unicode ge 'い' ) };
        like dies { assert( $unicode ge 'う' ) }, qr/\AAssertion failed \("い" ge "う"\)/;
    };
};

done_testing;
