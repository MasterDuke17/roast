use Test;
use lib $*PROGRAM.parent(2).add("packages/Test-Helpers");
use Test::Util;

plan 191;

# L<S05/Substitution/>

my $str = 'hello';

is $str.subst(/h/,'f'),       'fello', 'We can use subst';
is $str,                      'hello', '.. withouth side effect';

is $str.subst('h','f'),       'fello', '.. or using Str as pattern';
is $str.subst('.','f'),       'hello', '.. with literal string matching';

my $i=0;
is $str.subst(/l/,{$i++}),    'he0lo', 'We can have a closure as replacement';
is $str.=subst(/l/,'i'),      'heilo', '.. and with the .= modifier';
is $str,                      'heilo', '.. it changes the receiver';

is 'hello'.subst('e', 3),     'h3llo', 'non-Str replacement works for string form too';

# not sure about this. Maybe '$1$0' should work.

$/ = ['nope'];
is 'a'.subst(/(.)/,"$0"), 'nope',     '.. bare strings cannot see $/ because they are evaluated first';
is 'a'.subst(/(.)/,{$0~$0}),'aa',     '.. you must wrap it in a closure to delay evaluation';
is '12'.subst(/(.)(.)/,{$/*2}),'24', '.. and do nifty things in closures';

# https://github.com/Raku/old-issue-tracker/issues/3012
{
    $/ = ('-');   #  parens to avoid looking like a P5 irs directive
    is 'a'.subst("a","b"), 'b', '"a".subst("a", "b") is "b"';
    is $/,                 '-', '$/ is left untouched';

    is 'a'.subst(/a/,"b"), 'b', '"a".subst(/a/, "b") is "b"';
    is $/,                 'a', '$/ matched "a"';

    is 'a'.subst(/x/,"y"), 'a', '"a".subst(/x/, "y") is "a"';
    nok $/,                     '$/ is a falsey';

    $_ = 'a';
    is s/a/b/,             'a', '$_ = "a"; s/a/b/ is "a"';
    is $/,                 'a', '$/ matched "a"';

    $_ = 'a';
    nok s/x/y/,                 '$_ = "a"; s/x/y/ is a falsey';
    nok $/,                     '$/ is a falsey';
}

{
    is 'a b c d'.subst(/\w/, 'x', :g),      'x x x x', '.subst and :g';
    is 'a b c d'.subst(/\w/, 'x', :global), 'x x x x', '.subst and :global';
    is 'a b c d'.subst(/\w/, 'x', :x(0)),   'a b c d', '.subst and :x(0)';
    is 'a b c d'.subst(/\w/, 'x', :x(1)),   'x b c d', '.subst and :x(1)';
    is 'a b c d'.subst(/\w/, 'x', :x(2)),   'x x c d', '.subst and :x(2)';
    is 'a b c d'.subst(/\w/, 'x', :x(3)),   'x x x d', '.subst and :x(3)';
    is 'a b c d'.subst(/\w/, 'x', :x(4)),   'x x x x', '.subst and :x(4)';
    is 'a b c d'.subst(/\w/, 'x', :x(5)),   'a b c d', '.subst and :x(5)';
    is 'a b c d'.subst(/\w/, 'x', :x(*)),   'x x x x', '.subst and :x(*)';

    is 'a b c d'.subst(/\w/, 'x', :x(0..1)), 'x b c d', '.subst and :x(0..1)';
    is 'a b c d'.subst(/\w/, 'x', :x(1..3)), 'x x x d', '.subst and :x(0..3)';
    is 'a b c d'.subst(/\w/, 'x', :x(3..5)), 'x x x x', '.subst and :x(3..5)';
    is 'a b c d'.subst(/\w/, 'x', :x(5..6)), 'a b c d', '.subst and :x(5..6)';
    is 'a b c d'.subst(/\w/, 'x', :x(3..2)), 'a b c d', '.subst and :x(3..2)';

    # string pattern versions
    is 'a a a a'.subst('a', 'x', :g),      'x x x x', '.subst (str pattern) and :g';
    is 'a a a a'.subst('a', 'x', :x(0)),   'a a a a', '.subst (str pattern) and :x(0)';
    is 'a a a a'.subst('a', 'x', :x(1)),   'x a a a', '.subst (str pattern) and :x(1)';
    is 'a a a a'.subst('a', 'x', :x(2)),   'x x a a', '.subst (str pattern) and :x(2)';
    is 'a a a a'.subst('a', 'x', :x(3)),   'x x x a', '.subst (str pattern) and :x(3)';
    is 'a a a a'.subst('a', 'x', :x(4)),   'x x x x', '.subst (str pattern) and :x(4)';
    is 'a a a a'.subst('a', 'x', :x(5)),   'a a a a', '.subst (str pattern) and :x(5)';
    is 'a a a a'.subst('a', 'x', :x(*)),   'x x x x', '.subst (str pattern) and :x(*)';

    is 'a a a a'.subst('a', 'x', :x(0..1)), 'x a a a', '.subst (str pattern) and :x(0..1)';
    is 'a a a a'.subst('a', 'x', :x(1..3)), 'x x x a', '.subst (str pattern) and :x(0..3)';
    is 'a a a a'.subst('a', 'x', :x(3..5)), 'x x x x', '.subst (str pattern) and :x(3..5)';
    is 'a a a a'.subst('a', 'x', :x(5..6)), 'a a a a', '.subst (str pattern) and :x(5..6)';
    is 'a a a a'.subst('a', 'x', :x(3..2)), 'a a a a', '.subst (str pattern) and :x(3..2)';
}


# :nth
{
    # https://github.com/Raku/old-issue-tracker/issues/4475
    throws-like '"a b c d".subst(/\w/, "x", :nth(0))', Exception, message => rx/nth/;
    is 'a b c d'.subst(/\w/, 'x', :nth(1)), 'x b c d', '.subst and :nth(1)';
    is 'a b c d'.subst(/\w/, 'x', :nth(2)), 'a x c d', '.subst and :nth(2)';
    is 'a b c d'.subst(/\w/, 'x', :nth(3)), 'a b x d', '.subst and :nth(3)';
    is 'a b c d'.subst(/\w/, 'x', :nth(4)), 'a b c x', '.subst and :nth(4)';
    is 'a b c d'.subst(/\w/, 'x', :nth(5)), 'a b c d', '.subst and :nth(5)';

    # string pattern versions
    # https://github.com/Raku/old-issue-tracker/issues/4475
    throws-like '"a a a a".subst("a", "x", :nth(0))', Exception, message => rx/nth/;
    is 'a a a a'.subst('a', 'x', :nth(1)), 'x a a a', '.subst (str pattern) and :nth(1)';
    is 'a a a a'.subst('a', 'x', :nth(2)), 'a x a a', '.subst (str pattern) and :nth(2)';
    is 'a a a a'.subst('a', 'x', :nth(3)), 'a a x a', '.subst (str pattern) and :nth(3)';
    is 'a a a a'.subst('a', 'x', :nth(4)), 'a a a x', '.subst (str pattern) and :nth(4)';
    is 'a a a a'.subst('a', 'x', :nth(5)), 'a a a a', '.subst (str pattern) and :nth(5)';
}

# combining :nth with :x
{
    is 'a b c d e f g h'.subst(/\w/, 'x', :nth(1,2,3,4), :x(3)),
       'x x x d e f g h',
       '.subst with :nth(1,2,3,4)) and :x(3)';

    is 'a b c d e f g h'.subst(/\w/, 'x', :nth(2,4,6,8), :x(2)),
       'a x c x e f g h',
       '.subst with :nth(2,4,6,8) and :x(2)';

    throws-like '"a b c d e f g h".subst(/\w/, "x", :nth(2, 4, 1, 6), :x(3))',
       Exception,
       '.subst with :nth(2) and :x(3)';
}

{
    # :p
    is 'a b c d e f g h'.subst(/\w/, 'x', :p(0)),
       'x b c d e f g h',
       '.subst with :p(0)';

    is 'a b c d e f g h'.subst(/\w/, 'x', :p(1)),
       'a b c d e f g h',
       '.subst with :p(1)';

    is 'a b c d e f g h'.subst(/\w/, 'x', :p(2)),
       'a x c d e f g h',
       '.subst with :p(2)';

    # :p and :g
    is 'a b c d e f g h'.subst(/\w/, 'x', :p(0), :g),
       'x x x x x x x x',
       '.subst with :p(0) and :g';

    is 'a b c d e f g h'.subst(/\w/, 'x', :p(1), :g),
       'a b c d e f g h',
       '.subst with :p(1) and :g';

    is 'a b c d e f g h'.subst(/\w/, 'x', :p(2), :g),
       'a x x x x x x x',
       '.subst with :p(2) and :g';
}

{
    # :c
    is 'a b c d e f g h'.subst(/\w/, 'x', :c(0)),
       'x b c d e f g h',
       '.subst with :c(0)';

    is 'a b c d e f g h'.subst(/\w/, 'x', :c(1)),
       'a x c d e f g h',
       '.subst with :c(1)';

    is 'a b c d e f g h'.subst(/\w/, 'x', :c(2)),
       'a x c d e f g h',
       '.subst with :c(2)';

    # :c and :g
    is 'a b c d e f g h'.subst(/\w/, 'x', :c(0), :g),
       'x x x x x x x x',
       '.subst with :c(0) and :g';

    is 'a b c d e f g h'.subst(/\w/, 'x', :c(1), :g),
       'a x x x x x x x',
       '.subst with :c(1) and :g';

    is 'a b c d e f g h'.subst(/\w/, 'x', :c(2), :g),
       'a x x x x x x x',
       '.subst with :c(2) and :g';

    # :c and :nth(3, 4)
    is 'a b c d e f g h'.subst(/\w/, 'x', :c(0), :nth(3, 4)),
       'a b x x e f g h',
       '.subst with :c(0) and :nth(3, 4)';

    is 'a b c d e f g h'.subst(/\w/, 'x', :c(1), :nth(3, 4)),
       'a b c x x f g h',
       '.subst with :c(1) and :nth(3, 4)';

    is 'a b c d e f g h'.subst(/\w/, 'x', :c(2), :nth(3, 4)),
       'a b c x x f g h',
       '.subst with :c(2) and :nth(3, 4)';
}

{
    my $s = "ZBC";
    my @a = ("A", 'ZBC');

    $_ = q{Now I know my abc's};

    is +s:g/Now/Wow/, 1, 'Constant substitution succeeds and returns correct count';
    is($_, q{Wow I know my abc's}, 'Constant substitution produces correct result');

    isa-ok s:global:i/ABC/$s/.WHAT, List, 'Global scalar substitution succeeds and returns a List';
    is($_, q{Wow I know my ZBC's}, 'Scalar substitution produces correct result');

    isa-ok s/BC/@a[]/.WHAT, Match, 'Single list replacement succeeds and returns a Match';
    is($_, q{Wow I know my ZA ZBC's}, 'List replacement produces correct result');

    dies-ok { 'abc' ~~ s/b/g/ },
            "can't modify string literal (only variables)";
}

# L<S05/Modifiers/The :s modifier is considered sufficiently important>
# https://github.com/Raku/old-issue-tracker/issues/4764
# also RT #126679
{
    dies-ok {"a b c" ~~ ss/a b c/x y z/}, 'Cannot ss/// string literal';

    $_ = "a\nb\tc d";
    #?rakudo.jvm 2 skip 'samemark NYI'
    ok s:ss/a b c d/w x y z/, 'successful s:ss substitution returns truthy';
    is $_, "w\nx\ty z", 's:ss/.../.../ preserves whitespace';

    $_ = "a\nb\tc d";
    # note, the ss here implies :samespace, not just :sigspace
    #?rakudo.jvm 2 skip 'samemark NYI'
    ok ss/a b c d/w x y z/, 'successful ss substitution returns truthy';
    # https://github.com/Raku/old-issue-tracker/issues/3275
    is $_, "w\nx\ty z", 'ss/.../.../ preserves whitespace';

    $_ = "a\nb\tc d";
    #?rakudo.jvm 2 skip 'samemark NYI'
    ok s:s/a b c d/w x y z/, 'successful s:s substitution returns truthy';
    is $_, "w x y z", 's:s/.../.../ does not preserve whitespace';


    $_ = "A\nb\tc D";
    ok s:ss:ii/a B c D/w x y z/, 'successful s:ss:ii substitution returns truthy';
    is $_, "W\nx\ty Z", 's:ss:ii/.../.../ preserves whitespace and case';

    $_ = "A\nb\tC d";
    #?rakudo.jvm 2 skip 'samemark NYI'
    ok ss:i/A B c d/w x y z/, 'successful ss:i substitution returns truthy';
    # https://github.com/Raku/old-issue-tracker/issues/3275
    is $_, "w\nx\ty z", 'ss:i/.../.../ preserves whitespace';

    $_ = "A\nb\tC D";
    ok s:s:ii/A B c D/w x y z/, 'successful s:s:ii substitution returns truthy';
    is $_, "W x Y Z", 's:s:ii/.../.../ does not preserve whitespace but preserves case';


    $_ = "Ä\nb\tć D";
    # https://github.com/Raku/old-issue-tracker/issues/4454
    #?rakudo.jvm 2 todo 'RT #125753'
    ok s:ss:ii:mm/a ḇ?   c D/w x y z/, 'successful s:ss:ii:mm substitution returns truthy';
    is $_, "Ẅ\nx\tý Z", 's:ss:ii:mm/.../.../ preserves whitespace, case, and marks';

    $_ = "a\nḇ\tĆ d";
    # https://github.com/Raku/old-issue-tracker/issues/4454
    #?rakudo.jvm 2 todo 'RT #125753'
    ok ss:i:m/Å b C d/w x y z/, 'successful ss substitution returns truthy';
    # https://github.com/Raku/old-issue-tracker/issues/3275
    is $_, "w\nx̱\tý z", 'ss/.../.../ preserves whitespace';

    $_ = "Å\nḇ\tć d";
    # https://github.com/Raku/old-issue-tracker/issues/4454
    #?rakudo.jvm 2 todo 'RT #125753'
    ok s:s:ii:mm/a  B+  c   D/w x y z/, 'successful s:s substitution returns truthy';
    is $_, "W̊ x̱ ý z", 's:s/.../.../ does not preserve whitespace but preserves case and marks';

}

#L<S05/Substitution/As with Perl, a bracketing form is also supported>
{
    my $a = 'abc';
    ok $a ~~ s[b] = 'de', 's[...] = ... returns true on success';
    is $a, 'adec', 'substitution worked';

    $a = 'abc';
    nok $a ~~ s[d] = 'de', 's[...] = ... returns false on failure';
    is $a, 'abc', 'failed substitutions leaves string unchanged';
}

{
    throws-like '$_ = "a"; s:unkonwn/a/b/', X::Syntax::Regex::Adverb,
        's/// dies on unknown adverb';
    throws-like '$_ = "a"; s:overlap/a/b/', X::Syntax::Regex::Adverb,
        ':overlap does not make sense on s///';
}

# note that when a literal is passed to 'given', $_ is bound read-only
{
    given my $x = 'abc' {
        ok (s[b] = 'de'), 's[...] = ... returns true on success';
        is $_, 'adec', 'substitution worked';
    }

    given my $y = 'abc' {
        s[d] = 'foo';
        is $_, 'abc', 'failed substitutions leaves string unchanged';
    }
}

{
    my $x = 'foobar';
    is +($x ~~ s:g[o] = 'u'), 2, 's:global[..] = returns correct count';
    is $x, 'fuubar', 'and the substition worked';
}

{
    $_ = 'a b c';
    s[\w] = uc($/);
    is $_, 'A b c', 'can use $/ on the RHS';

    $_ = 'a b c';
    s[(\w)] = uc($0);
    is $_, 'A b c', 'can use $0 on the RHS';

    $_ = 'a b c';
    is +(s:g[ (\w) ] = $0 x 2), 3, 's:g[] returns proper count of matches';
    is $_, 'aa bb cc', 's:g[...] and captures work together well';
}

{
    my $x = 'ABCD';
    $x ~~ s:x(2)/<.alpha>/x/;
    is $x, 'xxCD', 's:x(2)';
}

# s///
{
    my $x = 'ooooo';
    ok $x ~~ s:1st/./X/,    's:1st return value';
    is $x,  'Xoooo',        's:1st side effect';

    $x    = 'ooooo';
    ok $x ~~ s:2nd/./X/,    's:2nd return value';
    is $x,  'oXooo',        's:2nd side effect';

    $x    = 'ooooo';
    ok $x ~~ s:3rd/./X/,    's:3rd return value';
    is $x,  'ooXoo',        's:3rd side effect';

    $x    = 'ooooo';
    ok $x ~~ s:4th/./X/,    's:4th return value';
    is $x,  'oooXo',        's:4th side effect';

    $x    = 'ooooo';
    ok $x ~~ s:nth(5)/./X/, 's:nth(5) return value';
    is $x,  'ooooX',        's:nth(5) side effect';

    $x    = 'ooooo';
    nok $x ~~ s:nth(6)/./X/, 's:nth(6) return value';
    is $x,  'ooooo',        's:nth(6) no side effect';
}

# s///
{
    my $x = 'ooooo';
    $x ~~ s:x(2):nth(1,3)/o/A/;
    is $x,  'AoAoo', 's:x(2):nth(1,3) works in combination';

    $x = 'ooooo';
    $x ~~ s:2x:nth(1,3)/o/A/;
    is $x,  'AoAoo', 's:2x:nth(1,3) works in combination';
}

# https://github.com/Raku/old-issue-tracker/issues/2351
# s// with other separators
{
    my $x = 'abcde';
    $x ~~ s!bc!zz!;
    is $x, 'azzde', '! separator';
}

#L<S05/Substitution/Any scalar assignment operator may be used>
{
    given 'a 2 3' -> $_ is copy {
        ok (s[\d] += 5), 's[...] += 5 returns True';
        is $_, 'a 7 3', 's[...] += 5 gave right result';
    }
    given 'a b c' -> $_ is copy {
        s:g[\w] x= 2;
        is $_, 'aa bb cc', 's:g[..] x= 2 worked';
    }
}

{
    multi sub infix:<fromplus>(Match $a, Int $b) {
        $a.from + $b
    }

    given 'a b c' -> $_ is copy {
        ok (s:g[\w] fromplus= 3), 's:g[...] customop= returned True';
        is $_, '3 5 7', '... and got right result';
    }
}

# https://github.com/Raku/old-issue-tracker/issues/1274
{
    sub s { 'sub s' }
    $_ = "foo";
    #?rakudo.jvm skip 'samemark NYI'
    ok s:s,foo,bar, , 's with colon is always substitution';
    is s(), 'sub s', 'can call sub s as "s()"';
    is s, 'sub s', 'can call sub s as "s"';
    $_ = "foo";
    #?rakudo.jvm skip 'samemark NYI'
    ok ss (foo) = 'bar', 'bare ss is substitution before whitespace then parens';
}

# Test for :samecase
{
    is 'The foo and the bar'.subst('the', 'that', :samecase), 'The foo and that bar', '.substr and :samecase (1)';
    is 'The foo and the bar'.subst('the', 'That', :samecase), 'The foo and that bar', '.substr and :samecase (2)';
    is 'The foo and the bar'.subst(/:i the/, 'that', :samecase), 'That foo and the bar', '.substr (string pattern) and :    samecase (1)';
    is 'The foo and the bar'.subst(/:i The/, 'That', :samecase), 'That foo and the bar', '.substr (string pattern) and :    samecase (2)';
    is 'The foo and the bar'.subst(/:i the/, 'that', :g, :samecase), 'That foo and that bar', '.substr (string pattern)     and :g and :samecase (1)';
    is 'The foo and the bar'.subst(/:i The/, 'That', :g, :samecase), 'That foo and that bar', '.substr (string pattern)     and :g and :samecase (2)';

    my $str = "that";
    is 'The foo and the bar'.subst(/:i the/, {++$str}, :samecase), 'Thau foo and the bar', '.substr and samecase, worked with block replacement';
    is 'The foo and the bar'.subst(/:i the/, {$str++}, :g, :samecase), 'Thau foo and thav bar', '.substr and :g and :samecase, worked with block replacement';
}

{
    $_ = 'foObar';
    s:ii/oo/au/;
    is $_, 'faUbar', ':ii implies :i';

    $_ = 'foObar';
    s:samecase/oo/au/;
    is $_, 'faUbar', ':samecase implies :i';

}

# https://github.com/Raku/old-issue-tracker/issues/1080
{
    my $str = "a\nbc\nd";
    is $str.subst(/^^/, '# ', :g), "# a\n# bc\n# d",
        'Zero-width substitution does not make the GC recurse';
}

{
    throws-like q[ $_ = "abc"; my $i = 1; s:i($i)/a/b/ ], X::Value::Dynamic,
        'Value of :i must be known at compile time';
    #?rakudo todo 'be smarter about constant detection'
    eval-lives-ok q[ $_ = "abc";s:i(1)/a/b/ ],
        ':i(1) is OK';
}

{
    $_ = 'foo';
    s/f(.)/b$0/;
    is $_, 'boo', 'can use $0 in RHS of s///';
}

# https://github.com/Raku/old-issue-tracker/issues/1963
{
    class SubstInsideMethod {
        method ro($_ ) { s/c// }
    }

    dies-ok { SubstInsideMethod.new.ro('ccc') }, '(sanely) dies when trying to s/// a read-only variable';
}

# https://github.com/Raku/old-issue-tracker/issues/2355
#?DOES 3
{
    $_ = "foo"; s[f] = 'bar';
    is $_, "baroo", 's[f] is parsed as a substitution op';
    throws-like q{$_ = "foo"; s[] = "bar";}, X::Syntax::Regex::NullRegex;
}

# https://github.com/Raku/old-issue-tracker/issues/3204
{
    my $RT119201_s = 'abcdef';
    my $RT119201_m = '';
    $RT119201_s   .= subst(/(\w)/, { $RT119201_m = $/[0] });
    is($RT119201_m, 'a', 'get match variable in replacement of subst-mutator');
}

# https://github.com/Raku/old-issue-tracker/issues/3456
{
    eval-lives-ok '$_ = "a";s/a$/b/;s|b$|c|;s!c$!d!;', '$ anchor directly at the end of the search pattern works';
}

# https://github.com/Raku/old-issue-tracker/issues/3555
{
    my $foo = "bar";
    $foo ~~ s:g [ r ] = 'z' if $foo.defined;
    is $foo, 'baz', 's{}="" plus statement mod if is not parsed as /i';
}

{
    $_ = 42;
    my $match = s/\d+/xxx/;
    isa-ok $match, Match, 's/// returns a Match object on non-strings';
    is $_, 'xxx', 's/// can modify a container that contains a non-string';
}

# https://github.com/Raku/old-issue-tracker/issues/3645
{
    $_ = 0; s{^(\d+)$} = sprintf "%3d -", $_;
    is $_, "  0 -", 's{}="" can modify a container that contains a non-string';
}

# https://github.com/Raku/old-issue-tracker/issues/2848
{
    $_ = "real";
    s[ea] = "rea";
    is $_, "rreal", 's[]="" works when $_ is set';

    $_ = "";
    throws-like { EVAL 's[] = "rea"' },
        X::Syntax::Regex::NullRegex;
}

# https://github.com/Raku/old-issue-tracker/issues/2593
# https://github.com/Raku/old-issue-tracker/issues/2848
#?rakudo todo "RT #114388 -- expected: '', got: (Any)"
{
    $_ = Any;
    s[ea] = "rea";
    is $_, "", 'can use s[]="" when $_ is not set';
}

# https://github.com/Raku/old-issue-tracker/issues/4683
{
    $_ = "foo";
    is S/a/A/, "foo", "non-mutating single substitution works ($/)";
}

{
    $_ = "foo";
    is S/o/O/, "fOo", "non-mutating single substitution works ($/)";

    $_ = "foo";
    is S:g/o/O/, "fOO", "non-mutating global substitution works ($/)";

    $_ = "foo";
    is S[o] = 'O', "fOo", "non-mutating single substitution assignment works ($/)";

    $_ = "foo";
    is S:g[o] = 'O', "fOO", "non-mutating global substitution assignment works ($/)";

    $_ = "foo";
    is S/(o)/{$0.uc}/, "fOo", "non-mutating single substitution works ($0)";

    $_ = "foo";
    is S:g/(o)/{$0.uc}/, "fOO", "non-mutating global substitution works ($0)";

    $_ = "foo";
    is S[(o)] = $0.uc, "fOo", "non-mutating single substitution assignment works ($0)";

    $_ = "foo";
    is S:g[(o)] = $0.uc, "fOO", "non-mutating global substitution assignment works ($0)";
}

# https://github.com/Raku/old-issue-tracker/issues/5514
{
    is_run 'await ^30 .map: { start { S/.+/{$/.chars.print}/ given "abc"; } }', {
        :err(''), :out('3' x 30)
    }, 'code in replacement part of s/// has correct scoping';
}

# https://github.com/Raku/old-issue-tracker/issues/5699
{
    throws-like { "".subst: /\w/, "", :x(my class SomeInvalidXParam {}.new) },
        X::Str::Match::x, 'giving .subst invalid args throws';
}

# https://github.com/Raku/old-issue-tracker/issues/5869
is-deeply (S:g/FAIL// with 'foo'), 'foo',
    'S:g/// returns original string on failure to match';

# https://github.com/Raku/old-issue-tracker/issues/5886
is-deeply (eager <a b c aab ac>.map: {S/a/x/}), <x b c xab xc>,
    'S/// can be used in map (does not reuse a container)';

# https://irclog.perlgeek.de/perl6-dev/2017-03-22#i_14308172
subtest 'List/Match result adverb handling' => {
    # Check that we can handle a bunch of adverb combinations that
    # can result in either a Match or a List of Matches in $/
    plan 3;

    group-of 2 => ':2nd:g' => {
        subtest 'S///' => {
            plan 3;
            is-deeply (S:2nd:g/./Z/ with 'abc'), 'aZc', 'return value';
            isa-ok    $/,                        Match, '$/ is Match';
            is-deeply $/.Str,                    'b',   '$/.Str';
        }
        subtest 's///' => {
            plan 4;
            my $v = 'abc';
            my $r = $v ~~ s:2nd:g/./Z/;
            is-deeply $v,        'aZc', 'result';
            cmp-ok    $r, '===', $/,    'return value';
            isa-ok    $/,        Match, '$/ is Match';
            is-deeply $/.Str,    'b',   '$/.Str';
        }
    }

    group-of 2 => ':x(1..3)' => {
        subtest 'S///' => {
            plan 3;
            is-deeply (S:x(1..3)/./Z/ with 'abcd'), 'ZZZd', 'return value';
            isa-ok    $/,                           List,    '$/ is List';
            is-deeply $/».Str,                      <a b c>, '$/».Str';
        }
        subtest 's///' => {
            plan 4;
            my $v = 'abcd';
            my $r = $v ~~ s:x(1..3):g/./Z/;
            is-deeply $v,        'ZZZd',  'result';
            cmp-ok    $r, '===', $/,      'return value';
            isa-ok    $/,        List,    '$/ is List';
            is-deeply $/».Str,   <a b c>, '$/».Str';
        }
    }

    group-of 2 => ':th(1, 3)' => {
        subtest 'S///' => {
            plan 3;
            is-deeply (S:th(1, 3)/./Z/ with 'abcd'), 'ZbZd', 'return value';
            isa-ok    $/,                           List,    '$/ is List';
            is-deeply $/».Str,                      <a c>,   '$/».Str';
        }
        subtest 's///' => {
            plan 4;
            my $v = 'abcd';
            my $r = $v ~~ s:th(1, 3):g/./Z/;
            is-deeply $v,        'ZbZd', 'result';
            cmp-ok    $r, '===', $/,     'return value';
            isa-ok    $/,        List,   '$/ is List';
            is-deeply $/».Str,   <a c>,  '$/».Str';
        }
    }
}

subtest '.subst(Str:D, Str:D)' => {
    plan 6;
    is-deeply 'abc'.subst('a',  'zo'),  'zobc',   'replace with longer';
    is-deeply 'abc'.subst('ab',  'z'),  'zc',     'replace with shorter';
    is-deeply 'abc'.subst('ab',  'xy'), 'xyc',    'replace with samelength';

    is-deeply 'a♥bc'.subst('♥',  'zo'), 'azobc',  'replace with longer (2)';
    is-deeply 'a♥bc'.subst('♥b',  'z'), 'azc',    'replace with shorter (2)';
    is-deeply 'a♥bc'.subst('a♥', '♦z'), '♦zbc',   'replace with samelength (2)';
}

# https://github.com/Raku/old-issue-tracker/issues/6043
subtest '.subst with multi-match args set $/ to a List of matches' => {
    plan 2*(2+5);
    for 1234567, '1234567' -> $type {
        group-of 4 => "$type.^name().subst: :g" => {
          ($ = $type).subst(:g, /../, 'XX');
          isa-ok $/, List, '$/ is a List…';
          cmp-ok +$/, '==', 3, '…with 3 items…';
          is-deeply $/.map({.WHAT}).unique, (Match,).Seq, '…all are Match…';
          is-deeply $/.map(~*), <12 34 56>.map(*.Str), '…all have right values';
        }
        group-of 4 => ".subst: :x" => {
          ($ = $type).subst(:2x, /../, 'XX');
          isa-ok $/, List, '$/ is a List…';
          cmp-ok +$/, '==', 2, '…with 2 items…';
          is-deeply $/.map({.WHAT}).unique, (Match,).Seq, '…all are Match…';
          is-deeply $/.map(~*), <12 34>.map(*.Str), '…all have right values';
        }
        for <nth st nd rd th> -> $suffix {
          group-of 4 => ".subst: :$suffix" => {
              ($ = $type).subst(|($suffix => 1..3), /../, 'XX');
              isa-ok $/, List, '$/ is a List…';
              cmp-ok +$/, '==', 3, '…with 3 items…';
              is-deeply $/.map({.WHAT}).unique, (Match,).Seq, '…all are Match…';
              is-deeply $/.map(~*), <12 34 56>.map(*.Str),
                  '…all have right values';
          }
        }
    }
}

# https://github.com/rakudo/rakudo/issues/3358
{
    $_ = "12345";
    is-deeply ([3,4].map:{S{5}=$^a}), ('12343', '12344'),
        'Placeholder parameter in substitution assignment';

    $_ = "12345";
    is-deeply ([3,4].map:{S/5/$^a/}), ('12343', '12344'),
        'Placeholder parameter in substitution quoted';

    $_ = "12345";
    is-deeply ([3,4].map:{S{$^a}='X'}), ('12X45', '123X5'),
        'Placeholder parameter in substitution regex ({} quoter)';

    $_ = "12345";
    is-deeply ([3,4].map:{S/$^a/X/}), ('12X45', '123X5'),
        'Placeholder parameter in substitution regex (// quoter)';
}
 
# https://github.com/Raku/old-issue-tracker/issues/3515
lives-ok { BEGIN "a".subst: /a/, "b" }, '.subst in BEGIN does not die';

# vim: expandtab shiftwidth=4
