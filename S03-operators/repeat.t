use Test;
use lib $*PROGRAM.parent(2).add("packages/Test-Helpers");
use Test::Util;

=begin description

Repeat operators for strings and lists

=end description

plan 63;

#L<S03/Changes to Perl operators/"x (which concatenates repetitions of a string to produce a single string">

is('a' x 3, 'aaa', 'string repeat operator works on single character');
is('ab' x 4, 'abababab', 'string repeat operator works on multiple character');
is(1 x 5, '11111', 'number repeat operator works on number and creates string');
is('' x 6, '', 'repeating an empty string creates an empty string');
is('a' x 0, '', 'repeating zero times produces an empty string');
is('a' x -1, '', 'repeating negative times produces an empty string');
is('a' x 2.2, 'aa', 'repeating with a fractional number coerces to Int');
# https://github.com/Raku/old-issue-tracker/issues/2878
is('str' x Int, '', 'x with Int type object');
# https://github.com/Raku/old-issue-tracker/issues/4410
{
    throws-like ｢'a' x -NaN｣, X::Numeric::CannotConvert,
        'repeating with -NaN dies';
    throws-like ｢'a' x NaN｣, X::Numeric::CannotConvert,
        'repeating with NaN dies';
    throws-like ｢'a' x -Inf｣, X::Numeric::CannotConvert,
        'repeating with -Inf dies';

    isa-ok('a' x *, WhateverCode, 'repeating with * is a WhateverCode');

    throws-like ｢'a' xx -NaN｣, X::Numeric::CannotConvert,
        'list repeating with -NaN fails';
    throws-like ｢'a' xx NaN｣, X::Numeric::CannotConvert,
        'list repeating with NaN fails';
    throws-like ｢'a' xx -Inf｣, X::Numeric::CannotConvert,
        'list repeating with -Inf fails';
}

#L<S03/Changes to Perl operators/"and xx (which creates a list of repetitions of a list or item)">
my @foo = 'x' xx 10;
is(@foo[0], 'x', 'list repeat operator created correct array');
is(@foo[9], 'x', 'list repeat operator created correct array');
is(+@foo, 10, 'list repeat operator created array of the right size');

lives-ok { my @foo2 = Mu xx 2; }, 'can repeat Mu';
my @foo3 = flat (1, 2) xx 2;
is(@foo3[0], 1, 'can repeat lists');
is(@foo3[1], 2, 'can repeat lists');
is(@foo3[2], 1, 'can repeat lists');
is(@foo3[3], 2, 'can repeat lists');

my @foo4 = 'x' xx 0;
is(+@foo4, 0, 'repeating zero times produces an empty list');

my @foo5 = 'x' xx -1;
is(+@foo5, 0, 'repeating negative times produces an empty list');

my @foo_2d = [1, 2] xx 2; # should create 2d
is(@foo_2d[1], [1, 2], 'can create 2d arrays'); # creates a flat 1d array
# Wrong/unsure: \(1, 2) does not create a ref to the array/list (1,2), but
# returns a list containing two references, i.e. (\1, \2).
#my @foo_2d2 = \(1, 2) xx 2; # just in case it's a parse bug
#is(@foo_2d[1], [1, 2], 'can create 2d arrays (2)'); # creates a flat 1d array

# test x=
my $twin = 'Lintilla';
ok($twin x= 2, 'operator x= for string works');
is($twin, 'LintillaLintilla', 'operator x= for string repeats correct');

# test that xx actually creates independent items
#?DOES 4
{
    my @a = 'a' xx 3;
    is @a.join('|'), 'a|a|a', 'basic infix:<xx>';
    @a[0] = 'b';
    is @a.join('|'), 'b|a|a', 'change to one item left the others unchanged';

    my @b = flat <x y> xx 3;
    is @b.join('|'), 'x|y|x|y|x|y', 'basic sanity with <x y> xx 3';
    @b[0] = 'z';
    @b[3] = 'a';
    is @b.join('|'), 'z|y|x|a|x|y', 'change to one item left the others unchanged';
}


# https://github.com/Raku/old-issue-tracker/issues/1970
# tests for non-number values on rhs of xx
#?DOES 2
{
    # make sure repeat numifies rhs, but respects whatever
    my @a = <a b c>;
    is(("a" xx @a).join('|'), 'a|a|a', 'repeat properly numifies rhs');

    my @b = flat <a b c> Z (1 xx *);
    is(@b.join('|'), 'a|1|b|1|c|1', 'xx understands Whatevers');
}

# https://github.com/Raku/old-issue-tracker/issues/2517
# xxx now thunks the LHS
{
    my @a = ['a'] xx 3;
    @a[0][0] = 'b';
    is @a[1][0], 'a', 'xx thunks the LHS';
}

# https://github.com/Raku/old-issue-tracker/issues/3684
{
    is 'ABC'.ords xx 2, (65,66,67,65,66,67), "xx works on a lazy list";
}

# https://github.com/Raku/old-issue-tracker/issues/4409
is ('foo' xx Inf)[8], 'foo', 'xx Inf';

ok (42 xx *).is-lazy, "xx * is lazy";
ok !(42 xx 3).is-lazy, "xx 3 is not lazy";

# https://github.com/Raku/old-issue-tracker/issues/4733
is ((2, 4, 6) xx 2).elems, 2, 'xx retains structure with list on LHS';
is ((2, 4, 6) xx 2).flat.elems, 6, 'xx retained list structure can be flattened with .flat';
is ((2, 4, 6).Seq xx 2).elems, 2, 'xx retains structure with Seq on LHS';
is ((2, 4, 6).Seq xx 2).flat.elems, 6, 'xx retained Seq structure can be flattened with .flat';
is ((2, 4, 6) xx *)[^2], ((2, 4, 6), (2, 4, 6)),
    'xx * retains structure with list on LHS';
is ((2, 4, 6).Seq xx *)[^2], ((2, 4, 6), (2, 4, 6)),
    'xx * retains structure with Seq on LHS';

# https://github.com/Raku/old-issue-tracker/issues/5368
{
    my $is-sunk = 0;
    my class A { method sink() { $is-sunk++ } };
    my @a = A.new xx 10;
    is $is-sunk, 0, 'xx does not sink';
}

{ # coverage; 2016-10-11
    throws-like { infix:<xx>() }, Exception, 'xx with no args throws';
    is-deeply infix:<xx>(2), 2, 'xx with single arg is identity';

    is-deeply infix:<xx>({$++;}, *)[^200],  (|^200).Seq,
        '(& xx *) works as & xx Inf';
    is-deeply infix:<xx>({$++;}, Inf)[^20], (|^20).Seq,
        '(& xx Inf) works as & xx Inf';
    is-deeply infix:<xx>({$++;}, 4e0)[^4],  (|^4).Seq,
        '(& xx Num) works as & xx Int';
}

# https://github.com/Raku/old-issue-tracker/issues/5753
{
    throws-like { 'a' x 'b' }, X::Str::Numeric, 'x does not silence failures';
    is-deeply 'a' x Int, '', 'type objects get interpreted as 0 iterations';
}

# https://github.com/Raku/old-issue-tracker/issues/5855
{
    throws-like ｢rand xx '123aaa'｣, X::Str::Numeric,
        'Failures in RHS of xx explode (callable LHS)';
    throws-like ｢42   xx '123aaa'｣, X::Str::Numeric,
        'Failures in RHS of xx explode (Int LHS)';
}

# https://github.com/Raku/old-issue-tracker/issues/5864
warns-like { 'x' x Int }, *.contains('uninitialized' & 'numeric'),
    'using an unitialized value in repeat count throws';

# https://github.com/Raku/old-issue-tracker/issues/6028
is-deeply (|() xx *)[^5], (Nil, Nil, Nil, Nil, Nil),
    'empty slip with xx * works';

## Ensure that when the repeat operator is used, a normalized string is created
# https://github.com/Raku/old-issue-tracker/issues/6412
{
    is-deeply (0x0F75.chr x 2), "\x[0F75,0F75]", "Repeat operator keeps text normalized (normalization + canonical combining class reordering)";
    #?rakudo.jvm todo "NFG or normalization not supported on JVM"
    is-deeply (0x0F75.chr x 2).ords, (0xF71, 0xF71, 0xF74, 0xF74), "Repeat operator keeps text normalized (normalization + canonical combining class reordering)";
}

# https://github.com/Raku/old-issue-tracker/issues/3348
{
    my @result = gather {
        for ^2 { my @b = 1 xx 4; my $ = take (@b.shift xx 2) xx 2; Nil }
    }
    is-deeply @result.map(*.list).list, (((1, 1), (1, 1)), ((1, 1), (1, 1))),
        'Nested xx in for-loop';
}

# https://github.com/Raku/old-issue-tracker/issues/6129
{
    my $y = 25;
    my $z = $y xx 1;
    $y = '♥';
    is $z, 25, 'xx does not keep containers around';
}

# https://github.com/Raku/old-issue-tracker/issues/4523
# https://github.com/rakudo/rakudo/issues/1708
subtest 'sunk, plain value `xx` sink cheaply' => {
    plan +my @tests
    := {seq => 42 xx 2⁹⁹⁹⁹⁹,     v => '2⁹⁹⁹⁹⁹',     count => 2⁹⁹⁹⁹⁹    },
       {seq => 42 xx 9999999999, v => '9999999999', count => 9999999999},
       {seq => 42 xx 2 ** 62,    v => '2 ** 62',    count => 2 ** 62   },
       {seq => 42 xx ∞,          v => '∞',          count => ∞         },
       {seq => 42 xx Inf,        v => 'Inf',        count => ∞         },
       {seq => 42 xx *,          v => '*',          count => ∞         };

    for @tests -> \t {
        subtest t.<v> => {
            plan 3;
            with t.<seq>.iterator {
                .can('bool-only')
                    ?? is-deeply .bool-only, True, 'bool-only gives true'
                    !! skip '.bool-only not implemented';
                .can('count-only')
                    ?? is-deeply .count-only, t.<count>, 'count-only is right'
                    !! skip '.count-only not implemented';
                .sink-all;
                pass 'sinking did not "hang"';
            }
        }
    }
}

# https://github.com/rakudo/rakudo/issues/3660
{
    my $a = 66666;
    my $b = 'a' x $a;
    is-deeply ('a' ~ $b).chars, $a + 1, 'repetition + concatenation lives and gives correct .chars';
}

# vim: expandtab shiftwidth=4
