use Test;

plan 259;

# basic Range
# L<S02/Immutable types/A pair of Ordered endpoints>

my $r = 1..5;
isa-ok $r, Range, 'Type';
is $r.WHAT.gist, Range.gist, 'Type';
is $r.raku, '1..5', 'canonical representation';

# XXX unspecced: exact value of Range.raku
is (1..5).raku, '1..5', ".raku ..";
is (1^..5).raku, '1^..5', ".raku ^..";
is (1..^5).raku, '1..^5', ".raku ..^";
is (1^..^5).raku, '1^..^5', ".raku ^..^";

my @r = $r;
is @r.raku, "[1..5,]", 'got the right array';

# Range of Str

$r = 'a'..'c';
isa-ok $r, Range;
# XXX unspecced: exact value of Range.raku
is $r.raku, '"a".."c"', 'canonical representation';
@r = $r;
is @r.raku, '["a".."c",]', 'got the right array';

# Stationary ranges
is (1..1).raku, '1..1', "stationary num .raku ..";
is (1..1), [1,], 'got the right array';
is ('a'..'a').raku, '"a".."a"', "stationary str .raku ..";
is ('a'..'a'), "a", 'got the right stationary string';

{
    my $x = 0;
    $x++ for (1..4).reverse;
    is $x, 4, '(1..4).reverse still turns into a list of four items';
    my $y = 0;
    $y++ for @( EVAL((1..4).reverse.raku) );
    is $y, 4, '(1..4).reverse.raku returns something useful';
}

# ACCEPTS and equals tests
{
    my $r = 1..5;
    ok(($r).ACCEPTS($r), 'accepts self');
    ok(($r).ACCEPTS(1..5), 'accepts same');
    ok($r ~~ $r, 'accepts self');
    ok($r ~~ 1..5, 'accepts same');
    # TODO check how to avoid "eager is", test passes but why?
    is($r, $r, "equals to self");
    my $s = 1..5;
    is($r, $s, "equals");
}


# Range in comparisons
ok((1..5).ACCEPTS(3), 'int in range');
ok(3 ~~ 1..5, 'int in range');
ok(3 !~~ 6..8, 'int not in range');

ok(('a'..'z').ACCEPTS('x'), 'str in range');
ok('x' ~~ 'a'..'z', 'str in range');
ok('x' !~~ 'a'..'c', 'str not in range');
ok(('aa'..'zz').ACCEPTS('ax'), 'str in range');
ok(('a'..'zz').ACCEPTS('ax'), 'str in range');

is(+(6..6), 1, 'numification');
is(+(6^..6), 0, 'numification');
is(+(6..^6), 0, 'numification');
is(+(6..^6.1), 1, 'numification');
is(+(6..8), 3, 'numification');
is(+(1^..10), 9, 'numification');
is(+(1..^10), 9, 'numification');
is(+(1^..^10), 8, 'numification');
is(+(10..9), 0, 'numification');
is(+(1.2..4), 3, 'numification');
is(+(1..^3.3), 3, 'numification');
is(+(2.3..3.1), 1, 'numification');
is(+Range, 0, 'type numification');

# immutability
{
    my $r = 1..5;

    for <push pop shift unshift append prepend> -> $method {
        throws-like { $r."$method"(42) }, X::Immutable,
          method   => $method,
          typename => 'Range',
          "range is immutable ($method)",
        ;
    }

    throws-like { $r.min = 2 }, X::Assignment::RO, "range.min ro";
    throws-like { $r.max = 4 }, X::Assignment::RO, "range.max ro";
    throws-like { $r.excludes-min = True }, X::Assignment::RO,
        "range.excludes-min ro";
    throws-like { $r.excludes-max = True }, X::Assignment::RO,
        "range.excludes-max ro";

    my $s = 1..5;
    is $r, $s, 'range has not changed';
}

# simple range
{
    my $r = 1 .. 5;
    is($r.min, 1, 'range.min');
    is($r.max, 5, 'range.max');
    is($r.bounds, (1,5), 'range.bounds');
}

# uneven ranges
{
    my $r = 1 .. 4.5;
    is($r.min, 1,   'range.min');
    is($r.max, 4.5, 'range.max');
    is($r.bounds, (1, 4.5), 'range.bounds');
}

# infinite ranges
{
    my $inf = -Inf..Inf;

    ok(42  ~~ $inf, 'positive integer matches -Inf..Inf');
    ok(.2  ~~ $inf, 'positive non-int matches -Inf..Inf');
    ok(-2  ~~ $inf, 'negative integer matches -Inf..Inf');
    ok(-.2 ~~ $inf, 'negative non-int matches -Inf..Inf');
}

# infinite ranges using Whatever
{
    my $inf = *..*;

    is($inf.min, -Inf, 'bottom end of *..* is -Inf (1)');
    is($inf.max, Inf, 'top end of *..* is Inf (1)');

    throws-like $inf.elems, X::Cannot::Lazy, :action<.elems>;

    ok(42  ~~ $inf, 'positive integer matches *..*');
    ok(.2  ~~ $inf, 'positive non-int matches *..*');
    ok(-2  ~~ $inf, 'negative integer matches *..*');
    ok(-.2 ~~ $inf, 'negative non-int matches *..*');
}

# https://github.com/Raku/old-issue-tracker/issues/674
# ranges constructed from parameters
{
    sub foo($a) { ~($a .. 5) };
    is(foo(5), '5', 'range constructed from parameter OK');
}

# ranges constructed from parameters, #2
{
    for 1 -> $i {
        for $i..5 -> $j { };
        # https://github.com/Raku/old-issue-tracker/issues/1014
        is($i, 1, 'Iter range from param doesnt modify param');
    }
}

{
    is((1..8)[*-1], 8, 'postcircumfix:<[ ]> on range works');
    is((1..8)[1,3], [2,4], 'postcircumfix:<[ ]> on range works');
}

{
    my @b = pick(*, 1..100);
    is @b.elems, 100, "pick(*, 1..100) returns the correct number of elements";
    is ~@b.sort, ~(1..100), "pick(*, 1..100) returns the correct elements";
    is ~@b.grep(Int).elems, 100, "pick(*, 1..100) returns Ints";

    @b = (1..100).pick(*);
    is @b.elems, 100, "pick(*, 1..100) returns the correct number of elements";
    is ~@b.sort, ~(1..100), "pick(*, 1..100) returns the correct elements";
    is ~@b.grep(Int).elems, 100, "pick(*, 1..100) returns Ints";

    isa-ok (1..100).pick, Int, "picking a single element from an range of Ints produces an Int";
    ok (1..100).pick ~~ 1..100, "picking a single element from an range of Ints produces one of them";

    isa-ok (1..100).pick(1), Seq, "picking 1 from an range of Ints produces a Seq";
    ok (1..100).pick(1)[0] ~~ 1..100, "picking 1 from an range of Ints produces one of them";

    my @c = (1..100).pick(2);
    isa-ok @c[0], Int, "picking 2 from an range of Ints produces an Int...";
    isa-ok @c[1], Int, "... and an Int";
    ok (@c[0] ~~ 1..100) && (@c[1] ~~ 1..100), "picking 2 from an range of Ints produces two of them";
    ok @c[0] != @c[1], "picking 2 from an range of Ints produces two distinct results";

    is (1..100).pick("25").elems, 25, ".pick works Str arguments";
    is pick("25", 1..100).elems, 25, "pick works Str arguments";
}

{
    my @b = pick(*, 'b' .. 'y');
    is @b.elems, 24, "pick(*, 'b' .. 'y') returns the correct number of elements";
    is ~@b.sort, ~('b' .. 'y'), "pick(*, 'b' .. 'y') returns the correct elements";
    is ~@b.grep(Str).elems, 24, "pick(*, 'b' .. 'y') returns Strs";

    @b = ('b' .. 'y').pick(*);
    is @b.elems, 24, "pick(*, 'b' .. 'y') returns the correct number of elements";
    is ~@b.sort, ~('b' .. 'y'), "pick(*, 'b' .. 'y') returns the correct elements";
    is ~@b.grep(Str).elems, 24, "pick(*, 'b' .. 'y') returns Strs";

    isa-ok ('b' .. 'y').pick, Str, "picking a single element from an range of Strs produces an Str";
    ok ('b' .. 'y').pick ~~ 'b' .. 'y', "picking a single element from an range of Strs produces one of them";

    isa-ok ('b' .. 'y').pick(1), Seq, "picking 1 from an range of Strs produces a Seq";
    ok ('b' .. 'y').pick(1)[0] ~~ 'b' .. 'y', "picking 1 from an range of Strs produces one of them";

    my @c = ('b' .. 'y').pick(2);
    isa-ok @c[0], Str, "picking 2 from an range of Strs produces an Str...";
    isa-ok @c[1], Str, "... and an Str";
    ok (@c[0] ~~ 'b' .. 'y') && (@c[1] ~~ 'b' .. 'y'), "picking 2 from an range of Strs produces two of them";
    ok @c[0] ne @c[1], "picking 2 from an range of Strs produces two distinct results";

    is ('b' .. 'y').pick("10").elems, 10, ".pick works Str arguments";
    is pick("10", 'b' .. 'y').elems, 10, "pick works Str arguments";
}

{
    my @b = roll(100, 1..100);
    is @b.elems, 100, "roll(100, 1..100) returns the correct number of elements";
    is ~@b.grep(1..100).elems, 100, "roll(100, 1..100) returns elements from 1..100";
    is ~@b.grep(Int).elems, 100, "roll(100, 1..100) returns Ints";

    @b = (1..100).roll(100);
    is @b.elems, 100, "roll(100, 1..100) returns the correct number of elements";
    is ~@b.grep(1..100).elems, 100, "roll(100, 1..100) returns elements from 1..100";
    is ~@b.grep(Int).elems, 100, "roll(100, 1..100) returns Ints";

    isa-ok (1..100).roll, Int, "rolling a single element from an range of Ints produces an Int";
    ok (1..100).roll ~~ 1..100, "rolling a single element from an range of Ints produces one of them";

    isa-ok (1..100).roll(1), Seq, "rolling 1 from an range of Ints produces a Seq";
    ok (1..100).roll(1)[0] ~~ 1..100, "rolling 1 from an range of Ints produces one of them";

    my @c = (1..100).roll(2);
    isa-ok @c[0], Int, "rolling 2 from an range of Ints produces an Int...";
    isa-ok @c[1], Int, "... and an Int";
    ok (@c[0] ~~ 1..100) && (@c[1] ~~ 1..100), "rolling 2 from an range of Ints produces two of them";

    is (1..100).roll("25").elems, 25, ".roll works Str arguments";
    is roll("25", 1..100).elems, 25, "roll works Str arguments";
}

{
    my @b = roll(100, 'b' .. 'y');
    is @b.elems, 100, "roll(100, 'b' .. 'y') returns the correct number of elements";
    is ~@b.grep('b' .. 'y').elems, 100, "roll(100, 'b' .. 'y') returns elements from b..y";
    is ~@b.grep(Str).elems, 100, "roll(100, 'b' .. 'y') returns Strs";

    @b = ('b' .. 'y').roll(100);
    is @b.elems, 100, "roll(100, 'b' .. 'y') returns the correct number of elements";
    is ~@b.grep('b' .. 'y').elems, 100, "roll(100, 'b' .. 'y') returns elements from b..y";
    is ~@b.grep(Str).elems, 100, "roll(100, 'b' .. 'y') returns Strs";

    isa-ok ('b' .. 'y').roll, Str, "rolling a single element from an range of Strs produces an Str";
    ok ('b' .. 'y').roll ~~ 'b' .. 'y', "rolling a single element from an range of Strs produces one of them";

    isa-ok ('b' .. 'y').roll(1), Seq, "rolling 1 from an range of Strs produces a Seq";
    ok ('b' .. 'y').roll(1)[0] ~~ 'b' .. 'y', "rolling 1 from an range of Strs produces one of them";

    my @c = ('b' .. 'y').roll(2);
    isa-ok @c[0], Str, "rolling 2 from an range of Strs produces an Str...";
    isa-ok @c[1], Str, "... and an Str";
    ok (@c[0] ~~ 'b' .. 'y') && (@c[1] ~~ 'b' .. 'y'), "rolling 2 from an range of Strs produces two of them";

    is ('b' .. 'y').roll("10").elems, 10, ".roll works Str arguments";
    is roll("10", 'b' .. 'y').elems, 10, "roll works Str arguments";
}

# Range.roll(*)/roll(N)/pick(N) with large number, from R#2090
{
  my $range = (1 +< 125) .. ( 1 +< 126 -1 );
  lives-ok { $range.pick(42) }, 'Range.pick(N) lives for vast range';
  lives-ok { $range.roll(42) }, 'Range.roll(N) lives for vast range';
  lives-ok { $range.roll(*).head(10) }, 'Range.roll(*) lives for vast range';
  lives-ok { ($range.roll xx *).head(10) }, '(Range.roll xx *) lives for vast range';
}

is join(':',grep 1..3, 0..5), '1:2:3', "ranges itemize or flatten lazily";

lives-ok({'A'..'a'}, "A..a range completes");
lives-ok({"\0".."~"}, "low ascii range completes");

# shifting and scaling intervals
{
    my $r = 1..10;
    is ($r + 5).gist, '6..15', "can shift a left .. range up";
    is (5 + $r).gist, '6..15', "can shift a right .. range up";
    is ($r * 2).gist, '2..20', "can scale a left .. range up";
    is (2 * $r).gist, '2..20', "can scale a right .. range up";
    is ($r - 1).gist, '0..9', "can shift a .. range down";
    is ($r / 2).gist, '0.5..5.0', "can scale a .. range down";

    $r = 1..^10;
    is ($r + 5).gist, '6..^15', "can shift a left ..^ range up";
    is (5 + $r).gist, '6..^15', "can shift a right ..^ range up";
    is ($r * 2).gist, '2..^20', "can scale a left ..^ range up";
    is (2 * $r).gist, '2..^20', "can scale a right ..^ range up";
    is ($r - 1).gist, '^9', "can shift a ..^ range down";
    is ($r / 2).gist, '0.5..^5.0', "can scale a ..^ range down";

    $r = 1^..10;
    is ($r + 5).gist, '6^..15', "can shift a left ^.. range up";
    is (5 + $r).gist, '6^..15', "can shift a right ^.. range up";
    is ($r * 2).gist, '2^..20', "can scale a left ^.. range up";
    is (2 * $r).gist, '2^..20', "can scale a right ^.. range up";
    is ($r - 1).gist, '0^..9', "can shift a ^.. range down";
    is ($r / 2).gist, '0.5^..5.0', "can scale a ^.. range down";

    $r = 1^..^10;
    is ($r + 5).gist, '6^..^15', "can shift a left ^..^ range up";
    is (5 + $r).gist, '6^..^15', "can shift a right ^..^ range up";
    is ($r * 2).gist, '2^..^20', "can scale a left ^..^ range up";
    is (2 * $r).gist, '2^..^20', "can scale a right ^..^ range up";
    is ($r - 1).gist, '0^..^9', "can shift a ^..^ range down";
    is ($r / 2).gist, '0.5^..^5.0', "can scale a ^..^ range down";
}

{
    sub test($range,$min,$max,$minbound,$maxbound) {
        subtest {
            plan 5;
            ok $range.is-int, "is $range.gist() an integer range";
            is $range.min, $min, "is $range.gist().min $min";
            is $range.max, $max, "is $range.gist().max $max";
            my ($low,$high) = $range.int-bounds;
            is  $low, $minbound, "is $range.gist().int-bounds[0] $minbound";
            is $high, $maxbound, "is $range.gist().int-bounds[1] $maxbound";
        }, "Testing min, max, int-bounds on $range.gist()";
    }

    test(     ^10,  0, 10,  0,  9);
    test(  -1..10, -1, 10, -1, 10);
    test( -1^..10, -1, 10,  0, 10);
    test( -1..^10, -1, 10, -1,  9);
    test(-1^..^10, -1, 10,  0,  9);
}

{
    ok 0 <= (^10).rand < 10, 'simple rand';
    ok 1 < (1..10).rand < 10, 'no borders excluded';
    ok 0.1 < (0.1^..0.3).rand <= 0.3, 'lower border excluded';
    throws-like ("a".."z").rand, Exception, 'cannot rand on string range';
}

{
    is (1..10).minmax,        '1 10',     "simple Range.minmax on Ints";
    is (3.5..4.5).minmax,     '3.5 4.5',  "simple Range.minmax on Rats";
    is (3.5e1..4.5e1).minmax, '35 45',    "simple Range.minmax on Reals";
    is ("a".."z").minmax,     'a z',      "simple Range.minmax on Strs";
    is (-Inf..Inf).minmax,    '-Inf Inf', "simple Range.minmax on Nums";
    is (^10).minmax,          '0 9',      "Range.minmax on Ints with exclusion";
    dies-ok { ^Inf .minmax },  "cannot have exclusions for minmax otherwise";
}

# https://github.com/Raku/old-issue-tracker/issues/4903
is-deeply Int.Range, -Inf^..^Inf, 'Int.range is -Inf^..^Inf';

# https://github.com/Raku/old-issue-tracker/issues/5553
is-deeply (eager (^10+5)/2), (2.5, 3.5, 4.5, 5.5, 6.5),
    'Rat range constructed with Range ops does not explode';

# https://github.com/Raku/old-issue-tracker/issues/5620
subtest '.rand does not generate value equal to excluded endpoints' => {
    plan 3;

    my $seen = 0;
    for ^10000 { $seen = 1 if (1..^(1+10e-15)).rand == 1+10e-15 };
    ok $seen == 0, '..^ range';

    $seen = 0;
    for ^10000 { $seen = 1 if (1^..(1+10e-15)).rand == 1 };
    ok $seen == 0, '^.. range';

    $seen = 0;
    for ^10000 {
        my $v = (1^..^(1+10e-15)).rand;
        $seen = 1 if $v == 1 or $v == 1+10e-15
    };
    ok $seen == 0, '^..^ range';
}

subtest 'out of range AT-POS' => {
    plan 7;
    throws-like { (^5)[*-9] }, X::OutOfRange, 'effective negative index throws';
    is-deeply (2..1)[^2], (Nil, Nil),
        'index larger than range returns Nil (Int range)';
    is-deeply (2.1..1.1)[^2], (Nil, Nil),
        'index larger than range returns Nil (Rat range)';
    is-deeply (2e0..1e0)[^2], (Nil, Nil),
        'index larger than range returns Nil (Num range)';

    my int $i2 = 2;
    my int $i5 = 5;
    is-deeply (2..1)[$i2, $i5], (Nil, Nil),
        'index larger than range returns Nil (Int range, native int index)';
    is-deeply (2.1..1.1)[$i2, $i5], (Nil, Nil),
        'index larger than range returns Nil (Rat range, native int index)';
    is-deeply (2e0..1e0)[$i2, $i5], (Nil, Nil),
        'index larger than range returns Nil (Num range, native int index)';
}

subtest 'Complex smartmatch against Range' => {
    my @false = [i, 1..10], [i, -2e300.Int..2e300.Int], [i, -2e300.Int..2e300.Int],
        [<0+0i>, 1..10], [i, 'a'..Inf], [i, 'a'..'z'];

    # these cases are true because the imaginary part is small enough that
    # we can convert these Complex into Real
    my @true  = [<0+0i>, -1..10], [<42+0i>, 10..50],
        [<42+0.0000000000000001i>, 40..50], [<42+0i>, 10e0..50e0];

    plan @false + @true;
    for @false -> $t {
        is-deeply ($t[0] ~~ $t[1]), False, "{$t[0].raku} ~~ {$t[1].raku}";
    }
    for @true -> $t {
        is-deeply ($t[0] ~~ $t[1]), True,  "{$t[0].raku} ~~ {$t[1].raku}";
    }
}

# https://irclog.perlgeek.de/perl6-dev/2017-03-16#i_14277938
subtest 'no .int-bounds for Infs and NaN as Range endpoints' => {
    my @ranges =  NaN.. NaN,  NaN..1, 1..NaN,   NaN..Inf,  NaN..-Inf,
                 -Inf..-Inf, -Inf..1, 1..-Inf, -Inf..NaN, -Inf.. Inf,
                  Inf.. Inf,  Inf..1, 1.. Inf,  Inf..NaN,  Inf.. Inf;
    plan 1 + @ranges;
    throws-like { .int-bounds }, Exception, "{.raku} throws" for @ranges;

    # https://github.com/rakudo/rakudo/commit/16ef21c162
    is-deeply (0..5.5).int-bounds, (0, 5),
        'we can get int-bounds from non-int range with `0` end-point';
}

# https://github.com/Raku/old-issue-tracker/issues/4297
subtest 'no floating point drifts in degenerate Ranges' => {
    plan 3;
    (NaN..NaN).map: {
        next unless $++ > 1050;
        is-deeply $_, NaN, 'NaN..NaN range keeps producing NaN ad infinitum';
        last;
    }
    (-Inf..0).map: {
        next unless $++ > 1050;
        is-deeply $_, -Inf, '-Inf..Inf range keeps producing -Inf ad infinitum';
        last;
    }
    is-deeply (Inf..0).elems, 0, 'Inf..0 Range has zero elems'
}

# https://github.com/rakudo/rakudo/issues/2517
{
    my @a = "1"..9;
    is-deeply @a, ["1","2","3","4","5","6","7","8","9"], 'did we get strings';
}

# https://github.com/rakudo/rakudo/issues/5222
{
    for 1..1, 1^..2, 1..^2, 1^..^3, "a".."a", 1..* -> $range {
        is-deeply $range.Bool, True, "$range.raku().Bool is True";
    }
    for 1..0, 1^..1, 1..^1, 1^..^2, "b".."a", 1..-Inf -> $range {
        todo("fixed in 6.e");
        is-deeply $range.Bool, False, "$range.raku().Bool is False";
    }
}

# https://github.com/rakudo/rakudo/issues/3596
{
    is-deeply (Inf .. Inf)[^5], (Nil, Nil, Nil, Nil, Nil),
      'Inf .. Inf produces Nils';
    is-deeply (Inf .. NaN)[^5], (Nil, Nil, Nil, Nil, Nil),
      'Inf .. NaN produces Nils';
}

# https://github.com/rakudo/rakudo/issues/3637
{
    is-deeply +((5..2).reverse), 0, '+((5..2).reverse)';
    is-deeply +(5..-∞),          0, '+(5..-∞)';
    is-deeply +(-∞..-∞),         Inf, '+(-∞..-∞)';
    is-deeply +(∞..∞),           Inf, '+(∞..∞)';
}

# https://github.com/rakudo/rakudo/issues/5791
{
    my $r := 2..6;
    is-deeply $r.min(:k),   0,             '2..6 min :k';
    is-deeply $r.min(:!k),  2,             '2..6 min :!k';
    is-deeply $r.min(:kv),  (0,2),         '2..6 min :kv';
    is-deeply $r.min(:!kv), 2,             '2..6 min :!kv';
    is-deeply $r.min(:p),   Pair.new(0,2), '2..6 min :p';
    is-deeply $r.min(:!p),  2,             '2..6 min :!p';

    is-deeply $r.max(:k),   4,             '2..6 max :k';
    is-deeply $r.max(:!k),  6,             '2..6 max :!k';
    is-deeply $r.max(:kv),  (4,6),         '2..6 max :kv';
    is-deeply $r.max(:!kv), 6,             '2..6 max :!kv';
    is-deeply $r.max(:p),   Pair.new(4,6), '2..6 max :p';
    is-deeply $r.max(:!p),  6,             '2..6 max :!p';

    is-deeply min($r,:k),   0,             'min 2..6 :k';
    is-deeply min($r,:!k),  2,             'min 2..6 :!k';
    is-deeply min($r,:kv),  (0,2),         'min 2..6 :kv';
    is-deeply min($r,:!kv), 2,             'min 2..6 :!kv';
    is-deeply min($r,:p),   Pair.new(0,2), 'min 2..6 :p';
    is-deeply min($r,:!p),  2,             'min 2..6 :!p';

    is-deeply max($r,:k),   4,             'max 2..6 :k';
    is-deeply max($r,:!k),  6,             'max 2..6 :!k';
    is-deeply max($r,:kv),  (4,6),         'max 2..6 :kv';
    is-deeply max($r,:!kv), 6,             'max 2..6 :!kv';
    is-deeply max($r,:p),   Pair.new(4,6), 'max 2..6 :p';
    is-deeply max($r,:!p),  6,             'max 2..6 :!p';

    my $i := 2..Inf;
    is-deeply $i.min(:k),   0,             '2..Inf min :k';
    is-deeply $i.min(:!k),  2,             '2..Inf min :!k';
    is-deeply $i.min(:kv),  (0,2),         '2..Inf min :kv';
    is-deeply $i.min(:!kv), 2,             '2..Inf min :!kv';
    is-deeply $i.min(:p),   Pair.new(0,2), '2..Inf min :p';
    is-deeply $i.min(:!p),  2,             '2..Inf min :!p';

    is-deeply $i.max(:k),   Inf,               '2..Inf max :k';
    is-deeply $i.max(:!k),  Inf,               '2..Inf max :!k';
    is-deeply $i.max(:kv),  (Inf,Inf),         '2..Inf max :kv';
    is-deeply $i.max(:!kv), Inf,               '2..Inf max :!kv';
    is-deeply $i.max(:p),   Pair.new(Inf,Inf), '2..Inf max :p';
    is-deeply $i.max(:!p),  Inf,               '2..Inf max :!p';

    is-deeply min($i,:k),   0,             '2..Inf min :k';
    is-deeply min($i,:!k),  2,             '2..Inf min :!k';
    is-deeply min($i,:kv),  (0,2),         '2..Inf min :kv';
    is-deeply min($i,:!kv), 2,             '2..Inf min :!kv';
    is-deeply min($i,:p),   Pair.new(0,2), '2..Inf min :p';
    is-deeply min($i,:!p),  2,             '2..Inf min :!p';

    is-deeply max($i,:k),   Inf,               '2..Inf max :k';
    is-deeply max($i,:!k),  Inf,               '2..Inf max :!k';
    is-deeply max($i,:kv),  (Inf,Inf),         '2..Inf max :kv';
    is-deeply max($i,:!kv), Inf,               '2..Inf max :!kv';
    is-deeply max($i,:p),   Pair.new(Inf,Inf), '2..Inf max :p';
    is-deeply max($i,:!p),  Inf,               '2..Inf max :!p';
}

# vim: expandtab shiftwidth=4
