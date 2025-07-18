use Test;

#L<S02/The C<Num> and C<Rat> Types/Raku intrinsically supports big integers>

plan 112;

isa-ok( EVAL(1.Num.raku), Num, 'EVAL 1.Num.raku is Num' );
is-approx( EVAL(1.Num.raku), 1, 'EVAL 1.Num.raku is 1' );
isa-ok( EVAL(0.Num.raku), Num, 'EVAL 0.Num.raku is Num' );
is-approx( EVAL(0.Num.raku), 0, 'EVAL 0.Num.raku is 0' );
isa-ok( EVAL((-1).Num.raku), Num, 'EVAL -1.Num.raku is Num' );
is-approx( EVAL((-1).Num.raku), -1, 'EVAL -1.Num.raku is -1' );
isa-ok( EVAL(1.1.Num.raku), Num, 'EVAL 1.1.Num.raku is Num' );
is-approx( EVAL(1.1.raku), 1.1, 'EVAL 1.1.Num.raku is 1.1' );
isa-ok( EVAL((-1.1).Num.raku), Num, 'EVAL -1.1.Num.raku is Num' );
is-approx( EVAL((-1.1).raku), -1.1, 'EVAL -1.1.Num.raku is -1.1' );
isa-ok( EVAL(1e100.Num.raku), Num, 'EVAL 1e100.Num.raku is Num' );
is-approx( EVAL(1e100.Num.raku), 1e100, 'EVAL 1e100.Num.raku is 1' );

{
    my $a = 1; "$a";
    isa-ok($a, Int);
    is($a, "1", '1 stringification works');
}

{
    my $a = -1; "$a";
    isa-ok($a, Int);
    is($a, "-1", '-1 stringification works');
}

#L<S02/The C<Num> and C<Rat> Types/Rat supports extended precision rational arithmetic>
{
    my $a = 1 / 1;
    isa-ok($a, Rat);
    is(~$a, "1", '1/1 stringification works');
}

{
    my $a = -1.0;
    isa-ok($a, Rat);
    is($a, "-1", '-1 stringification works');
}

{
    my $a = 0.1;
    isa-ok($a, Rat);
    is($a, "0.1", '0.1 stringification works');
}

{
    my $a = -0.1; "$a";
    isa-ok($a, Rat);
    is($a, "-0.1", '-0.1 stringification works');
}

{
    my $a = 10.01; "$a";
    isa-ok($a, Rat);
    is($a, "10.01", '10.01 stringification works');
}

{
    my $a = -1.0e0;
    isa-ok($a, Num);
    is($a, "-1", '-1 stringification works');
}

{
    my $a = 0.1e0;
    isa-ok($a, Num);
    is($a, "0.1", '0.1 stringification works');
}

{
    my $a = -0.1e0; "$a";
    isa-ok($a, Num);
    is($a, "-0.1", '-0.1 stringification works');
}

{
    my $a = 10.01e0; "$a";
    isa-ok($a, Num);
    is($a, "10.01", '10.01 stringification works');
}

{
    my $a = 1e3; "$a";
    ok $a ~~ Num, '1e3 conforms to Num';
    is($a, "1000", '1e3 stringification works');
}

{
    my $a = 10.01e3; "$a";
    isa-ok($a, Num);
    is($a, "10010", '10.01e3 stringification works');
}

#L<S02/The C<Num> and C<Rat> Types/Raku intrinsically supports big integers>

{
    my $a = 0b100; "$a";
    isa-ok($a, Int);
    is($a, "4", '0b100 (binary) stringification works');
}

{
    my $a = 0x100; "$a";
    isa-ok($a, Int);
    is($a, "256", '0x100 (hex) stringification works');
}

{
    my $a = 0o100; "$a";
    isa-ok($a, Int);
    is($a, "64", '0o100 (octal) stringification works');
}

{
    my $a = 1; "$a";
    is($a + 1, 2, 'basic addition works');
}

{
    my $a = -1; "$a";
    ok($a + 1 == 0, 'basic addition with negative numbers works'); # parsing bug
}
#L<S02/The C<Num> and C<Rat> Types/Rat supports extended precision rational arithmetic>

isa-ok(1 / 1, Rat);

{
    my $a = 80000.0000000000000000000000000;
    isa-ok($a, Rat);
    ok($a == 80000.0, 'trailing zeros compare correctly');
}

{
    my $a = 1.0000000000000000000000000000000000000000000000000000000000000000000e1;
    isa-ok($a, Num);
    ok($a == 10.0, 'trailing zeros compare correctly');
}

#L<S02/The C<Num> and C<Rat> Types/Raku intrinsically supports big integers>
{
    my $a = "1.01";
    isa-ok($a.Int, Int);
    is($a.Int, 1, "1.01 intifies to 1");
}

#L<S02/The C<Num> and C<Rat> Types/may be bound to an arbitrary>
{
    my $a = "0d0101";
    isa-ok(+$a, Int);
    is(+$a, 101, "0d0101 numifies to 101");
}

{
    my $a = 2 ** 65; # over the 64 bit limit too
    is($a, 36893488147419103232, "we have bignums, not weeny floats");
}

is(42_000,     42000,    'underscores allowed (and ignored) in numeric literals');
is(42_127_000, 42127000, 'multiple underscores ok');
is(42.0_1,     42.01,    'underscores in fraction ok');
is(4_2.01,     42.01,    'underscores in whole part ok');

throws-like { EVAL '4_2._0_1' },
  X::Method::NotFound,
  'single underscores are not ok directly after the dot';
is(4_2.0_1, 42.01,  'single underscores are ok');

is 0_1, 1, "0_1 is parsed as 0d1";
is +^1, -2, '+^1 == -2 as promised';

# https://github.com/Raku/old-issue-tracker/issues/1567
ok 0xFFFFFFFFFFFFFFFF > 1, '0xFFFFFFFFFFFFFFFF is not -1';

# https://github.com/Raku/old-issue-tracker/issues/3485
ok Num === Num, 'Num === Num should be truthy, and not die';

{ # cover for https://github.com/rakudo/rakudo/commit/906719c8c528bb46c12ebd1ce857b7ec90ebe425
    cmp-ok 1e0.atanh, '==', ∞, '1e0.atanh returns ∞';
}

{ # coverage; 2016-10-14
    is-deeply Num.Range, -∞..∞, 'Num:U.Range gives -Inf to Inf range';

    subtest 'Num.new coerces types that can .Num' => {
        plan 6;

        is-deeply Num.new(42e0),  42e0, 'Num';
        is-deeply Num.new(42/1),  42e0, 'Rat';
        is-deeply Num.new(42),    42e0, 'Int';
        is-deeply Num.new(42+0i), 42e0, 'Complex';
        is-deeply Num.new("42"),  42e0, 'Str';

        throws-like { Num.new: class {} }, Exception,
            'class that cannot .Num';
    }

    subtest '++Num' => {
        plan 8;

        my $v1 = 4e0;
        is-deeply ++$v1, 5e0, 'return value (:D)';
        is-deeply   $v1, 5e0, 'new value (:D)';

        my Num $v2;
        is-deeply ++$v2, 1e0, 'return value (:U)';
        is-deeply   $v2, 1e0, 'new value (:U)';

        my num $v3 = 4e0;
        is-deeply ++$v3, (my num $=5e0), 'return value (native)';
        is-deeply   $v3, (my num $=5e0), 'new value (native)';

        my num $v4;
        cmp-ok ++$v4, '===', 1e0, 'return value (uninit. native)';
        cmp-ok   $v4, '===', 1e0, 'new value (uninit. native)';
    }

    subtest '--Num' => {
        plan 8;

        my $v1 = 4e0;
        is-deeply --$v1, 3e0, 'return value (:D)';
        is-deeply   $v1, 3e0, 'new value (:D)';

        my Num $v2;
        is-deeply --$v2, -1e0, 'return value (:U)';
        is-deeply   $v2, -1e0, 'new value (:U)';

        my num $v3 = 4e0;
        is-deeply --$v3, (my num $ = 3e0), 'return value (native)';
        is-deeply   $v3, (my num $ = 3e0), 'new value (native)';

        my num $v4;
        cmp-ok --$v4, '===', -1e0, 'return value (uninit. native)';
        cmp-ok   $v4, '===', -1e0, 'new value (uninit. native)';
    }

    subtest 'Num++' => {
        plan 4;
        my Num $v1;
        is-deeply $v1++, 0e0, 'return value';
        is-deeply $v1,   1e0, 'new value';

        my num $v2;
        cmp-ok $v2++, '===', 0e0, 'return value (uninit. native)';
        cmp-ok $v2,   '===', 1e0, 'new value (uninit. native)';
    }

    subtest 'Num--' => {
        plan 6;

        my Num $v1;
        is-deeply $v1--,  0e0, 'return value (:U)';
        is-deeply $v1,   -1e0, 'new value (:U)';

        my num $v2 = 4e0;
        is-deeply $v2--, (my num $ = 4e0), 'return value (native)';
        is-deeply $v2,   (my num $ = 3e0), 'new value (native)';

        my num $v3;
        cmp-ok $v3--, '===',  0e0, 'return value (uninit. native)';
        cmp-ok $v3,   '===', -1e0, 'new value (uninit. native)';
    }
}

{ # coverage; 2016-10-16
    subtest 'prefix:<->(num) and U+2212 prefix op' => {
        plan 8;
        cmp-ok -(my num $), '===', -0e0, '- uninitialized';
        cmp-ok −(my num $), '===', -0e0, '− (U+2212) uninitialized';
        is-deeply -(my num $ = 0e0  ), (my num $ = -0e0 ), '- zero';
        is-deeply −(my num $ = 0e0  ), (my num $ = -0e0 ), '− (U+2212) zero';
        is-deeply -(my num $ = 42e0 ), (my num $ = -42e0), '- positive';
        is-deeply −(my num $ = 42e0 ), (my num $ = -42e0),
            '− (U+2212) positive';
        is-deeply -(my num $ = -42e0), (my num $ = 42e0 ), '- negative';
        is-deeply −(my num $ = -42e0), (my num $ = 42e0 ),
            '− (U+2212) negative';
    }

    subtest 'abs(num)' => {
        plan 4;
        cmp-ok    abs(my num $), '===', 0e0, 'uninitialized';
        is-deeply abs(my num $ = 0e0),   (my num $ = 0e0),  'zero';
        is-deeply abs(my num $ = 42e0),  (my num $ = 42e0), 'positive';
        is-deeply abs(my num $ = -42e0), (my num $ = 42e0), 'negative';
    }

    subtest 'infix:<+>(num, num)' => {
        plan 16;
        my num $nu;
        my num $nz = 0e0;
        my num $np = 42e0;
        my num $nn = -42e0;

        cmp-ok $nu + $nz, '===', 0e0,   'uninit + zero';
        cmp-ok $nu + $np, '===', 42e0,  'uninit + positive';
        cmp-ok $nu + $nn, '===', -42e0, 'uninit + negative';
        cmp-ok $nu + $nu, '===', 0e0,   'uninit + uninit';
        cmp-ok $nz + $nu, '===', 0e0,   'zero + uninit';
        cmp-ok $np + $nu, '===', 42e0,  'positive + uninit';
        cmp-ok $nn + $nu, '===', -42e0, 'negative + uninit';

        is-deeply $nz + $np, (my num $ = 42e0 ), 'zero + positive';
        is-deeply $nz + $nn, (my num $ = -42e0), 'zero + negative';
        is-deeply $nz + $nz, (my num $ = 0e0  ), 'zero + zero';
        is-deeply $np + $nn, (my num $ = 0e0  ), 'positive + negative';
        is-deeply $np + $nz, (my num $ = 42e0 ), 'positive + zero';
        is-deeply $np + $np, (my num $ = 84e0 ), 'positive + positive';
        is-deeply $nn + $nz, (my num $ = -42e0), 'negative + zero';
        is-deeply $nn + $np, (my num $ = 0e0  ), 'negative + positive';
        is-deeply $nn + $nn, (my num $ = -84e0), 'negative + negative';
    }

    subtest 'infix:<*>(num, num)' => {
        plan 16;
        my num $nu;
        my num $nz = 0e0;
        my num $np = 4e0;
        my num $nn = -4e0;

        cmp-ok $nu * $nz, '===',  0e0, 'uninit * zero';
        cmp-ok $nu * $np, '===',  0e0, 'uninit * positive';
        cmp-ok $nu * $nn, '===', -0e0, 'uninit * negative';
        cmp-ok $nu * $nu, '===',  0e0, 'uninit * uninit';
        cmp-ok $nz * $nu, '===',  0e0, 'zero * uninit';
        cmp-ok $np * $nu, '===',  0e0, 'positive * uninit';
        cmp-ok $nn * $nu, '===', -0e0, 'negative * uninit';

        is-deeply $nz * $np, (my num $ = 0e0  ), 'zero * positive';
        is-deeply $nz * $nn, (my num $ = -0e0 ), 'zero * negative';
        is-deeply $nz * $nz, (my num $ = 0e0  ), 'zero * zero';
        is-deeply $np * $nn, (my num $ = -16e0), 'positive * negative';
        is-deeply $np * $nz, (my num $ = 0e0  ), 'positive * zero';
        is-deeply $np * $np, (my num $ = 16e0 ), 'positive * positive';
        is-deeply $nn * $nz, (my num $ = -0e0 ), 'negative * zero';
        is-deeply $nn * $np, (my num $ = -16e0), 'negative * positive';
        is-deeply $nn * $nn, (my num $ = 16e0 ), 'negative * negative';
    }
}

{ # coverage; 2016-10-16
    subtest 'infix:<%>(num, num)' => {
        plan 7;
        my num $nu;
        my num $nz  = 0e0;
        my num $n4  = 4e0;
        my num $n5  = 5e0;
        my num $nn4 = -4e0;

        cmp-ok $nu % $n5, '===', 0e0, 'uninit % defined';

        is-deeply $nz  % $n4,  (my num $ =  0e0), '0 % 4';
        is-deeply $n4  % $n5,  (my num $ =  4e0), '4 % 5';
        is-deeply $n5  % $n4,  (my num $ =  1e0), '5 % 4';
        is-deeply $nz  % $nn4, (my num $ =  0e0), '0 % -4';
        is-deeply $nn4 % $n5,  (my num $ =  1e0), '-4 % 5';
        is-deeply $n5  % $nn4, (my num $ = -3e0), '5 % -4';
    }

    subtest 'infix:<**>(num, num)' => {
        plan 22;
        my num $nu;
        my num $nz = 0e0;
        my num $n1 = 1e0;
        my num $np = 2e0;
        my num $nn = -2e0;

        cmp-ok $nu ** $n1, '===', 0e0, 'uninit ** 1st power';
        cmp-ok $nu ** $np, '===', 0e0, 'uninit ** positive';
        cmp-ok $nu ** $nn, '===', Inf, 'uninit ** negative';
        cmp-ok $nu ** $nu, '===', 1e0, 'uninit ** uninit';
        cmp-ok $nz ** $nu, '===', 1e0, 'zero ** uninit';
        cmp-ok $np ** $nu, '===', 1e0, 'positive ** uninit';
        cmp-ok $nn ** $nu, '===', 1e0, 'negative ** uninit';

        is-deeply $n1 ** $nu, (my num $ = 1e0    ), '1 ** uninit';
        is-deeply $nu ** $nz, (my num $ = 1e0    ), 'uninit ** zero';
        is-deeply $nz ** $np, (my num $ = 0e0    ), 'zero ** positive';
        is-deeply $nz ** $nz, (my num $ = 1e0    ), 'zero ** zero';
        is-deeply $nz ** $n1, (my num $ = 0e0    ), 'zero ** 1st power';
        is-deeply $np ** $nz, (my num $ = 1e0    ), 'positive ** zero';
        is-deeply $np ** $n1, (my num $ = 2e0    ), 'positive ** 1st power';
        is-deeply $np ** $np, (my num $ = 4e0    ), 'positive ** positive';
        is-deeply $nn ** $nz, (my num $ = 1e0    ), 'negative ** zero';
        is-deeply $nn ** $n1, (my num $ = -2e0   ), 'negative ** 1st power';
        is-deeply $nn ** $np, (my num $ = 4e0    ), 'negative ** positive';
        is-approx $np ** $nn, (my num $ = 0.25e0 ), 'positive ** negative';
        is-approx $nn ** $nn, (my num $ = 0.25e0 ), 'negative ** negative';

        # rational powers => like taking roots
        is-approx (my num $ = 125e0) ** (my num $ = (1/3).Num),
            (my num $ = 5e0), '1/3 power (third root)';
        is-approx (my num $ = 125e0) ** (my num $ = (4/6).Num),
            (my num $ = 25e0), '4/6 power (6th root of 4th power)';
    }

    subtest 'log(num)' => sub {
        plan 9;
        cmp-ok    log(my num $        ), '===', -Inf, 'uninitialized';
        cmp-ok    log(my num $ = NaN  ), '===', NaN, 'NaN';
        cmp-ok    log(my num $ = -42e0), '===', NaN, 'negative';
        cmp-ok    log(my num $ =    -∞), '===', NaN, '-∞';
        is-deeply log(my num $ =     ∞), my num $ =      ∞, '+∞';
        is-deeply log(my num $ =   0e0), my num $ =     -∞, 'zero';
        is-deeply log(my num $ =  -0e0), my num $ =     -∞, 'neg zero';
        is-deeply log(my num $ =   1e0), my num $ =    0e0, 'one';
        is-approx log(my num $ =  42e0), my num $ = 3.74e0, '42',
            :abs-tol(.01);
    }

    subtest 'ceiling(num)' => sub {
        plan 10;
        cmp-ok    ceiling(my num $         ), '===', 0e0, 'uninitialized';
        cmp-ok    ceiling(my num $ =    NaN), '===', NaN, 'NaN';
        is-deeply ceiling(my num $ =     -∞), my num $ =   -∞, '-∞';
        is-deeply ceiling(my num $ =      ∞), my num $ =    ∞, '+∞';
        is-deeply ceiling(my num $ =    0e0), my num $ =  0e0, 'zero';
        is-deeply ceiling(my num $ =   -0e0), my num $ = -0e0, 'neg zero';
        is-deeply ceiling(my num $ =  4.7e0), my num $ =  5e0, 'positive (1)';
        is-deeply ceiling(my num $ =  4.2e0), my num $ =  5e0, 'positive (2)';
        is-deeply ceiling(my num $ = -4.7e0), my num $ = -4e0, 'negative (1)';
        is-deeply ceiling(my num $ = -4.2e0), my num $ = -4e0, 'negative (2)';
    }
}

{ # coverage; 2016-10-18

    # Special cases, like NaN/Inf returns, are based on 2008 IEEE 754 standard

    sub prefix:<√> { sqrt $^x }

    subtest 'sin(num)' => {
        plan 13;

        cmp-ok sin(my num $      ), '===', 0e0, 'uninitialized';
        cmp-ok sin(my num $ = NaN), '===', NaN, 'NaN';
        cmp-ok sin(my num $ =  -∞), '===', NaN, '-∞';
        cmp-ok sin(my num $ =   ∞), '===', NaN, '+∞';

        is-approx sin(my num $ =  0e0), my num $ =   0e0,  '0e0';
        is-approx sin(my num $ =    τ), my num $ =   0e0,  'τ';
        is-approx sin(my num $ =   -τ), my num $ =   0e0,  '-τ';
        is-approx sin(my num $ =    π), my num $ =   0e0,  'π';
        is-approx sin(my num $ =   -π), my num $ =   0e0,  '-π';
        is-approx sin(my num $ =  π/2), my num $ =   1e0,  'π/2';
        is-approx sin(my num $ = -π/2), my num $ =  -1e0,  '-π/2';
        is-approx sin(my num $ =  π/4), my num $ =  .5*√2, 'π/4';
        is-approx sin(my num $ = -π/4), my num $ = -.5*√2, '-π/4';
    }

    subtest 'asin(num)' => {
        plan 11;

        cmp-ok asin(my num $         ), '===', 0e0, 'uninitialized';
        cmp-ok asin(my num $ =    NaN), '===', NaN, 'NaN';
        cmp-ok asin(my num $ =     -∞), '===', NaN, '-∞';
        cmp-ok asin(my num $ =      ∞), '===', NaN, '+∞';
        cmp-ok asin(my num $ = -1.1e0), '===', NaN, '-1.1e0';
        cmp-ok asin(my num $ =  1.1e0), '===', NaN, '+1.1e0';

        is-approx asin(my num $ =    0e0), my num $ =  0e0, '0e0';
        is-approx asin(my num $ =    1e0), my num $ =  π/2, '1e0';
        is-approx asin(my num $ =   -1e0), my num $ = -π/2, '-1e0';
        is-approx asin(my num $ =  .5*√2), my num $ =  π/4, '½√2';
        is-approx asin(my num $ = -.5*√2), my num $ = -π/4, '-½√2';
    }

    subtest 'cos(num)' => {
        plan 13;

        cmp-ok cos(my num $      ), '===', 1e0, 'uninitialized';
        cmp-ok cos(my num $ = NaN), '===', NaN, 'NaN';
        cmp-ok cos(my num $ =  -∞), '===', NaN, '-∞';
        cmp-ok cos(my num $ =   ∞), '===', NaN, '+∞';

        is-approx cos(my num $ =  0e0), my num $ =  1e0,  '0e0';
        is-approx cos(my num $ =  π/4), my num $ = .5*√2, 'π/4';
        is-approx cos(my num $ = -π/4), my num $ = .5*√2, '-π/4';
        is-approx cos(my num $ =    π), my num $ = -1e0,  'π';
        is-approx cos(my num $ =   -π), my num $ = -1e0,  '-π';
        is-approx cos(my num $ =  π/2), my num $ =  0e0,  'π/2';
        is-approx cos(my num $ = -π/2), my num $ =  0e0,  '-π/2';
        is-approx cos(my num $ =  π/4), my num $ = .5*√2, 'π/4';
        is-approx cos(my num $ = -π/4), my num $ = .5*√2, '-π/4';
    }

    subtest 'acos(num)' => {
        plan 11;

        cmp-ok acos(my num $ =    NaN), '===', NaN, 'NaN';
        cmp-ok acos(my num $ =     -∞), '===', NaN, '-∞';
        cmp-ok acos(my num $ =      ∞), '===', NaN, '+∞';
        cmp-ok acos(my num $ = -1.1e0), '===', NaN, '-1.1e0';
        cmp-ok acos(my num $ =  1.1e0), '===', NaN, '+1.1e0';

        is-approx acos(my num $         ), my num $ =  π/2,  '1e0';
        is-approx acos(my num $ =    1e0), my num $ =  0e0,  '1e0';
        is-approx acos(my num $ =   -1e0), my num $ =  π,    '-1e0';
        is-approx acos(my num $ =    0e0), my num $ =  π/2,  '0e0';
        is-approx acos(my num $ =  .5*√2), my num $ =  π/4,  '½√2';
        is-approx acos(my num $ = -.5*√2), my num $ = .75*π, '-½√2';
    }

    subtest 'tan(num)' => {
        plan 13;

        cmp-ok tan(my num $ = NaN), '===', NaN, 'NaN';
        cmp-ok tan(my num $ =  -∞), '===', NaN, '-∞';
        cmp-ok tan(my num $ =   ∞), '===', NaN, '+∞';

        is-approx tan(my num $       ), my num $ =  0e0, 'uninitialized';
        is-approx tan(my num $ =  0e0), my num $ =  0e0,        '0e0';
        is-approx tan(my num $ =    τ), my num $ =  0e0,        'τ';
        is-approx tan(my num $ =   -τ), my num $ =  0e0,        '-τ';
        is-approx tan(my num $ =    π), my num $ =  0e0,        'π';
        is-approx tan(my num $ =   -π), my num $ =  0e0,        '-π';
        is-approx tan(my num $ =  π/4), my num $ =  1e0,        'π/4';
        is-approx tan(my num $ = -π/4), my num $ = -1e0,        '-π/4';
        is-approx tan(my num $ =  π/2),  (sin(π/2) / cos(π/2)), 'π/2',
            :rel-tol<5e-5>;
        is-approx tan(my num $ = -π/2), -(sin(π/2) / cos(π/2)), '-π/2',
            :rel-tol<5e-5>;
    }

    subtest 'atan(num)' => {
        plan 7;

        cmp-ok atan(my num $ = NaN), '===', NaN, 'NaN';

        is-approx atan(my num $       ), my num $ =  0e0, 'uninitialized';
        is-approx atan(my num $ =  0e0), my num $ =  0e0, '0e0';
        is-approx atan(my num $ =  1e0), my num $ =  π/4, '1e0';
        is-approx atan(my num $ = -1e0), my num $ = -π/4, '-1e0';
        is-approx atan(my num $ =    π), my num $ =  1.26262725567891e0, 'π';
        is-approx atan(my num $ =   -π), my num $ = -1.26262725567891e0, '-π';
    }

    subtest 'sec(num)' => {
        plan 13;

        cmp-ok sec(my num $ = NaN), '===', NaN, 'NaN';
        cmp-ok sec(my num $ =  -∞), '===', NaN, '-∞';
        cmp-ok sec(my num $ =   ∞), '===', NaN, '+∞';

        is-approx sec(my num $       ), my num $ =  1e0, 'uninitialized';
        is-approx sec(my num $ =  0e0), my num $ =  1e0,  '0e0';
        is-approx sec(my num $ =    τ), my num $ =  1e0,  'τ';
        is-approx sec(my num $ =   -τ), my num $ =  1e0,  '-τ';
        is-approx sec(my num $ =    π), my num $ = -1e0,  'π';
        is-approx sec(my num $ =   -π), my num $ = -1e0,  '-π';
        is-approx sec(my num $ =  π/4), my num $ =  2/√2, 'π/4';
        is-approx sec(my num $ = -π/4), my num $ =  2/√2, '-π/4';

        # Since we don't have perfect π, cheetsy-doodle to get "infinity"
        is-approx sec(my num $ =  π/2), my num $ = tan(π/2), 'π/2',
            :rel-tol<5e-5>;
        is-approx sec(my num $ = -π/2), my num $ = tan(π/2), '-π/2',
            :rel-tol<5e-5>;
    }

    subtest 'asec(num)' => {
        plan 10;

        cmp-ok asec(my num $        ), '===', NaN, 'uninitialized';
        cmp-ok asec(my num $ =   NaN), '===', NaN, 'NaN';
        cmp-ok asec(my num $ =   0e0), '===', NaN, '0e0';
        cmp-ok asec(my num $ =  .9e0), '===', NaN, '.9e0';
        cmp-ok asec(my num $ = -.9e0), '===', NaN, '-.9e0';

        is-approx asec(my num $ =   1e0), my num $ = 0e0,   '1e0';
        is-approx asec(my num $ =     ∞), my num $ = π/2,   '∞';
        is-approx asec(my num $ =    -∞), my num $ = π/2,   '-∞';
        is-approx asec(my num $ =  2/√2), my num $ = π/4,   '2/√2';
        is-approx asec(my num $ = -2/√2), my num $ = 3/4*π, '-2/√2';
    }

    subtest 'cotan(num)' => {
        plan 38;

        cmp-ok cotan(my num $      ), '===', my num $ = ∞, 'uninitialized';
        cmp-ok cotan(my num $ = NaN), '===', NaN, 'NaN';
        cmp-ok cotan(my num $ =  -∞), '===', NaN, '-∞';
        cmp-ok cotan(my num $ =   ∞), '===', NaN, '+∞';

        cmp-ok cotan(my num $ =  0e0), '==', my num $ =  ∞,         '0e0';
        cmp-ok cotan(my num $ = -0e0), '==', my num $ = -∞,         '-0e0';

        is-approx cotan(my num $ =    π/12), my num $ = 2+√3,       'π/12';
        is-approx cotan(my num $ =    π/10), my num $ = √(5+2*√5),  'π/10';
        is-approx cotan(my num $ =     π/8), my num $ = 1+√2,       'π/8';
        is-approx cotan(my num $ =     π/6), my num $ = √3,         'π/6';
        is-approx cotan(my num $ =     π/5), my num $ = √(1+2/√5),  'π/5';
        is-approx cotan(my num $ =     π/4), my num $ = 1e0,        'π/4';
        is-approx cotan(my num $ =  3*π/10), my num $ = √(5-2*√5),  '3*π/10';
        is-approx cotan(my num $ =     π/3), my num $ = √3/3,       'π/3';
        is-approx cotan(my num $ =   3*π/8), my num $ = √2-1,       '3*π/8';
        is-approx cotan(my num $ =   2*π/5), my num $ = √(1-2/√5),  '2*π/5';
        is-approx cotan(my num $ =  5*π/12), my num $ = 2-√3,       '5*π/12';
        is-approx cotan(my num $ =     π/2), my num $ = 0e0,        '-π/2';
        is-approx cotan(my num $ =   3*π/2), my num $ = 0e0,        '3*π/2';
        is-approx cotan(my num $ =   5*π/2), my num $ = 0e0,        '5*π/2';

        is-approx cotan(my num $ =   -π/12), my num $ = -(2+√3),    '-π/12';
        is-approx cotan(my num $ =   -π/10), my num $ = -√(5+2*√5), '-π/10';
        is-approx cotan(my num $ =    -π/8), my num $ = -(1+√2),    '-π/8';
        is-approx cotan(my num $ =    -π/6), my num $ = -√3,        '-π/6';
        is-approx cotan(my num $ =    -π/5), my num $ = -√(1+2/√5), '-π/5';
        is-approx cotan(my num $ =    -π/4), my num $ = -1e0,       '-π/4';
        is-approx cotan(my num $ = -3*π/10), my num $ = -√(5-2*√5), '-3*π/10';
        is-approx cotan(my num $ =    -π/3), my num $ = -√3/3,      '-π/3';
        is-approx cotan(my num $ =  -3*π/8), my num $ = -(√2-1),    '-3*π/8';
        is-approx cotan(my num $ =  -2*π/5), my num $ = -√(1-2/√5), '-2*π/5';
        is-approx cotan(my num $ = -5*π/12), my num $ = -(2-√3),    '-5*π/12';
        is-approx cotan(my num $ =    -π/2), my num $ = 0e0,        '-π/2';
        is-approx cotan(my num $ =  -3*π/2), my num $ = 0e0,        '-3*π/2';
        is-approx cotan(my num $ =  -5*π/2), my num $ = 0e0,        '-5*π/2';

        # Since we don't have perfect π, cheetsy-doodle to get "infinity"
        # NOTE: the / on tan is to compensate for π's inexactness
        is-approx cotan(my num $ =  π), my num $ = -tan(π/2)/2, 'π';
        is-approx cotan(my num $ = -π), my num $ =  tan(π/2)/2, '-π';
        is-approx cotan(my num $ =  τ), my num $ = -tan(π/2)/4, 'τ';
        is-approx cotan(my num $ = -τ), my num $ =  tan(π/2)/4, '-τ';
    }

    subtest 'acotan(num)' => {
        plan 29;

        cmp-ok acotan(my num $ = NaN), '===', NaN, 'NaN';
        is-approx acotan(my num $), my num $ =  π/2, 'uninitialized';
        is-deeply acotan(my num $ = -∞), -0e0, '-∞ is -0';

        is-approx acotan(my num $ =          ∞), my num $ =  0e0,    '∞';
        is-approx acotan(my num $ =         -∞), my num $ = -0e0,    '-∞';
        is-approx acotan(my num $ =        0e0), my num $ =  π/2,    '0e0';
        is-approx acotan(my num $ =       -0e0), my num $ = -π/2,    '-0e0';

        is-approx acotan(my num $ =       2+√3), my num $ =  π/12,   '2+√3';
        is-approx acotan(my num $ =  √(5+2*√5)), my num $ =  π/10,   '√(5+2*√5)';
        is-approx acotan(my num $ =       1+√2), my num $ =  π/8,    '1+√2';
        is-approx acotan(my num $ =         √3), my num $ =  π/6,    '√3';
        is-approx acotan(my num $ =  √(1+2/√5)), my num $ =  π/5,    '√(1+2/√5)';
        is-approx acotan(my num $ =        1e0), my num $ =  π/4,    '1e0';
        is-approx acotan(my num $ =  √(5-2*√5)), my num $ =  3*π/10, '√(5-2*√5)';
        is-approx acotan(my num $ =       √3/3), my num $ =  π/3,    '√3/3';
        is-approx acotan(my num $ =       √2-1), my num $ =  3*π/8,  '√2-1';
        is-approx acotan(my num $ =  √(1-2/√5)), my num $ =  2*π/5,  '√(1-2/√5)';
        is-approx acotan(my num $ =       2-√3), my num $ =  5*π/12, '2-√3';

        is-approx acotan(my num $ =    -(2+√3)), my num $ = -π/12,   '-(2+√3)';
        is-approx acotan(my num $ = -√(5+2*√5)), my num $ = -π/10,   '-√(5+2*√5)';
        is-approx acotan(my num $ =    -(1+√2)), my num $ = -π/8,    '-(1+√2)';
        is-approx acotan(my num $ =        -√3), my num $ = -π/6,    '-√3';
        is-approx acotan(my num $ = -√(1+2/√5)), my num $ = -π/5,    '-√(1+2/√5)';
        is-approx acotan(my num $ =       -1e0), my num $ = -π/4,    '-1e0';
        is-approx acotan(my num $ = -√(5-2*√5)), my num $ = -3*π/10, '-√(5-2*√5)';
        is-approx acotan(my num $ =      -√3/3), my num $ = -π/3,    '-√3/3';
        is-approx acotan(my num $ =    -(√2-1)), my num $ = -3*π/8,  '-(√2-1)';
        is-approx acotan(my num $ = -√(1-2/√5)), my num $ = -2*π/5,  '-√(1-2/√5)';
        is-approx acotan(my num $ =    -(2-√3)), my num $ = -5*π/12, '-(2-√3)';
    }

    subtest 'sinh(num)' => {
        my @test-values = e, 0e0, 1e0, π, τ, 1e2;
        plan 2*@test-values + 6;

        cmp-ok sinh(my num $      ), '===', 0e0, 'uninitialized';
        cmp-ok sinh(my num $ = NaN), '===', NaN, 'NaN';

        cmp-ok sinh(my num $ =     ∞), '==',  ∞,     '∞';
        cmp-ok sinh(my num $ =    -∞), '==', -∞,    '-∞';
        cmp-ok sinh(my num $ =  1e20), '==',  ∞,  '1e20';
        cmp-ok sinh(my num $ = -1e20), '==', -∞, '-1e20';

        for @test-values.map({|($_, -$_)}) -> $x {
            is-approx sinh(my num $ = $x), my num $ = (e**$x - e**(-$x))/2, ~$x;
        }
    }

    subtest 'asinh(num)' => {
        my @test-values = e, 0e0, 1e0, π, τ, 1e2;
        plan 2*@test-values + 7;

        cmp-ok asinh(my num $      ), '===', 0e0, 'uninitialized';
        cmp-ok asinh(my num $ = NaN), '===', NaN, 'NaN';

        cmp-ok asinh(my num $ =      ∞), '==',  ∞,      '∞';
        cmp-ok asinh(my num $ =     -∞), '==', -∞,     '-∞';

        cmp-ok asinh(my num $ =  1e200), '==',  ∞,  '1e200';
        # https://github.com/Raku/old-issue-tracker/issues/5760
        #?rakudo 2 todo 'asinh does not comply with IEEE'
        cmp-ok asinh(my num $ = -1e200), '==', -∞, '-1e200';
        is asinh(my num $ = -0e0).Str, '-0', '-0e0 actually gives a minus 0';

        for @test-values.map({|($_, -$_)}) -> $x {
            is-approx asinh(my num $ = $x), my num $ = log($x+√($x²+1)), ~$x;
        }
    }

    subtest 'cosh(num)' => {
        my @test-values = e, 0e0, 1e0, π, τ, 1e2;
        plan 2*@test-values + 6;

        cmp-ok cosh(my num $      ), '===', 1e0, 'uninitialized';
        cmp-ok cosh(my num $ = NaN), '===', NaN, 'NaN';

        cmp-ok cosh(my num $ =     ∞), '==',  ∞,     '∞';
        cmp-ok cosh(my num $ =    -∞), '==',  ∞,    '-∞';
        cmp-ok cosh(my num $ =  1e20), '==',  ∞,  '1e20';
        cmp-ok cosh(my num $ = -1e20), '==',  ∞, '-1e20';

        for @test-values.map({|($_, -$_)}) -> $x {
            is-approx cosh(my num $ = $x), my num $ = (e**$x + e**(-$x))/2, ~$x;
        }
    }

    subtest 'acosh(num)' => {
        my @test-values = e, 1e0, π, τ, 1e20;
        plan 2*@test-values + 10;

        cmp-ok acosh(my num $         ), '===', NaN, 'uninitialized';
        cmp-ok acosh(my num $ =    NaN), '===', NaN, 'NaN';
        cmp-ok acosh(my num $ =    0e0), '===', NaN, '0e0';
        cmp-ok acosh(my num $ =   .9e0), '===', NaN, '.9e0';
        cmp-ok acosh(my num $ =   -1e0), '===', NaN, '-1e0';
        cmp-ok acosh(my num $ = -1e100), '===', NaN, '-1e100';
        cmp-ok acosh(my num $ = -1e200), '===', NaN, '-1e200';
        cmp-ok acosh(my num $ =     -∞), '===', NaN, '-∞';

        cmp-ok acosh(my num $ =      ∞), '==',  ∞, '∞';
        cmp-ok acosh(my num $ =  1e200), '==',  ∞, '1e200';

        for @test-values -> $x {
            is-approx acosh(my num $ =  $x), my num $ = log($x+√($x²-1)), ~$x;
            cmp-ok    acosh(my num $ = -$x), '===',  NaN, '-' ~ $x;
        }
    }

    subtest 'tanh(num)' => {
        my @test-values = e, 0e0, 1e0, π, τ, 1e2;
        plan 2*@test-values + 6;

        cmp-ok tanh(my num $      ), '===', 0e0, 'uninitialized';
        cmp-ok tanh(my num $ = NaN), '===', NaN, 'NaN';

        cmp-ok tanh(my num $ =     ∞), '==',  1e0,     '∞';
        cmp-ok tanh(my num $ =    -∞), '==', -1e0,    '-∞';
        cmp-ok tanh(my num $ =  1e20), '==',  1e0,  '1e20';
        cmp-ok tanh(my num $ = -1e20), '==', -1e0, '-1e20';

        for @test-values.map({|($_, -$_)}) -> $x {
            my \term:<e²ˣ> = e**(2*$x);
            is-approx tanh(my num $ = $x), my num $ = (e²ˣ-1)/(e²ˣ+1), ~$x;
        }
    }

    subtest 'atanh(num)' => {
        my @nan-test-values = e, 1e1, π, τ, 1e20, 1e100, 1e200, 1e1000, ∞;
        my     @test-values = 0e0, .2e0, .3e0, .5e0, .7e0, .9e0;
        plan 2*@test-values + 2*@nan-test-values + 2;

        cmp-ok atanh(my num $ =  1e0), '==',  ∞,  '1e0';
        cmp-ok atanh(my num $ = -1e0), '==', -∞, '-1e0';

        for @nan-test-values.map({|($_, -$_)}) -> $x {
            #?rakudo todo "atanh for these values return Complex in 6.e"
            is-approx atanh(my num $ = $x), log((1+$x)/(1-$x))/2,
              "atanh($x) is a Complex";
        }

        for @test-values.map({|($_, -$_)}) -> $x {
            is-approx atanh(my num $ = $x), my num $ = log((1+$x)/(1-$x))/2, ~$x;
        }
    }
}

# https://github.com/Raku/old-issue-tracker/issues/5784
is-approx 1.2e308, 2*.6e308, 'Literal Nums close to the upper limit are not Inf';

subtest '.Bool' => {
    plan 5;
    is-deeply    42e0.Bool, True,  'positive';
    is-deeply (-42e0).Bool, True,  'negative';
    is-deeply     0e0.Bool, False, 'zero';
    is-deeply  (-0e0).Bool, False, 'negative zero';

    # https://irclog.perlgeek.de/perl6-dev/2018-02-21#i_15843708
    is-deeply     NaN.Bool, True,  'NaN';
}

# https://github.com/rakudo/rakudo/issues/1626
# https://github.com/Raku/old-issue-tracker/issues/6594
subtest 'no parsing glitches in the way Num is parsed' => {
    plan 3;

    my num $a = 602214090000000000000000e0;
    my num $b = 6.0221409e+23;
    cmp-ok $a, '==', $b, '(1)';

    cmp-ok .1e0    +  .2e0,    '!=', .3e0,    '(2)';
    cmp-ok  1.0e-1 +   2.0e-1, '!=',  3.0e-1, '(3)';
}

# https://github.com/Raku/old-issue-tracker/issues/6594
cmp-ok 1.000000000000001e0, '!=', 1e0,
    'Nums that are close to each other parsed correctly as different';

subtest 'Num literals yield closest available Num to their nominal value' => {
    plan 2;
    my $a := (9.999e-5               * 2e0**66).Int * 5**8 - 9999 * 2**58;
    my $b := (9.99899999999999995e-5 * 2e0**66).Int * 5**8 - 9999 * 2**58;
    cmp-ok $a, '==', -103256, '9.999e-5';
    cmp-ok $b, '==', -103256, '9.99899999999999995e-5';
}

subtest 'parsed nums choose closest available representation' => {
    plan 13;
    # https://github.com/Raku/old-issue-tracker/issues/5564
    cmp-ok '9.9989999999999991e0'.EVAL, &[!<], '9.998999999999999e0'.EVAL;

    cmp-ok <241431045331557770.44e-161>,  '==', 241431045331557770.44e-161; # 2
    cmp-ok <2.41431045331557783896e-144>, '==', 241431045331557770.44e-161;
    cmp-ok  2.41431045331557783896e-144,  '==', 241431045331557770.44e-161;

    cmp-ok <86004303003.045451885e-269>,  '==', 86004303003.045451885e-269; # 5
    cmp-ok <8.60043030030454550566e-259>, '==', 86004303003.045451885e-269;
    cmp-ok  8.60043030030454550566e-259,  '==', 86004303003.045451885e-269;

    cmp-ok <331.11563566342757550e202>,   '==', 331.11563566342757550e202; # 8
    cmp-ok <3.31115635663427602973e+204>, '==', 331.11563566342757550e202;
    cmp-ok 3.31115635663427602973e+204,   '==', 331.11563566342757550e202;

    # compare to what it stringifies too
    cmp-ok 2026887777243374/10**63,        '==', 2.026887777243374e-48; # 11
    #?rakudo.jvm 2 todo 'stringifies to 2.026887777243374E-48'
    cmp-ok (2026887777243374/10**63).raku, 'eq', '2.026887777243374e-48';
    cmp-ok 2.026887777243374e-48.raku,     'eq', '2.026887777243374e-48';


}

# https://github.com/Raku/old-issue-tracker/issues/6623
cmp-ok Num(0.777777777777777777777), '==', Num(0.7777777777777777777771),
    'Rat->Num conversion is monotonic';

subtest 'parsed nums are the same as those produced from Str.Num' => {
    plan 5;
    is '9.998999999999999e0'.EVAL, '9.998999999999999',
        'parsed number stringification';
    is '9.998999999999999e0'.Num, '9.998999999999999',
        'Str.Num stringification';
    is val('9.998999999999999e0').Numeric.Str, '9.998999999999999',
        'val().Numeric.Str stringification';

    cmp-ok '9.998999999999999e0'.EVAL, '==', '9.998999999999999e0'.Num,
      'parsed matches Str.Num';
    cmp-ok '9.998999999999999e0'.EVAL, '==', val('9.998999999999999e0'),
      'parsed matches val()';
}

# https://github.com/Raku/old-issue-tracker/issues/5521
subtest 'distinct num literals do not compare the same' => {
    plan 3;
    my $l1 := 1180591620717411303424e0;
    my $l2 := 1180591620717409992704e0;
    cmp-ok $l1, &[!==],  $l2, '==';
    cmp-ok $l1, &[!===], $l2, '===';

    # https://github.com/Raku/old-issue-tracker/issues/5520
    cmp-ok $l1.WHICH, &[!===], $l2.WHICH, '=== of .WHICHes';
}

# https://github.com/Raku/old-issue-tracker/issues/5518
{
    my $n := 1180591620717411303424.0e0;
    cmp-ok $n.Int, '==', $n.raku.EVAL.Int,
        '.raku roundtrips the Num correctly';
}

subtest 'no hangs/crashes when parsing nums with huge exponents' => {
    plan 2;
    subtest 'huge-ish exponent' => { # this used to hang
        plan 7;
        is-deeply   1e100000000,          Inf,  'Num literal';
        is-deeply  "1e100000000".EVAL,    Inf,  'Num literal in EVAL';
        is-deeply +"1e100000000",         Inf,  '+Str';
        is-deeply  "1e100000000".Numeric, Inf,  'Str.Numeric';
        is-deeply  "1e100000000".Num,     Inf,  'Str.Num';
        is-deeply  <1e100000000>,        NumStr.new(Inf, '1e100000000'), 'Num allomorph';
        is-deeply "<1e100000000>".EVAL,  NumStr.new(Inf, '1e100000000'), 'Num allomorph in EVAL';
    }
    subtest 'huge-huge-huge exponent' => { # this used to crash
        plan 7;
        is-deeply 1e1000000000000000000000000000000000000000000000000000000, Inf, 'Num literal';
        is-deeply "1e1000000000000000000000000000000000000000000000000000000".EVAL, Inf,
            'Num literal in EVAL';

        is-deeply +"1e1000000000000000000000000000000000000000000000000000000", Inf, '+Str';
        is-deeply "1e1000000000000000000000000000000000000000000000000000000".Numeric, Inf,
            'Str.Numeric';
        is-deeply "1e1000000000000000000000000000000000000000000000000000000".Num, Inf,
            'Str.Num';

        is-deeply <1e1000000000000000000000000000000000000000000000000000000>,
            NumStr.new(Inf, '1e1000000000000000000000000000000000000000000000000000000'),
            'Num allomorph';
        is-deeply "<1e1000000000000000000000000000000000000000000000000000000>".EVAL,
            NumStr.new(Inf, '1e1000000000000000000000000000000000000000000000000000000'),
            'Num allomorph in EVAL';
    }
}

# https://github.com/rakudo/rakudo/issues/2434
{
    my num $a = 5e0;
    my num $b;
    #?rakudo.jvm 4 todo 'throws X::AdHox "This type (P6opaque) cannot unbox to a native number"'
    fails-like { $a % $b }, X::Numeric::DivideByZero,
      using     => '%',
      numerator => $a,
      'does num % 0e0 return a Failure'
    ;

    fails-like { $b % $b }, X::Numeric::DivideByZero,
      using     => '%',
      numerator => $b,
      'does 0e0 % 0e0 return a Failure'
    ;

    fails-like { $a / $b }, X::Numeric::DivideByZero,
      using     => '/',
      numerator => $a,
      'does num / 0e0 return a Failure'
    ;

    $b = -1e20;
    fails-like { $a ** $b }, X::Numeric::Underflow,
      'does num ** -1e20 return a Failure'
    ;
}

# vim: expandtab shiftwidth=4
