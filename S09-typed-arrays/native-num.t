use Test;

my @num = num, num32;
if $*KERNEL.bits == 64 {
    @num.push:  num64;
}

plan @num * 170 + 8;

# Basic native num array tests.
for @num -> $T {
    my $t = $T.^name;
    diag "Testing $t array";

    ok array[$T] ~~ Positional,         "$t array type is Positional";
    ok array[$T] ~~ Positional[$T],     "$t array type is Positional[$t]";
    ok array[$T].of === $T,             "$t array type .of is $t";
    ok array[$T].new ~~ Positional,     "$t array is Positional";
    ok array[$T].new ~~ Positional[$T], "$t array is Positional[$t]";
    ok array[$T].new.of === $T,         "$t array .of is $t";

    my @a := EVAL "my $t @";
    ok @a ~~ Positional,         "$t array is Positional";
    ok @a ~~ Positional[$T],     "$t array is Positional[$t]";
    ok @a.of === $T,             "$t array .of is $t";
    ok @a.new ~~ Positional,     ".new from $t array is Positional";
    ok @a.new ~~ Positional[$T], ".new from $t array Positional[$t]";
    ok @a.new.of === $T,         ".new from $t array .of is $t";

    my @arr := array[$T].new;
    is @arr.elems,  0, "New $t array has no elems";
    is @arr.end,   -1, "New $t array has end of -1";
    is @arr.Int,    0, "New $t array Int-ifies to 0";
    is +@arr,       0, "New $t array numifies to 0";
    nok @arr,          "New $t array is falsey";
    nok @arr.is-lazy,  "Empty $t array is not lazy";

    is @arr[5],  0e0, "Accessing non-existing on $t array gives 0";
    is @arr.elems, 0, "Elems do not grow just from an access on $t array";

    is-approx (@arr[0] = 4.2e0), 4.2e0, "Can store num in an $t array";
    is-approx @arr[0], 4.2e0, "Can get value from $t array";
    is @arr.elems, 1,  "The elems grew as expected on $t array";
    ok @arr,           "$t array becomes truthy when it has an element";

    @arr[1,2] = 6.9e0, 7.0e0;
    is-approx @arr[1], 6.9e0, "Can get slice-assigned value from $t array (1)";
    is-approx @arr[2], 7.0e0, "Can get slice-assigned value from $t array (2)";
    is @arr.elems, 3,  "The elems grew as expected on $t array";
    is @arr.end,   2,  "The end value matches grown elems on $t array";
    is @arr.Int,   3,  "Int-ifies to grown number of elems on $t array";
    is +@arr,      3,  "Numifies to grown number of elems on $t array";
    nok @arr.is-lazy,  "$t array with values is not lazy";

    is (@arr[^3] = NaN,-Inf,Inf), (NaN,-Inf,Inf),
      "are special IEEE values supported on $t array";

    is-approx (@arr[10] = 10.0e0), 10.0e0,
      "Can assign non-contiguously to $t array";
    is-approx @arr[  9],    0e0, "Elems non-contiguous assign 0 on $t array";
    is-approx @arr[ 10], 10.0e0, "Non-contiguous assignment works on $t array";
    is-approx @arr[*-1], 10.0e0, "Can also get last element on $t array";

    is (@arr = ()), (), "Can clear $t array by assigning empty list";
    is @arr.elems, 0, "Cleared $t array has no elems";
    is @arr.end,  -1, "Cleared $t array has end of -1";
    is @arr.Int,   0, "Cleared $t array Int-ifies to 0";
    is +@arr,      0, "Cleared $t array numifies to 0";
    nok @arr,         "Cleared $t array is falsey";

    @arr = 1e0..50e0;
    is @arr.elems, 50, "Got correct elems from range assign on $t array";
    is-approx @arr[0],   1e0, "Correct elem from range assign on $t array (1)";
    is-approx @arr[49], 50e0, "Correct elem from range assign on $t array (2)";

    ok  @arr[ 0]:exists, ":exists works on $t array (1)";
    ok  @arr[49]:exists, ":exists works on $t array (2)";
    nok @arr[50]:exists, ":exists works on $t array (3)";

    @arr := array[$T].new(4.2e0);
    is @arr.elems,  1, "Correct number of elems set in constructor of $t array";
    is-approx @arr[0], 4.2e0, "Correct elem set by constructor of $t array";

    @arr := array[$T].new(1.0e0,1.5e0,1.2e0,1.6e0);
    is @arr.elems,  4, "Correct number of elems set in constructor of $t array";
    is-approx @arr[0], 1.0e0, "Correct elem set by constructor of $t array (1)";
    is-approx @arr[1], 1.5e0, "Correct elem set by constructor of $t array (2)";
    is-approx @arr[2], 1.2e0, "Correct elem set by constructor of $t array (3)";
    is-approx @arr[3], 1.6e0, "Correct elem set by constructor of $t array (4)";
    @arr[*-1,*-2];

    ok @arr.flat ~~ Seq, "$t array .flat returns a Seq";
    ok @arr.eager === @arr, "$t array .eager returns identity";

#?rakudo skip "borkedness with num and iteration"
{
    diag qq:!a:!c/my $t \$s = 0e0; for @arr { \$s += \$_ }; \$s/ if !
      is EVAL( qq:!a:!c/my $t \$s = 0e0; for @arr { \$s += \$_ }; \$s/ ), 5.3e0,
        "Can iterate over $t array";
}

    $_++ for @arr;
    is-approx @arr[0], 2.0e0, "Mutating for loop on $t array works (1)";
    is-approx @arr[1], 2.5e0, "Mutating for loop on $t array works (2)";
    is-approx @arr[2], 2.2e0, "Mutating for loop on $t array works (3)";
    is-approx @arr[3], 2.6e0, "Mutating for loop on $t array works (4)";

    @arr.map(* *= 2);
    is-approx @arr[0], 4.0e0, "Mutating map on $t array works (1)";
    is-approx @arr[1], 5.0e0, "Mutating map on $t array works (2)";
    is-approx @arr[2], 4.4e0, "Mutating map on $t array works (3)";
    is-approx @arr[3], 5.2e0, "Mutating map on $t array works (4)";

    is @arr.grep(* < 4.5e0).elems, 2, "Can grep a $t array";

    if $t eq 'num32' {
        pass "skipping .grep/.first test for num32 as they will fail" for ^10;
    }
    else {
        is-deeply @arr.grep(5.2e0),      (5.2e0,),    "$t array.grep(Num)";
        is-deeply @arr.grep(5.2e0, :k),  (3,),        "$t array.grep(Num, :k)";
        is-deeply @arr.grep(5.2e0, :kv), (3,5.2e0),   "$t array.grep(Num, :kv)";
        is-deeply @arr.grep(5.2e0, :p), (3 => 5.2e0,),"$t array.grep(Num, :p)";
        is-deeply @arr.grep(5.2e0, :v),  (5.2e0,),    "$t array.grep(Num, :v)";

        is-deeply @arr.first(5.2e0),      5.2e0,      "$t array.grep(Num)";
        is-deeply @arr.first(5.2e0, :k),  3,          "$t array.grep(Num, :k)";
        is-deeply @arr.first(5.2e0, :kv), (3,5.2e0),  "$t array.grep(Num, :kv)";
        is-deeply @arr.first(5.2e0, :p),  3 => 5.2e0, "$t array.grep(Num, :p)";
        is-deeply @arr.first(5.2e0, :v),  5.2e0,      "$t array.grep(Num, :v)";
    }

    is-approx ([+] @arr), 18.6e0, "Can use reduce meta-op on a $t array";

    #?rakudo 2 skip 'cannot approx test Parcels'
    is @arr.values,    (4.0e0,5.0e0,4.4e0,5.2e0), ".values from a $t array";
    is @arr.pairup,  (4.0e0=>5.0e0,4.4e0=>5.2e0), ".pairup from a $t array";
    #?rakudo 6 skip 'nativeint.list loops on itself'
    is @arr.keys,                  ( 0, 1, 2, 3), ".keys from a $t array";
    is @arr.pairs,     (0=>4.0e0,1=>5.0e0,2=>4.4e0,3=>5.2e0), "[$t].pairs";
    is @arr.antipairs, (4.0e0=>0,5.0e0=>1,4.4e0=>2,5.2e0=>3), "[$t].antipairs";
    is @arr.kv, (0,4.0e0,1,5.0e0,2,4.4e0,3,5.2e0), ".kv from a $t array";
    is @arr.pick,         4.0e0|5.0e0|4.4e0|5.2e0, ".pick from a $t array";
    is @arr.roll,         4.0e0|5.0e0|4.4e0|5.2e0, ".roll from a $t array";

    @arr[1] = @arr[0];
    is-deeply @arr.unique.List, (@arr[0],@arr[2],@arr[3]), "$t array.unique";
    is-deeply @arr.repeated.List, (@arr[0],),              "$t array.repeated";
    is-deeply @arr.squish.List, (@arr[0],@arr[2],@arr[3]), "$t array.squish";

    @arr = ();
    throws-like { @arr.pop }, X::Cannot::Empty,
      action => 'pop',
      what   => "array[$t]",
      "Trying to pop an empty $t array dies";
    throws-like { @arr.shift }, X::Cannot::Empty,
      action => 'shift',
      what   => "array[$t]",
      "Trying to shift an empty $t array dies";
    throws-like { @arr[0] := my $a }, Exception,
      message => 'Cannot bind to a native num array',
      "Cannot push non-int/Int to $t array";
    throws-like { @arr[0]:delete }, Exception,
      message => 'Cannot delete from a native num array',
      "Cannot push non-int/Int to $t array";
    throws-like { @arr = 0e0..Inf }, X::Cannot::Lazy,
      action => 'initialize',
      what   => "array[$t]",
      "Trying to initialize a $t array with a right infinite list";
    throws-like { @arr = -Inf..0e0 }, X::Cannot::Lazy,
      action => 'initialize',
      what   => "array[$t]",
      "Trying to initialize a $t array with a left infinite list";

    @arr.push(4.2e0);
    is @arr.elems, 1,  "push to $t array works (1)";
    is-approx @arr[0], 4.2e0, "push to $t array works (2)";
    throws-like { @arr.push('it real good') }, Exception,
      "Cannot push non-num/Num to $t array";

    @arr.push(10.1e0, 10.5e0);
    is @arr.elems, 3, "push multiple to $t array works (1)";
    is-approx @arr[1], 10.1e0,  "push multiple to $t array works (2)";
    is-approx @arr[2], 10.5e0,  "push multiple to $t array works (3)";
    throws-like { @arr.push('omg', 'wtf') }, Exception,
      "Cannot push non-num/Num to $t array (multiple push)";

    @arr.append(4.2e1);
    is @arr.elems, 4,  "append to $t array works (1)";
    is-approx @arr[3], 4.2e1, "append to $t array works (2)";
    throws-like { @arr.append('it real good') }, Exception,
      "Cannot append non-num/Num to $t array";

    @arr.append(10.1e1, 10.5e1);
    is @arr.elems, 6, "append multiple to $t array works (1)";
    is-approx @arr[4], 10.1e1,  "append multiple to $t array works (2)";
    is-approx @arr[5], 10.5e1,  "append multiple to $t array works (3)";
    throws-like { @arr.append('omg', 'wtf') }, Exception,
      "Cannot push non-num/Num to $t array (multiple push)";

    is-approx @arr.pop, 10.5e1, "pop from $t array works (1)";
    is @arr.elems, 5, "pop from $t array works (2)";

    @arr.unshift(-1e0);
    is @arr.elems, 6, "unshift to $t array works (1)";
    is-approx @arr[0],  -1e0, "unshift to $t array works (2)";
    is-approx @arr[1], 4.2e0, "unshift to $t array works (3)";
    throws-like { @arr.unshift('part of the day not working') }, Exception,
      "Cannot unshift non-num/Num to $t array";

    @arr.unshift(-3e0,-2e0);
    is @arr.elems, 8, "unshift multiple to $t array works (1)";
    is-approx @arr[0],  -3e0, "unshift multiple to $t array works (2)";
    is-approx @arr[1],  -2e0, "unshift multiple to $t array works (3)";
    is-approx @arr[2],  -1e0, "unshift multiple to $t array works (4)";
    is-approx @arr[3], 4.2e0, "unshift multiple to $t array works (5)";
    throws-like { @arr.unshift('wtf', 'bbq') }, Exception,
      "Cannot unshift non-num/Num to $t array (multiple unshift)";

    @arr.prepend(-1e1);
    is @arr.elems, 9, "prepend to $t array works (1)";
    is-approx @arr[0], -1e1, "prepend to $t array works (2)";
    is-approx @arr[1], -3e0, "prepend to $t array works (3)";
    throws-like { @arr.prepend('part of the day not working') }, Exception,
      "Cannot prepend non-num/Num to $t array";

    @arr.prepend(-3e1,-2e1);
    is @arr.elems, 11, "prepend multiple to $t array works (1)";
    is-approx @arr[0], -3e1, "prepend multiple to $t array works (2)";
    is-approx @arr[1], -2e1, "prepend multiple to $t array works (3)";
    is-approx @arr[2], -1e1, "prepend multiple to $t array works (4)";
    is-approx @arr[3], -3e0, "prepend multiple to $t array works (5)";
    throws-like { @arr.prepend('wtf', 'bbq') }, Exception,
      "Cannot prepend non-num/Num to $t array (multiple unshift)";

    is-approx @arr.shift, -3e1, "shift from $t array works (1)";
    is @arr.elems, 10, "shift from $t array works (2)";

    @arr = 1e0..10e0;
    my @replaced = @arr.splice(3, 2, 98e0, 99e0, 100e0);
    is @arr.elems, 11, "Number of elems after splice $t array";
    is-approx @arr[2],   3e0, "Splice on $t array did the right thing (1)";
    is-approx @arr[3],  98e0, "Splice on $t array did the right thing (2)";
    is-approx @arr[4],  99e0, "Splice on $t array did the right thing (3)";
    is-approx @arr[5], 100e0, "Splice on $t array did the right thing (4)";
    is-approx @arr[6],   6e0, "Splice on $t array did the right thing (5)";
    is @replaced.elems, 2, "Number of returned spliced values from $t array";
    is-approx @replaced[0],  4e0, "Correct value in splice from $t array (1)";
    is-approx @replaced[1],  5e0, "Correct value in splice from $t array (2)";

    @arr = 1e0..5e0;
    is @arr.Str,  '1 2 3 4 5', ".Str space-separates on $t array";
    is @arr.gist, '[1 2 3 4 5]', ".gist space-separates on $t array";
    is @arr.raku, "array[$t].new(1e0, 2e0, 3e0, 4e0, 5e0)",
      ".raku includes type and num values on $t array";

    is-deeply @arr[^2], array[$T].new(1e0,2e0), 'does slice return same type';
    is-deeply @arr[my $ = ^2], 3e0, 'does slice handle containerized range';

    my &ftest := EVAL qq:!c/sub ftest($t \$a, $t \$b) { \$a + \$b }/;
    @arr = 3.9e0, 0.3e0;
    is-approx ftest(|@arr), 4.2e0, "Flattening $t array in call works";

    @arr = 0e0..^5e0;  # cannot use 0.1e0 because of num32 accuracy issues
    is @arr.join(":"), "0:1:2:3:4", "does join a $t array";

    @arr = ();
    @arr[4] = 22.1e0;
    ok @arr.join(":").starts-with("0:0:0:0:22.1"),  # num32 accurracy issues
      "does emptying a $t array really empty";

    my @holes := array[$T].new;
    @holes[4] = 22.1e0;
    ok @holes.join(":").starts-with("0:0:0:0:22.1"), # num32 accuracy issues
      "does join handle holes in a $t array";

    # Interaction of native num arrays and untyped arrays.
    my @native := array[$T].new(1e0..10e0);
    my @untyped = @native;
    is @untyped.elems,        10, "List-assign $t array to untyped works (1)";
    is-approx @untyped[0],   1e0, "List-assign $t array to untyped works (2)";
    is-approx @untyped[9],  10e0, "List-assign $t array to untyped works (3)";

    @untyped = flat 0e0, @native, 11e0;
    is @untyped.elems, 12,        "List-assign $t array surrounded by lits (1)";
    is-approx @untyped[0],   0e0, "List-assign $t array surrounded by lits (2)";
    is-approx @untyped[5],   5e0, "List-assign $t array surrounded by lits (3)";
    is-approx @untyped[10], 10e0, "List-assign $t array surrounded by lits (4)";
    is-approx @untyped[11], 11e0, "List-assign $t array surrounded by lits (5)";

    my @untyped2 = 21e0..30e0;
    my @native2 := array[$T].new;
    @native2 = @untyped2;
    is @native2.elems,        10, "List-assign array of Num to $t array (1)";
    is-approx @native2[0],  21e0, "List-assign array of Num to $t array (2)";
    is-approx @native2[9],  30e0, "List-assign array of Num to $t array (3)";

    @untyped2.push('C-C-C-C-Combo Breaker!');
    throws-like { @native2 = @untyped2 }, Exception,
      "List-assigning incompatible untyped array to $t array dies";

    my @ssa := array[$T].new(1e0..10e0);
    my @ssb := array[$T].new(1e0..10e0);
    is @ssa ~~ @ssb, True, "Smartmatching same $t arrays works";

    @ssb.push(42e0);
    is @ssa ~~ @ssb, False, "Smartmatching different $t arrays works";

    my @unsorted := array[$T].new(4e0,5e0,1e0,2e0,3e0);
    is @unsorted.sort, "1 2 3 4 5", "Can we sort $t array";

    @unsorted = 1e0,2e0;
    is @unsorted.sort, "1 2", "Can we sort 2-element sorted $t array";

    @unsorted = 2e0,1e0;
    is @unsorted.sort, "1 2", "Can we sort 2-element unsorted $t array";

    @unsorted = 1e0;
    is @unsorted.sort, "1", "Can we sort 1-element $t array";

    @unsorted = ();
    is @unsorted.sort, "", "Can we sort 0-element $t array";
}

# https://github.com/rakudo/rakudo/issues/2912
{
    my @a;
    @a[1] = 1e0;
    my num @b = @a;
    is-deeply @b, (my num @ = 0e0,1e0), 'did we survive the hole';
}

# https://github.com/rakudo/rakudo/issues/5781
{
    my num @a = 1e0,2e0,3e0;
    is-deeply (@a.first = 42e0), 42e0, "can we assign with '.first'";
    is-deeply @a.first, 42e0, "did the assign with '.first' work";

    is-deeply (@a.head = 666e0), 666e0, "can we assign with '.head'";
    is-deeply @a.head, 666e0, "did the assign with '.head' work";

    is-deeply (@a.tail = 137e0), 137e0, "can we assign with '.tail'";
    is-deeply @a.tail, 137e0, "did the assign with '.tail' work";

    is-deeply @a, (my num @ = 666e0,2e0,137e0), 'is the final array correct';
}

# vim: expandtab shiftwidth=4
