use Test;
use lib $*PROGRAM.parent(2).add: 'packages/Test-Helpers';
use Test::Util;

plan 155;

=begin pod

Misc. Junction tests

=end pod

# https://github.com/Raku/old-issue-tracker/issues/834
{
    isa-ok any(6,7), Junction;
    is any(6,7).WHAT.gist, Junction.gist, 'junction.WHAT works';
}

# avoid auto-threading on ok()
#?DOES 1
sub jok(Mu $condition, $msg?) is test-assertion { ok ?($condition), $msg }

# L<S03/Junctive operators>
# L<S09/Junctions>
{

    # initialize them all to empty strings
    my $a = '';
    my $b = '';
    my $c = '';

    # make sure they all match to an empty string
    jok('' eq ($a & $b & $c), 'junction of ($a & $b & $c) matches an empty string');
    jok('' eq all($a, $b, $c), 'junction of all($a, $b, $c) matches an empty string');

    # give $a a value
    $a = 'a';

    # make sure that at least one of them matches 'a'
    jok('a' eq ($b | $c | $a), 'junction of ($b | $c | $a) matches at least one "a"');
    jok('a' eq any($b, $c, $a), 'junction of any($b, $c, $a) matches at least one "a"');

    jok('' eq ($b | $c | $a), 'junction of ($b | $c | $a) matches at least one empty string');
    jok('' eq any($b, $c, $a), 'junction of any($b, $c, $a) matches at least one empty string');

    # make sure that ~only~ one of them matches 'a'
    jok('a' eq ($b ^ $c ^ $a), 'junction of ($b ^ $c ^ $a) matches at ~only~ one "a"');
    jok('a' eq one($b, $c, $a), 'junction of one($b, $c, $a) matches at ~only~ one "a"');

    # give $b a value
    $b = 'a';

    # now this will fail
    jok('a' ne ($b ^ $c ^ $a), 'junction of ($b ^ $c ^ $a) matches at more than one "a"');

    # change $b and give $c a value
    $b = 'b';
    $c = 'c';

    jok('a' eq ($b ^ $c ^ $a), 'junction of ($b ^ $c ^ $a) matches at ~only~ one "a"');
    jok('b' eq ($a ^ $b ^ $c), 'junction of ($a ^ $b ^ $c) matches at ~only~ one "b"');
    jok('c' eq ($c ^ $a ^ $b), 'junction of ($c ^ $a ^ $b) matches at ~only~ one "c"');

    jok('a' eq ($b | $c | $a), 'junction of ($b | $c | $a) matches at least one "a"');
    jok('b' eq ($a | $b | $c), 'junction of ($a | $b | $c) matches at least one "b"');
    jok('c' eq ($c | $a | $b), 'junction of ($c | $a | $b) matches at least one "c"');


    # test junction to junction
    jok(('a' | 'b' | 'c') eq ($a & $b & $c), 'junction ("a" | "b" | "c") matches junction ($a & $b & $c)');
    jok(('a' & 'b' & 'c') eq ($a | $b | $c), 'junction ("a" & "b" & "c") matches junction ($a | $b | $c)');

    # mix around variables and literals

    jok(($a & 'b' & 'c') eq ('a' | $b | $c), 'junction ($a & "b" & "c") matches junction ("a" | $b | $c)');
    jok(($a & 'b' & $c) eq ('a' | $b | 'c'), 'junction ($a & "b" & $c) matches junction ("a" | $b | "c")');

}

# same tests, but with junctions as variables
{
        # initialize them all to empty strings
    my $a = '';
    my $b = '';
    my $c = '';

    my Mu $all_of_them = $a & $b & $c;
    jok('' eq $all_of_them, 'junction variable of ($a & $b & $c) matches and empty string');

    $a = 'a';

    my Mu $any_of_them = $b | $c | $a;
    jok('a' eq $any_of_them, 'junction variable of ($b | $c | $a) matches at least one "a"');
    jok('' eq $any_of_them, 'junction variable of ($b | $c | $a) matches at least one empty string');

    my Mu $one_of_them = $b ^ $c ^ $a;
    jok('a' eq $one_of_them, 'junction variable of ($b ^ $c ^ $a) matches at ~only~ one "a"');

    $b = 'a';

    {
        my Mu $one_of_them = $b ^ $c ^ $a;
        jok('a' ne $one_of_them, 'junction variable of ($b ^ $c ^ $a) matches at more than one "a"');
    }

    $b = 'b';
    $c = 'c';

    {
        my Mu $one_of_them = $b ^ $c ^ $a;
        jok('a' eq $one_of_them, 'junction of ($b ^ $c ^ $a) matches at ~only~ one "a"');
        jok('b' eq $one_of_them, 'junction of ($a ^ $b ^ $c) matches at ~only~ one "b"');
        jok('c' eq $one_of_them, 'junction of ($c ^ $a ^ $b) matches at ~only~ one "c"');
    }

    {
        my Mu $any_of_them = $b | $c | $a;
        jok('a' eq $any_of_them, 'junction of ($b | $c | $a) matches at least one "a"');
        jok('b' eq $any_of_them, 'junction of ($a | $b | $c) matches at least one "b"');
        jok('c' eq $any_of_them, 'junction of ($c | $a | $b) matches at least one "c"');
    }

}

{
    my Mu $j = 1 | 2;
    $j = 5;
    is($j, 5, 'reassignment of junction variable');
}

{
    my Mu $j;
    my Mu $k;

    $j = 1|2;
    is(WHAT($j).gist, '(Junction)', 'basic junction type reference test');

    $k=$j;
    is(WHAT($k).gist, '(Junction)', 'assignment preserves reference');
}


=begin description

Tests junction examples from Synopsis 03

j() is used to convert a junction to canonical string form, currently
just using .raku until a better approach presents itself.

=end description

# L<S03/Junctive operators>

# Canonical stringification of a junction
sub j (Mu $j) { return $j.raku }

{
    # L<S03/Junctive operators/They thread through operations>
    my Mu $got;
    my Mu $want;
    $got = ((1|2|3)+4);
    $want = (5|6|7);
    is( j($got), j($want), 'thread + returning junctive result');

    $got = ((1|2) + (3&4));
    $want = ((4|5) & (5|6));
    is( j($got), j($want), 'thread + returning junctive combination of results');

    # L<S03/Junctive operators/This opens doors for constructions like>
    # unless $roll == any(1..6) { print "Invalid roll" }
    my $roll;
    my $note;
    $roll = 3; $note = '';
    unless $roll == any(1..6) { $note = "Invalid roll"; };
    is($note, "", 'any() junction threading ==');

    $roll = 7; $note = '';
    unless $roll == any(1..6) { $note = "Invalid roll"; };
    is($note, "Invalid roll", 'any() junction threading ==');

    # if $roll == 1|2|3 { print "Low roll" }
    $roll = 4; $note = '';
    if $roll == 1|2|3 { $note = "Low roll" }
    is($note, "", '| junction threading ==');

    $roll = 2; $note = '';
    if $roll == 1|2|3 { $note = "Low roll" }
    is($note, "Low roll", '| junction threading ==');
}

{
    # L<S03/Junctive operators/Junctions work through subscripting>
    my $got;
    my @foo;
    $got = ''; @foo = ();
    $got ~= 'y' if try { @foo[any(1,2,3)] };
    is($got, '', "junctions work through subscripting, 0 matches");

    $got = ''; @foo = (0,1);
    $got ~= 'y' if try { @foo[any(1,2,3)] };
    is($got, 'y', "junctions work through subscripting, 1 match");

    $got = ''; @foo = (1,1,1);
    $got ~= 'y' if try { @foo[any(1,2,3)] };
    is($got, 'y', "junctions work through subscripting, 3 matches");


    # L<S03/Junctive operators/Junctions are specifically unordered>
    # Compiler *can* reorder and parallelize but *may not* so don't test
    # for all(@foo) {...};

    # Not sure what is expected
    #my %got = ('1' => 1); # Hashes are unordered too
    #@foo = (2,3,4);
    #for all(@foo) { %got{$_} = 1; };
    #is( %got.keys.sort.join(','), '1,2,3,4',
    #    'for all(...) { ...} as parallelizable');
}

=begin description

These are implemented but still awaiting clarification on p6l.

 On Fri, 2005-02-11 at 10:46 +1100, Damian Conway wrote:
 > Subject: Re: Fwd: Junctive puzzles.
 >
 > Junctions have an associated boolean predicate that's preserved across
 > operations on the junction. Junctions also implicitly distribute across
 > operations, and rejunctify the results.

=end description

# L<S03/Junctive operators/They thread through operations>

{
    my @subs = (sub {3}, sub {2});

    my Mu $got;
    my Mu $want;

    is(j(any(@subs)()), j(3|2), '.() on any() junction of subs');

    $want = (3&2);
    $got = all(@subs)();
    is(j($got), j($want), '.() on all() junction of subs');

    $want = (3^2);
    $got = one(@subs)();
    is(j($got), j($want), '.() on one() junction of subs');

    $want = none(3,2);
    $got = none(@subs)();
    is(j($got), j($want), '.() on none() junction of subs');

    $want = one( any(3,2), all(3,2) );
    $got = one( any(@subs), all(@subs) )();
    is(j($got), j($want), '.() on complex junction of subs');

    # Avoid future constant folding
    #my $rand = rand;
    #my $zero = int($rand-$rand);
    #my @subs = (sub {3+$zero}, sub {2+$zero});
}

# Check functional and operator versions produce the same structure
{
    is(j((1|2)^(3&4)), j(one(any(1,2),all(3,4))),
        '((1|2)^(3&4)) equiv to one(any(1,2),all(3,4))');

    is(j((1|2)&(3&4)), j(all(any(1,2),all(3,4))),
        '((1|2)&(3&4)) equiv to all(any(1,2),all(3,4))');

    is(j((1|2)|(3&4)), j(any(any(1,2),all(3,4))),
        '((1|2)|(3&4)) equiv to any(any(1,2),all(3,4))');
}

# junction in boolean context
ok(?(0&0) == ?(0&&0), 'boolean context');
ok(?(0&1) == ?(0&&1), 'boolean context');
ok(?(1&1) == ?(1&&1), 'boolean context');
ok(?(1&0) == ?(1&&0), 'boolean context');
ok(!(?(0&0) != ?(0&&0)), 'boolean context');
ok(!(?(0&1) != ?(0&&1)), 'boolean context');
ok(!(?(1&1) != ?(1&&1)), 'boolean context');
ok(!(?(1&0) != ?(1&&0)), 'boolean context');


{
    my $c = 0;
    if 1 == 1 { $c++ }
    is $c, 1;
    if 1 == 1|2 { $c++ }
    is $c, 2;
    if 1 == 1|2|3 { $c++ }
    is $c, 3;

    $c++ if 1 == 1;
    is $c, 4;
    $c++ if 1 == 1|2;
    is $c, 5, 'if modifier with junction should be called once';

    $c = 0;
    $c++ if 1 == 1|2|3;
    is $c, 1, 'if modifier with junction should be called once';

    $c = 0;
    $c++ if 1 == any(1, 2, 3);
    is $c, 1, 'if modifier with junction should be called once';
}

{
    my @array = <1 2 3 4 5 6 7 8>;
    jok( all(@array) == one(@array), "all(@x) == one(@x) tests uniqueness(+ve)" );

    push @array, 6;
    jok( !( all(@array) == one(@array) ), "all(@x) == one(@x) tests uniqueness(-ve)" );

}

# https://github.com/Raku/old-issue-tracker/issues/434
ok Mu & Mu ~~ Mu, 'Mu & Mu ~~ Mu works';

## See also S03-junctions/autothreading.t
{
  is substr("abcd", 1, 2), "bc", "simple substr";
  my Mu $res = substr(any("abcd", "efgh"), 1, 2);
  isa-ok $res, Junction;
  ok $res eq "bc", "substr on junctions: bc";
  ok $res eq "fg", "substr on junctions: fg";
}

{
  my Mu $res = substr("abcd", 1|2, 2);
  isa-ok $res, Junction;
  ok $res eq "bc", "substr on junctions: bc";
  ok $res eq "cd", "substr on junctions: cd";
}

{
  my Mu $res = substr("abcd", 1, 1|2);
  isa-ok $res, Junction;
  ok $res eq "bc", "substr on junctions: bc";
  ok $res eq "b", "substr on junctions: b";
}

{
  my Mu $res = index(any("abcd", "qwebdd"), "b");
  isa-ok $res, Junction;
  ok $res == 1, "index on junctions: 1";
  ok $res == 3, "index on junctions: 3";
}

{
  my Mu $res = index("qwebdd", "b"|"w");
  isa-ok $res, Junction;
  ok $res == 1, "index on junctions: 1";
  ok $res == 3, "index on junctions: 3";
}

# https://github.com/Raku/old-issue-tracker/issues/745
{
    lives-ok { try { for any(1,2) -> $x {}; } },
             'for loop over junction in try block';

    sub rt63686 {
        for any(1,2) -> $x {};    #OK not used
        return 'happiness';
    }
    is rt63686(), 'happiness', 'for loop over junction in sub';
}

# https://github.com/rakudo/rakudo/issues/3198
{
    my @seen;
    @seen.push(.^name) for any 1;
    is-deeply @seen, ['Junction'], 'for loop over Junction gets the Junction';
}

# https://github.com/Raku/old-issue-tracker/issues/1167
# Error with stringifying .WHAT on any junctions
{
    ok((WHAT any()) ~~ Junction, "test WHAT on empty any junction");
    ok(any().WHAT ~~ Junction, "test WHAT on empty any junction");
    ok((WHAT any(1,2)) ~~ Junction, "test WHAT on any junction");
    ok(any(1,2).WHAT ~~ Junction, "test WHAT on any junction");
}

# Any list has junction methods
{
    jok(5 < (6,7,8).all, '.all method builds "all" junction');
    jok(!(7 < (6,7,8).all), '.all method builds "all" junction');
    jok(7 == (6,7,8).one, '.one method builds "one" junction');
    jok(9 == (6,7,8).none, '.none method builds "none" junction');

    my @x = (6,7,8);
    jok(5 < @x.all, '.all method works on array objects');
}

# https://github.com/Raku/old-issue-tracker/issues/688
#?DOES 2
{
    my @a = "foo", "foot";
    ok @a[all(0,1)] ~~ /^foo/,
        'junction can be used to index Array';

    my %h = (
        "0" => "foo",
        "1" => "foot"
    );
    ok %h{all(0,1)} ~~ /^foo/,
        'junction can be used to index Hash';
}

# https://github.com/Raku/old-issue-tracker/issues/2670
{
    is (all() ~~ /^ \d+ $/).gist,  'all()',
        'regex match in all junction is an empty all junction (1)';
    is (all() ~~ /./).gist,        'all()',
        'regex match in all junction is an empty all junction (2)';
    is (all() ~~ /all/).gist,      'all()',
        'regex match in all junction is an empty all junction (3)';
    is (all() ~~ /bll/).gist,      'all()',
        'regex match in all junction is an empty all junction (4)';
    is (any("4","5") ~~ /4/).gist, 'any(｢4｣, Nil)',
        'successful regex match in any junction';
}

# https://github.com/Raku/old-issue-tracker/issues/2533
{
    is ("foo" & "a nice old foo" ~~ /foo/).gist, 'all(｢foo｣, ｢foo｣)',
        'successful regex match in all junction';
}

# https://github.com/Raku/old-issue-tracker/issues/3313
{
    is (all("a","b") ~~ /a/).gist, 'all(｢a｣, Nil)',
        'successful regex match in all junction if one element does not match';
}

# stringy tests
{
   my class Foo {
      multi method gist(Foo:D:) { "gisted"; }
      multi method raku(Foo:D:) { "rakued"; }
      multi method Str(Foo:D:) { "Stred"; }
   }
   is any(Foo.new).raku, 'any(rakued)', 'any(Foo.new).raku';
   is any(Foo.new).gist, 'any(gisted)', 'any(Foo.new).gist';
}

# https://github.com/Raku/old-issue-tracker/issues/2623
ok { a => 1} ~~ List|Hash, 'Can construct junction with List type object';

# https://github.com/Raku/old-issue-tracker/issues/2511
ok (0|1 == 0&1), 'test junction evaluation order';
ok (0&1 == 0|1), 'test junction evaluation order';

# test one-arg-flattening of listop forms

ok any((1,2,3),(4,5,6)) eqv (1,2,3), 'any is not flattening 1';
nok any((1,2,4),(4,5,6)) == 2, 'any is not flattening 2';
is (any((1,2,3),(4,5,6)) eqv (4,5,6)).gist, 'any(False, True)', 'any is not flattening 3';
ok any((1,2,4)) == 2, 'any is onearg';

ok all((4,5,6),(4,5,6)) eqv (4,5,6), 'all is not flattening 1';
ok all((1,2,3),(4,5,6)) == 3, 'all is non flattening 2';
is (all((1,2,3),(4,5,6)) eqv (4,5,6)).gist, 'all(False, True)', 'all is not flattening 3';
nok all((1,2,3)) == 3, 'all is onearg';

ok one((4,5,6),(4,5,6,7)) eqv (4,5,6,7), 'one is not flattening 1';
nok one((1,2,3),(4,5,6)) eq '3' , 'one is not flattening 2';
is (one((1,2,3),(4,5,6)) eqv (1,2,3)).gist, 'one(True, False)', 'one is not flattening 3';
ok one((1,2,3)) == 2, 'one is onearg';

ok none((4,5,6),(4,5,6)) == 4, 'none is not flattening 1';
ok none((1,2,3,4),(4,5,6,7)) eq '3' , 'none is not flattening 2';
is (none(1,2,3,(4,5,6)) == 3).gist, 'none(False, False, True, True)', 'none is not flattening 3';
nok none((1,2,3,4)) == 3 , 'none is onearg';

# test non-flattening of method forms

nok (<a b c>,(4,5,6)).any == 4, '.any is not flattening 1';
ok (<a b c>,(4,5,6)).any == 3, '.any is not flattening 2';
is ((<a b c>,(4,5,6)).any == 3).gist, 'any(True, True)', '.any is not flattening 3';

nok ((4,5,6),(4,5,6)).all > 3, '.all is not flattening 1';
ok (<a b c>,(4,5,6)).all == 3, '.all is not flattening 2';
is ((<a b c>,(4,5,6)).all == 3).gist, 'all(True, True)', '.any is not flattening 3';

nok ((4,5,6),(4,5,6,7)).one == 7, '.one is not flattening 1';
ok (<a b c>,(4,5,6)).one eq 'a b c' , '.one is not flattening 2';
is ((<a b c>,(4,5,6)).one eq 'a b c').gist, 'one(True, False)', '.one is not flattening 3';

nok ((4,5,6),(4,5,6,7)).none == 3, '.none is not flattening 1';
ok (<a b c>,(4,5,6)).none eq 'a' , '.none is not flattening 2';
is ((<a b c>,(4,5,6)).none eq 'a b c').gist, 'none(True, False)', '.none is not flattening 3';

throws-like 'multi sub foo($) { }; foo(Junction)', X::Multi::NoMatch,
    'Do not try to auto-thread Junction type object (multi case)';
throws-like 'sub foo($) { }; foo(Junction)', X::TypeCheck::Binding,
    'Do not try to auto-thread Junction type object (only case)';

# https://github.com/Raku/old-issue-tracker/issues/5691
{
    my %h;
    %h{ any ^2 }.push: 42;
    is-deeply %h, %(0 => [42], 1 => [42]), 'Junctions with autovivification';
}

subtest 'Junction.new' => { # coverage; 2016-10-11
    plan 4;

    is-deeply-junction Junction.new([^3], :type<all> ),
        ^3 .all, 'all';
    is-deeply-junction Junction.new([^3], :type<one> ),
        ^3 .one, 'one';
    is-deeply-junction Junction.new([^3], :type<any> ),
        ^3 .any, 'any';
    is-deeply-junction Junction.new([^3], :type<none>),
        ^3 .none, 'none';
}

# https://github.com/rakudo/rakudo/commit/aa3684218b1f668b6a6e41da
subtest 'Junction.new does not crash with empty, but touched array' => {
    plan 4;

    my @a; $ = +@a;
    lives-ok { Junction.new($_, @a).raku }, $_ for <all none any one>;
}

subtest 'Junction .Str, .gist, and .raku' => {
    plan 3+4*2;
    isa-ok <a b c>.any.Str.WHAT,  Junction, 'Junction.Str juncts';
    isa-ok <a b c>.any.gist.WHAT, Str,      'Junction.gist does not junct';
    isa-ok <a b c>.any.raku.WHAT, Str,      'Junction.raku does not junct';

    for <none one any all> -> $t {
        is-deeply <foo bar ber>."$t"().gist.comb(/\w+/).sort, ($t, |<foo bar ber>).sort, "Junction.gist on $t junction looks about right";
        my $j := <foo bar ber>."$t"();
        is-deeply-junction $j.raku.EVAL, $j, "Junction.raku on $t junction roundtrips";
    }
}
# GH rakudo/rakudo#1205
subtest q<meta-assignment to a scalar doesn't cause freezing> => {
    plan 3;
    my %junction_ops = :all<&>, :any<|>, :one<^>;
    for %junction_ops.pairs -> (:key($type), :value($op)) {
        #?rakudo.jvm todo 'closing parenthesis from gist pops up on stderr for "&"'
        doesn't-hang 'my $j = 1; $j ' ~ $op ~ '= 2; print $j.gist',
                     "junction '$type' doesn't freeze after assign metaop",
                     :out("{$type}(1, 2)"),
                     :err("");
    }
}

# GH #2042
{
    is-deeply-junction (all("a","b","c") ~ any("d","e")),
      all(any("ad", "ae"), any("bd", "be"), any("cd", "ce")),
      'did all() on left concate with any() on right ok';
    is-deeply-junction (any("a","b","c") ~ all("d","e")),
      all(any("ad", "ae"), any("bd", "be"), any("cd", "ce")),
      'did any() on left concate with all() on right ok';
}

# GH rakudo/rakudo#4742
# https://github.com/rakudo/rakudo/issues/4742
subtest "IO" => {
    my @routines =
        say => %(
            out => "any(1, any(2, 3))\n",
            err => "",
        ),
        put => %(
            out => "1\n2\n3\n",
            err => "",
        ),
        note => %(
            err => "any(1, any(2, 3))\n",
            out => "",
        ),
        print => %(
            out => "123",
            err => "",
        );

    plan +@routines * 4;

    for @routines -> (:key($routine), :value(%expected)) {
        is_run "$routine (1|(2|3))", %expected, "$routine";
        is_run "(1|(2|3)).&$routine", %expected, "$routine sub as .\&method";
        is_run "(1|(2|3)).$routine", %expected, "$routine as method";
        is_run "$routine (1|(2|3)):", %expected, "$routine as method-prefix";
    }
}

# Junction is a value object
subtest "Value Object", {
    my $j1 := any(<a b c>);
    my $j2 := any(<a b c>);
    cmp-ok $j1, &[!=:=], $j2, "identical junctions are different object";
    cmp-ok $j1.WHICH, &[===], $j2.WHICH, "but they're identity";
}

# https://github.com/rakudo/rakudo/issues/2719
{
    is-deeply "foo".starts-with("f"|"b"), (True | False), 'starts-with';
    is-deeply "foo".ends-with("f"|"b"), (False | False),  'ends-with'; 
    is-deeply "foo".contains("f"|"b"), (True | False),    'contains';
    is-deeply "foo".substr-eq("f"|"b"), (True | False),   'substr-eq';
}

# vim: expandtab shiftwidth=4
