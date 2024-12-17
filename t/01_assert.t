use Test2::V0;

use Syntax::Keyword::Assert;

use constant HAS_36 => $] >= 5.036;

subtest 'Test `assert` keyword' => sub {
    like dies {
        assert(0);
    }, qr/\AAssertion failed/;

    ok lives {
        assert(1);
    };

    my $hello = sub {
        my ($message) = @_;
        assert(defined $message);
        return "Hello, $message!";
    };

    ok lives { $hello->('world') };
    ok dies { $hello->(undef) };

    like dies { assert(undef) }, qr/\AAssertion failed \(undef\)/;
    like dies { assert(0) },     qr/\AAssertion failed \(0\)/;
    like dies { assert('0') },   qr/\AAssertion failed \("0"\)/;
    like dies { assert('') },    qr/\AAssertion failed \(""\)/;

    my $false = HAS_36 ? 'false' : '""';
    like dies { assert(!1) }, qr/\AAssertion failed \($false\)/;
};

sub expected_assert_bin {
    my ($left, $op, $right) = @_;

    my $m = match qr/\AAssertion failed \($left $op $right\)/;

    if (HAS_36) {
        return $m;
    }

    # Workaround to less than 5.36

    if ($left eq 'true')  { $left = 1 if !HAS_36 }
    if ($left eq 'false') { $left = "" if !HAS_36 }

    my $m1 = match qr/\AAssertion failed \($left $op $right\)/;
    my $m2 = match qr/\AAssertion failed \("$left" $op $right\)/;
    my $m3 = match qr/\AAssertion failed \("$left" $op "$right"\)/;
    return in_set($m, $m1, $m2, $m3);
}

subtest 'Test `assert(binary)` keyword' => sub {

    subtest 'NUM_EQ' => sub {
        my $x = 1;
        my $y = 2;
        ok lives { assert($x + $y == 3) };

        is dies { assert($x + $y == 100) }, expected_assert_bin(3, '==', 100);
        is dies { assert($x == 100) },      expected_assert_bin(1, '==', 100);

        is dies { assert(!!$x == 100) }, expected_assert_bin('true',  '==', 100);
        is dies { assert(!$x == 100) },  expected_assert_bin('false', '==', 100);

        my $message = 'hello';
        my $undef   = undef;

        my $warnings = warnings {
            is dies { assert($message == 100) }, expected_assert_bin('"hello"', '==', 100);
            is dies { assert($undef == 100) },   expected_assert_bin('undef',   '==', 100);
        };

        # suppressed warnings
        is scalar @$warnings, 2;
    };

    subtest 'NUM_NE' => sub {
        my $x = 2;
        ok lives { assert($x != 1) };
        is dies { assert($x != 2) }, expected_assert_bin(2, '!=', 2);
    };

    subtest 'NUM_LT' => sub {
        my $x = 2;
        is dies { assert($x < 1) }, expected_assert_bin(2, '<', 1);
        is dies { assert($x < 2) }, expected_assert_bin(2, '<', 2);
        ok lives { assert($x < 3) };

        my $x2 = 2.01;
        is dies { assert($x2 < 2) },    expected_assert_bin(2.01, '<', 2);
        is dies { assert($x2 < 2.01) }, expected_assert_bin(2.01, '<', 2.01);
        ok lives { assert($x2 < 3) };

        my $x3 = -1;
        ok lives { assert($x3 < 0) };
        is dies { assert($x3 < -1) }, expected_assert_bin(-1, '<', -1);
        is dies { assert($x3 < -2) }, expected_assert_bin(-1, '<', -2);

        my $x4 = -1.01;
        ok lives { assert($x4 < 0) };
        is dies { assert($x4 < -1.01) }, expected_assert_bin(-1.01, '<', -1.01);
        is dies { assert($x4 < -2) },    expected_assert_bin(-1.01, '<', -2);
    };

    subtest 'NUM_GT' => sub {
        my $x = 2;
        ok lives { assert($x > 1) };
        is dies { assert($x > 2) }, expected_assert_bin(2, '>', 2);
        is dies { assert($x > 3) }, expected_assert_bin(2, '>', 3);

        my $x2 = 2.01;
        ok lives { assert($x2 > 2) };
        is dies { assert($x2 > 2.01) }, expected_assert_bin(2.01, '>', 2.01);
        is dies { assert($x2 > 3) },    expected_assert_bin(2.01, '>', 3);

        my $x3 = -1;
        is dies { assert($x3 > 0) },  expected_assert_bin(-1, '>',  0);
        is dies { assert($x3 > -1) }, expected_assert_bin(-1, '>', -1);
        ok lives { assert($x3 > -2) };

        my $x4 = -1.01;
        is dies { assert($x4 > 0) },     expected_assert_bin(-1.01, '>',  0);
        is dies { assert($x4 > -1.01) }, expected_assert_bin(-1.01, '>', -1.01);
        ok lives { assert($x4 > -2) };
    };

    subtest 'NUM_LE' => sub {
        my $x = 2;
        is dies { assert($x <= 1) }, expected_assert_bin(2, '<=', 1);
        ok lives { assert($x <= 2) };
        ok lives { assert($x <= 3) };
    };

    subtest 'NUM_GE' => sub {
        my $x = 2;
        ok lives { assert($x >= 1) };
        ok lives { assert($x >= 2) };
        is dies { assert($x >= 3) }, expected_assert_bin(2, '>=', 3);
    };

    subtest 'STR_EQ' => sub {
        my $message = 'hello';

        ok lives { assert($message eq 'hello') };
        is dies { assert($message eq 'world') }, expected_assert_bin('"hello"', 'eq', '"world"');

        my $x     = 1;
        my $undef = undef;

        is dies { assert($x eq 'world') }, expected_assert_bin(1, 'eq', '"world"');

        my $warnings = warnings {
            is dies { assert($undef eq 'world') }, expected_assert_bin('undef', 'eq', '"world"');
        };

        # suppressed warnings
        is scalar @$warnings, 1;
    };

    subtest 'STR_NE' => sub {
        my $message = 'hello';
        ok lives { assert($message ne 'world') };
        is dies { assert($message ne 'hello') }, expected_assert_bin('"hello"', 'ne', '"hello"');
    };

    subtest 'STR_LT' => sub {
        my $message = 'b';
        is dies { assert($message lt 'a') }, expected_assert_bin('"b"', 'lt', '"a"');
        is dies { assert($message lt 'b') }, expected_assert_bin('"b"', 'lt', '"b"');
        ok lives { assert($message lt 'c') };

        my $unicode = "い";
        is dies { assert($unicode lt 'あ') }, expected_assert_bin('"い"', 'lt', '"あ"');
        is dies { assert($unicode lt 'い') }, expected_assert_bin('"い"', 'lt', '"い"');
        ok lives { assert($unicode lt 'う') };
    };

    subtest 'STR_GT' => sub {
        my $message = 'b';
        ok lives { assert($message gt 'a') };
        is dies { assert($message gt 'b') }, expected_assert_bin('"b"', 'gt', '"b"');
        is dies { assert($message gt 'c') }, expected_assert_bin('"b"', 'gt', '"c"');

        my $unicode = "い";
        ok lives { assert($unicode gt 'あ') };
        is dies { assert($unicode gt 'い') }, expected_assert_bin('"い"', 'gt', '"い"');
        is dies { assert($unicode gt 'う') }, expected_assert_bin('"い"', 'gt', '"う"');
    };

    subtest 'STR_LE' => sub {
        my $message = 'b';
        is dies { assert($message le 'a') }, expected_assert_bin('"b"', 'le', '"a"');
        ok lives { assert($message le 'b') };
        ok lives { assert($message le 'c') };

        my $unicode = "い";
        is dies { assert($unicode le 'あ') }, expected_assert_bin('"い"', 'le', '"あ"');
        ok lives { assert($unicode le 'い') };
        ok lives { assert($unicode le 'う') };
    };

    subtest 'STR_GE' => sub {
        my $message = 'b';
        ok lives { assert($message ge 'a') };
        ok lives { assert($message ge 'b') };
        is dies { assert($message ge 'c') }, expected_assert_bin('"b"', 'ge', '"c"');

        my $unicode = "い";
        ok lives { assert($unicode ge 'あ') };
        ok lives { assert($unicode ge 'い') };
        is dies { assert($unicode ge 'う') }, expected_assert_bin('"い"', 'ge', '"う"');
    };
};

done_testing;
