use v6;

use Test;

=begin description

Tests the "for" statement

This attempts to test as many variations of the
for statement as possible

=end description

plan 55;

## No foreach
# L<S04/The C<for> statement/"no foreach statement any more">
{
    my $times_run = 0;
    eval_dies_ok 'foreach 1..10 { $times_run++ }; 1', "foreach is gone";
    eval_dies_ok 'foreach (1..10) { $times_run++}; 1',
        "foreach is gone, even with parens";
    is $times_run, 0, "foreach doesn't work";
}

## for with plain old range operator w/out parens

{
    my $a;
    for 0 .. 5 { $a = $a ~ $_; };
    is($a, '012345', 'for 0..5 {} works');
}

# ... with pointy blocks

{
    my $b;
    for 0 .. 5 -> $_ { $b = $b ~ $_; };
    is($b, '012345', 'for 0 .. 5 -> {} works');
}

#?pugs eval 'todo: slice context'
#?rakudo skip 'slice context'
{
    my $str;
    my @a = 1..3;
    my @b = 5..6;
    for zip(@a; @b) -> $x, $y {
        $str ~= "($x $y)";
    }
    is $str, "(1 5)(2 4)(3 6)", 'for zip(@a; @b) -> $x, $y works';
}

# ... with referential sub
#?rakudo skip 'class accessing outer lexical'
{
    my $d = '';
    class Int is also {
        method some_meth_1 { 
            $d = $d ~ self
        } 
    };
    for 0 .. 5 { .some_meth_1 };
    is($d, '012345', 'for 0 .. 5 { .some_sub } works');
}

## and now with parens around the range operator
{
    my $e;
    for (0 .. 5) { $e = $e ~ $_; };
    is($e, '012345', 'for () {} works');
}

# ... with pointy blocks
{
    my $f;
    for (0 .. 5) -> $_ { $f = $f ~ $_; };
    is($f, '012345', 'for () -> {} works');
}

# ... with implicit topic

{
    $_ = "GLOBAL VALUE";
    for "INNER VALUE" {
    is( .lc, "inner value", "Implicit default topic is seen by lc()");
    };
    is($_,"GLOBAL VALUE","After the loop the implicit topic gets restored");
}
{
    # as statement modifier
    $_ = "GLOBAL VALUE";
    is( .lc, "inner value", "Implicit default topic is seen by lc()" )
        for "INNER VALUE";
    is($_,"GLOBAL VALUE","After the loop the implicit topic gets restored");
}

## and now for with 'topical' variables

# ... w/out parens

my $i;
for 0 .. 5 -> $topic { $i = $i ~ $topic; };
is($i, '012345', 'for 0 .. 5 -> $topic {} works');

# ... with parens

my $j;
for (0 .. 5) -> $topic { $j = $j ~ $topic; };
is($j, '012345', 'for () -> $topic {} works');


## for with @array operator w/out parens

my @array_k = (0 .. 5);
my $k;
for @array_k { $k = $k ~ $_; };
is($k, '012345', 'for @array {} works');

# ... with pointy blocks

my @array_l = (0 .. 5);
my $l;
for @array_l -> $_ { $l = $l ~ $_; };
is($l, '012345', 'for @array -> {} works');

## and now with parens around the @array

my @array_o = (0 .. 5);
my $o;
for (@array_o) { $o = $o ~ $_; };
is($o, '012345', 'for (@array) {} works');

# ... with pointy blocks
{
    my @array_p = (0 .. 5);
    my $p;
    for (@array_p) -> $_ { $p = $p ~ $_; };
    is($p, '012345', 'for (@array) -> {} works');
}

my @elems = <a b c d e>;

{
    my @a;
    for (@elems) {
        push @a, $_;
    }
    my @e = <a b c d e>;
    is(@a, @e, 'for (@a) { ... $_ ... } iterates all elems');
}

{
    my @a;
        for (@elems) -> $_ { push @a, $_ };
    my @e = @elems;
    is(@a, @e, 'for (@a)->$_ { ... $_ ... } iterates all elems' );
}

{
    my @a;
    for (@elems) { push @a, $_, $_; }
    my @e = <a a b b c c d d e e>;
    is(@a, @e, 'for (@a) { ... $_ ... $_ ... } iterates all elems, not just odd');
}

# "for @a -> $var" is ro by default.
{
    my @a = <1 2 3 4>;

    eval_dies_ok('for @a -> $elem {$elem = 5}', '-> $var is ro by default');

    for @a <-> $elem {$elem++;}
    is(@a, <2 3 4 5>, '<-> $var is rw');

    for @a <-> $first, $second {$first++; $second++}
    is(@a, <3 4 5 6>, '<-> $var, $var2 works');
}

# for with "is rw"
{
    my @array_s = (0..2);
    my @s = (1..3);
    for @array_s { $_++ };
    is(@array_s, @s, 'for @array { $_++ }');
}

{
    my @array_t = (0..2);
    my @t = (1..3);
    for @array_t -> $val is rw { $val++ };
    is(@array_t, @t, 'for @array -> $val is rw { $val++ }');
}

#?pugs eval 'todo'
{
    my @array_v = (0..2);
    my @v = (1..3);
    for @array_v.values -> $val is rw { $val++ };
    is(@array_v, @v, 'for @array.values -> $val is rw { $val++ }');
}

#?pugs eval 'todo'
{
    my @array_kv = (0..2);
    my @kv = (1..3);
    for @array_kv.kv -> $key, $val is rw { $val++ };
    is(@array_kv, @kv, 'for @array.kv -> $key, $val is rw { $val++ }');
}

#?pugs eval 'todo'
{
    my %hash_v = ( a => 1, b => 2, c => 3 );
    my %v = ( a => 2, b => 3, c => 4 );
    for %hash_v.values -> $val is rw { $val++ };
    is(%hash_v, %v, 'for %hash.values -> $val is rw { $val++ }');
}

#?pugs eval 'todo'
{
    my %hash_kv = ( a => 1, b => 2, c => 3 );
    my %kv = ( a => 2, b => 3, c => 4 );
    try { for %hash_kv.kv -> $key, $val is rw { $val++ }; };
    is( %hash_kv, %kv, 'for %hash.kv -> $key, $val is rw { $val++ }');
}

# .key //= ++$i for @array1;
class TestClass{ has $.key is rw  };

#?rakudo todo '//='
{
   my @array1 = (TestClass.new(:key<1>),TestClass.new());
   
   my $i = 0;
   my $sum1 = [+] @array1.map: { $_.key };
   is( $sum1, 2, '.key //= ++$i for @array1;', :todo<bug>);

}

# .key = 1 for @array1;
{
   my @array1 = (TestClass.new(),TestClass.new(:key<2>));

   .key = 1 for @array1;
   my $sum1 = [+] @array1.map: { $_.key };
   is($sum1, 2, '.key = 1 for @array1;');
}

# $_.key = 1 for @array1;
{
   my @array1 = (TestClass.new(),TestClass.new(:key<2>));

   $_.key = 1 for @array1;
   my $sum1 = [+] @array1.map: { $_.key };
   is( $sum1, 2, '$_.key = 1 for @array1;');

}

# rw scalars
#L<S04/The C<for> statement/implicit parameter to block read/write "by default">
{
    my ($a, $b, $c) = 0..2;
    try { for ($a, $b, $c) { $_++ } };
    is( [$a,$b,$c], [1,2,3], 'for ($a,$b,$c) { $_++ }');

    ($a, $b, $c) = 0..2;
    try { for ($a, $b, $c) -> $x is rw { $x++ } };
    is( [$a,$b,$c], [1,2,3], 'for ($a,$b,$c) -> $x is rw { $x++ }');
}

# list context

{
    my $a = '';
    for 1..3, 4..6 { $a ~= $_.WHAT };
    is($a, 'Int()Int()Int()Int()Int()Int()', 'List context');

    $a = '';
    for [1..3, 4..6] { $a ~= $_.WHAT };
    is($a, 'Array()', 'List context');

    $a = '';
    for [1..3], [4..6] { $a ~= $_.WHAT };
    is($a, 'Array()Array()', 'List context');
}

{
    # this was a rakudo bug with mixed 'for' and recursion, which seems to 
    # confuse some lexical pads or the like, see RT #58392
    my $gather = '';
    sub f($l) {
        if $l <= 0 {
            return $l;
        }
        $gather ~= $l;
        for 1..3 {
        f($l-1);
            $gather ~= '.';
        }
    }
    f(2);

    is $gather, '21....1....1....', 'Can mix recursion and for';
}

# grep and sort in for - these were pugs bugs once, so let's
# keep them as regression tests

{
  my @array = <1 2 3 4>;
  my $output = '';

  for (grep { 1 }, @array) -> $elem {
    $output ~= "$elem,";
  }

  is $output, "1,2,3,4,", "grep and sort work in for";
}

{
  my @array = <1 2 3 4>;
  my $output = '';

  for sort @array -> $elem {
    $output ~= "$elem,";
  }

  is $output, "1,2,3,4,", "grep and sort work in for";
}

{
  my @array = <1 2 3 4>;
  my $output = '';

  for (grep { 1 }, sort @array) -> $elem {
    $output ~= "$elem,";
  }

  is $output, "1,2,3,4,", "grep and sort work in for";
}

# L<S04/Statement parsing/keywords require whitespace>
eval_dies_ok('for(0..5) { }','keyword needs at least one whitespace after it');

# looping with more than one loop variables
{
  my @a = <1 2 3 4>;
  my $str = '';
  for @a -> $x, $y { 
    $str ~= $x+$y;
  }
  is $str, "37", "for loop with two variables";
}

{
  #my $str = '';
  eval_dies_ok('for 1..5 ->  $x, $y { $str ~= "$x$y" }', 'Should throw exception StopIteration'); 
  #is $str, "1234", "loop ran before throwing exception";
  #diag ">$str<";
}

#?rakudo skip 'optional variable in for loop'
{
  my $str = '';
  for 1..5 -> $x, $y? {
    $str ~= " " ~ $x*$y;
  }
  is $str, " 2 12 0";
}

#?rakudo skip 'default value in variable in for loop'
{
  my $str = '';
  for 1..5 -> $x, $y = 7 {
    $str ~= " " ~ $x*$y;
  }
  is $str, " 2 12 35";
}


{
  my @a = <1 2 3>;
  my @b = <4 5 6>;
  my $res = '';
  for @a Z @b -> $x, $y {
    $res ~= " " ~ $x * $y;
  }
  is $res, " 4 10 18", "Z -ed for loop";
}

{
  my @a = <1 2 3>;
  my $str = '';

  for @a Z @a Z @a Z @a Z @a -> $q, $w, $e, $r, $t {
    $str ~= " " ~ $q*$w*$e*$r*$t;
  }
  is $str, " 1 {2**5} {3**5}", "Z-ed for loop with 5 arrays";
}

{
  eval_dies_ok 'for 1.. { };', "Please use ..* for indefinite range";
  eval_dies_ok 'for 1... { };', "1... does not exist";
}

{
  my $c;
  for 1..8 {
    $c = $_;
    last if $_ == 6;
  }
  is $c, 6, 'for loop ends in time using last';
}

#?rakudo skip 'lazy lists (loops)'
{
  my $c;
  for 1..* {
    $c = $_;
    last if $_ == 6;
  }
  is $c, 6, 'infinte for loop ends in time using last';
}

#?rakudo skip 'lazy lists (loops)'
{
  my $c;
  for 1..Inf {
    $c = $_;
    last if $_ == 6;
  }
  is $c, 6, 'infinte for loop ends in time using last';
}

  

# vim: ft=perl6
