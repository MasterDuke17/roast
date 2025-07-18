use Test;
use lib $*PROGRAM.parent(2).add: 'packages/Test-Helpers';
use Test::Util;

plan 143;

{
    my int $x;
    is $x, 0, 'int default value';
    is $x + 1,  1, 'can do + with int';
    is $x - 1, -1, 'can do - with int';
}

{
    my uint $x;
    is $x, 0, 'uint default value';
    is $x + 1,  1, 'can do + with uint';
    is $x - 1, -1, 'can do - with uint';
}

{
    my num $num;
    is-deeply $num, 0e0, 'num default value';
    $num = 3e0;
    ok $num * 2e0 == 6e0, 'can do basic math with num';
}

{
    my str $str;
    is $str, '', 'str default value';
    my str $s2 = 'foo';
    is $s2 ~ $s2, 'foofoo', 'string concatenation with native strings';
}

{
    multi f(int $x) { 'int' }
    multi f(Int $x) { 'Int' }
    multi f(num $x) { 'num' }
    multi f(Num $x) { 'Num' }
    multi f(str $x) { 'str' }
    multi f(Str $x) { 'Str' }
    my int $int = 3;
    my Int $Int = 4;
    my num $num = 5e0;
    my Num $Num = 6e0;
    my str $str = '7';
    my Str $Str = '8';
    is f($int), 'int', 'can identify native type with multi dispatch (int)';
    is f($Int), 'Int', 'can identify non-native type with multi dispatch (Int)';
    is f($num), 'num', 'can identify native type with multi dispatch (num)';
    is f($Num), 'Num', 'can identify non-native type with multi dispatch (Num)';
    is f($str), 'str', 'can identify native type with multi dispatch (str)';
    is f($Str), 'Str', 'can identify non-native type with multi dispatch (Str)';

    is $int * $Int, 12, 'can do math with mixed native/boxed ints';
    is-approx $num * $Num, 30e0, 'can do math with mixed native/boxed nums';
    is $str ~ $Str, '78', 'can concatenate native and boxed strings';
}

{
    # these tests are a bit pointless, since is() already shows that boxing
    # works. Still doesn't hurt to test it with explicit type constraints
    sub g(Int $x) { $x * 2 }
    my int $i = 21;
    is g($i), 42, 'routine-entry int autoboxing';

    sub h(int $x) { $x div 2 }
    my Int $I = 84;
    is h($I), 42, 'routine-entry Int autounboxing';
}

{
    my int $x = 2;
    is $x.gist, 2, 'can call method on a native int';
    my $gist = ($x = 3).gist;
    is $gist, 3, 'Can call a method on the result of assignment to int-typed var';
}

# methods on native type objects
# https://github.com/Raku/old-issue-tracker/issues/2537
{
    isa-ok int, Mu, 'int ~~ Mu';
    is num.gist, '(num)', 'num.gist';
    nok str.defined, 'str.defined';
}

{
    sub slurpy(*@a) {
        @a.join(' ');
    }
    my int $i = 42;
    my str $s = 'roads';
    is slurpy($i, $s), '42 roads', 'can bind native vars to slurpy arrays';
}

# https://github.com/Raku/old-issue-tracker/issues/2519
{
    my int $x;
    my num $y;
    is-deeply $x, 0,   'initialization of native int';
    is-deeply $y, 0e0, 'initialization of native num';
}

# https://github.com/Raku/old-issue-tracker/issues/2541
{
    my int $x;
    ($x) = (5);
    is $x, 5, 'did we assign $x';
    is $x.WHAT, Int, 'WHAT boxes value in native variable';
}

# https://github.com/Raku/old-issue-tracker/issues/3350
{
    my @j;
    my int $j = 42;
    lives-ok { @j.push($j) }, 'can push native int to an array (1)';
    is @j[0], 42, 'can push native int to an array (2)';
}

{
    my int   $i   = 1;
    my int64 $i64 = 2;
    my int32 $i32 = 3;
    my int16 $i16 = 4;
    my int8  $i8  = 5;
    my $alias;

    $alias := $i;
    $alias++;
    is $i, 2, 'Bound alias to int native works';

    $alias := $i64;
    $alias++;
    is $i64, 3, 'Bound alias to int64 native works';

    $alias := $i32;
    $alias++;
    is $i32, 4, 'Bound alias to int32 native works';

    $alias := $i16;
    $alias++;
    is $i16, 5, 'Bound alias to int16 native works';

    $alias := $i8;
    $alias++;
    is $i8, 6, 'Bound alias to int8 native works';
}

{
    my uint   $i   = 1;
    my uint64 $i64 = 2;
    my uint32 $i32 = 3;
    my uint16 $i16 = 4;
    my uint8  $i8  = 5;
    my $alias;

    $alias := $i;
    $alias++;
    is $i, 2, 'Bound alias to uint native works';

    $alias := $i64;
    $alias++;
    is $i64, 3, 'Bound alias to uint64 native works';

    $alias := $i32;
    $alias++;
    is $i32, 4, 'Bound alias to uint32 native works';

    $alias := $i16;
    $alias++;
    is $i16, 5, 'Bound alias to uint16 native works';

    $alias := $i8;
    $alias++;
    is $i8, 6, 'Bound alias to uint8 native works';
}

{
    my num   $n   = 1e0;
    my num64 $n64 = 2e0;
    my num32 $n32 = 3e0;
    my $alias;

    $alias := $n;
    $alias = 2e0;
    is $n, 2e0, 'Bound alias to num native works';

    $alias := $n64;
    $alias = 3e0;
    is $n64, 3e0, 'Bound alias to num64 native works';

    $alias := $n32;
    $alias = 4e0;
    is $n32, 4e0, 'Bound alias to num32 native works';
}

# https://github.com/MoarVM/MoarVM/issues/393

{
    #?rakudo.js 3 todo 'the values get accidentally sign-extended'
    is class :: { has uint8  $.x; }.new( x => 2** 8-1 ).x, 2**8 -1, 'uint8 attributes don\'t get sign-extended';
    is class :: { has uint16 $.x; }.new( x => 2**16-1 ).x, 2**16-1, 'uint16 attributes don\'t get sign-extended';
    is class :: { has uint32 $.x; }.new( x => 2**32-1 ).x, 2**32-1, 'uint32 attributes don\'t get sign-extended';
    #?rakudo.jvm todo 'the value gets sign-extended'
    #?rakudo.moar todo 'the value gets sign-extended'
    #?rakudo.js skip 'Cannot unbox 64 bit wide bigint'
    is class :: { has uint64 $.x; }.new( x => 2**64-1 ).x, 2**64-1, 'uint64 attributes don\'t get sign-extended';
}

# https://github.com/Raku/old-issue-tracker/issues/3678
dies-ok { EVAL 'my int $x = Int;' }, '"my int $x = Int" dies';
dies-ok { EVAL 'my num $x = Num;' }, '"my num $x = Num" dies';
dies-ok { EVAL 'my str $x = Str;' }, '"my str $x = Str" dies';

# https://github.com/Raku/old-issue-tracker/issues/3739
{
    my num $a;
    is-deeply $a, 0e0, "num defaults to 0e0";
    my num32 $b;
    is-deeply $b, 0e0, "num32 defaults to 0e0";
    my num64 $c;
    is-deeply $c, 0e0, "num64 defaults to 0e0";
}

# https://github.com/Raku/old-issue-tracker/issues/3739
{
    my num $d = 42e0;
    is-deeply $d, 42e0, "assign 42e0 to num";
    my num32 $e = 43e0;
    is-deeply $e, 43e0, "assign 43e0 to num32";
    my num64 $f = 44e0;
    is-deeply $f, 44e0, "assign 44e0 to num64";
}

{
    sub want-int(int $x) { }
    sub want-num(num $x) { }
    dies-ok { EVAL 'my num $y = 4e2; want-int($y)' }, 'Passing num to int parameter dies';
    dies-ok { EVAL 'my $y = 4e2; want-int($y)' }, 'Passing Num to int parameter dies';
    dies-ok { EVAL 'my int $y = 42; want-num($y)' }, 'Passing int to num parameter dies';
    dies-ok { EVAL 'my $y = 42; want-num($y)' }, 'Passing Int to num parameter dies';
}

{
    my int64 $i64;
    is $i64, 0, 'int64 starts off as 0';

    my int32 $i32;
    is $i32, 0, 'int32 starts off as 0';

    my int16 $i16;
    is $i16, 0, 'int16 starts off as 0';

    my int8 $i8;
    is $i8, 0, 'int8 starts off as 0';

    $i8 = 42;
    is $i8, 42, 'can assign in-range value to int8';
    $i8 = 131;
    #?rakudo.jvm todo 'native int does not truncate, yet'
    is $i8, -125, 'assigning out-of-range value to int8 truncates';

    $i16 = 342;
    is $i16, 342, 'can assign in-range value to int16';
    $i16 = 32770;
    #?rakudo.jvm todo 'native int does not truncate, yet'
    is $i16, -32766, 'assigning out-of-range value to int16 truncates';

    $i32 = 32771;
    is $i32, 32771, 'can assign in-range value to int32';
    $i32 = 24294967280;
    #?rakudo.jvm todo 'native int does not truncate, yet'
    is $i32, -1474836496, 'assigning out-of-range value to int32 truncates';
}

{
    my uint64 $u64;
    is $u64, 0, 'uint64 starts off as 0';

    my uint32 $u32;
    is $u32, 0, 'uint32 starts off as 0';

    my uint16 $u16;
    is $u16, 0, 'uint16 starts off as 0';

    my uint8 $u8;
    is $u8, 0, 'uint8 starts off as 0';

    $u8 = 42;
    is $u8, 42, 'can assign in-range value to uint8';
    $u8 = 259;
    #?rakudo.jvm todo 'native int does not truncate, yet'
    is $u8, 3, 'assigning out-of-range value to uint8 truncates';

    $u16 = 342;
    is $u16, 342, 'can assign in-range value to uint16';
    $u16 = 65540;
    #?rakudo.jvm todo 'native int does not truncate, yet'
    is $u16, 4, 'assigning out-of-range value to uint16 truncates';

    $u32 = 32771;
    is $u32, 32771, 'can assign in-range value to uint32';
    $u32 = 4294967299;
    #?rakudo.jvm todo 'native int does not truncate, yet'
    is $u32, 3, 'assigning out-of-range value to uint32 truncates';
}

{
    sub n64(num64 $i) {
        is $i, 4e2, 'called num64 sub successfully';
    }
    sub n32(num32 $i) {
        is $i, 4e2, 'called num32 sub successfully';
    }
    n64(4e2);
    n32(4e2);

    sub i64(int64 $i) {
        is $i, 42, 'called int64 sub successfully';
    }
    sub i32(int32 $i) {
        is $i, 42, 'called int32 sub successfully';
    }
    sub i16(int16 $i) {
        is $i, 42, 'called int16 sub successfully';
    }
    sub i8(int8 $i) {
        is $i, 42, 'called int8 sub successfully';
    }
    i64(42);
    i32(42);
    i16(42);
    i8(42);

    #?DOES 1
    sub i32_o(int32 $i) {
        isnt $i, 2147483650, 'sub with int32 arg will see it truncated';
    }
    #?DOES 1
    sub i16_o(int16 $i) {
        isnt $i, 32770, 'sub with int16 arg will see it truncated';
    }
    #?DOES 1
    sub i8_o(int8 $i) {
        isnt $i, 257, 'sub with int8 arg will see it truncated';
    }
    #?rakudo.jvm 3 todo 'native int args do not truncate, yet'
    i32_o(2147483650);
    i16_o(32770);
    i8_o(257);
}

# https://github.com/Raku/old-issue-tracker/issues/3779
{
    my int32 $i32 = 2 ** 32 - 1;
    #?rakudo.jvm todo 'signed/unsigned native ints'
    isnt $i32, 4294967295, 'cannot store 2**32 - 1 in a signed int32';
    my uint32 $u32 = 2**32 - 1;
    is $u32, 4294967295, 'can store 2**32 - 1 in an unsigned int32';
    $u32 = 2 ** 33;
    #?rakudo.jvm 2 todo 'signed/unsigned native ints'
    isnt $u32, 8589934592, 'cannot store 2**33 in an unsigned uint32';
    $u32 = 2 ** 63;
    ok $u32 >= 0, 'cannot make a uint32 go negative by overflowing it';

    my int16 $i16 = 2 ** 16 - 1;
    #?rakudo.jvm todo 'signed/unsigned native ints'
    isnt $i16, 65535, 'cannot store 2**16 - 1 in a signed int16';
    my uint16 $u16 = 2**16 - 1;
    is $u16, 65535, 'can store 2**16 - 1 in an unsigned int16';
    $u16 = 2 ** 33;
    #?rakudo.jvm 2 todo 'signed/unsigned native ints'
    isnt $u16, 8589934592, 'cannot store 2**33 in an unsigned uint16';
    $u16 = 2 ** 63;
    ok $u16 >= 0, 'cannot make a uint16 go negative by overflowing it';

    my int8 $i8 = 2 ** 8 - 1;
    #?rakudo.jvm todo 'signed/unsigned native ints'
    isnt $i8, 255, 'cannot store 2**8 - 1 in a signed int8';
    my uint8 $u8 = 2**8 - 1;
    is $u8, 255, 'can store 2**8 - 1 in an unsigned int8';
    $u8 = 2 ** 33;
    #?rakudo.jvm 2 todo 'signed/unsigned native ints'
    isnt $u8, 8589934592, 'cannot store 2**33 in an unsigned uint8';
    $u8 = 2 ** 63;
    ok $u8 >= 0, 'cannot make a uint8 go negative by overflowing it';
}

# https://github.com/Raku/old-issue-tracker/issues/4989
# uint increment in sink context
{
    sub d { "++ on uint$^n overflows to 0 in sink context" }
    my uint8  $uint8  = 0xff;
    $uint8++;
    #?rakudo.jvm todo "uint8 increment in sink context doesn't work"
    is($uint8,  0, d 8);
    my uint16 $uint16 = 0xffff;
    $uint16++;
    #?rakudo.jvm todo "uint16 increment in sink context doesn't work"
    is($uint16, 0, d 16);
    my uint32 $uint32 = 0xffff_ffff;
    $uint32++;
    #?rakudo.jvm todo "uint32 increment in sink context doesn't work"
    is($uint32, 0, d 32);
    my uint64 $uint64 = 0xffff_ffff_ffff_ffff;
    $uint64++;
    is($uint64, 0, d 64);
}

# https://github.com/Raku/old-issue-tracker/issues/5207
#?rakudo.jvm todo 'Expected a native int argument for $a; works standalone, probably wrong multi selected'
{
    group-of 13 => 'using native types as named parameters' => {
        eval-lives-ok '-> int    :$x { $x == 1   or die }(:x( 1 ))', 'int   ';
        eval-lives-ok '-> int8   :$x { $x == 1   or die }(:x( 1 ))', 'int8  ';
        eval-lives-ok '-> int16  :$x { $x == 1   or die }(:x( 1 ))', 'int16 ';
        eval-lives-ok '-> int32  :$x { $x == 1   or die }(:x( 1 ))', 'int32 ';
        eval-lives-ok '-> uint   :$x { $x == 1   or die }(:x( 1 ))', 'uint  ';
        eval-lives-ok '-> uint8  :$x { $x == 1   or die }(:x( 1 ))', 'uint8 ';
        eval-lives-ok '-> uint16 :$x { $x == 1   or die }(:x( 1 ))', 'uint16';
        eval-lives-ok '-> uint32 :$x { $x == 1   or die }(:x( 1 ))', 'uint32';
        eval-lives-ok '-> num    :$x { $x == 1e0 or die }(:x(1e0))', 'num   ';
        eval-lives-ok '-> num32  :$x { $x == 1e0 or die }(:x(1e0))', 'num32 ';

        eval-lives-ok '-> int64  :$x { $x == 1   or die }(:x( 1 ))', 'int64 ';
        eval-lives-ok '-> uint64 :$x { $x == 1   or die }(:x( 1 ))', 'uint64';
        eval-lives-ok '-> num64  :$x { $x == 1e0 or die }(:x(1e0))', 'num64 ';
    }
}

{
    #?rakudo.jvm todo 'does not die, gives 7766279631452241919'
    throws-like ｢sub (int $x) { say $x }(99999999999999999999)｣, Exception,
        'a too large argument for a native parameter should throw';
}

# https://github.com/Raku/old-issue-tracker/issues/3738
subtest 'meta-assign op with native nums' => {
    plan 2;

    is-approx do {
        my num32 @arr = 1.1e0, 1.2e0, 1.3e0;
        my num32 $s = 0e0;
        for @arr { $s += $_ }
        $s
    }, 3.6, 'meta-assigning into inited num';

    is-approx do {
        my num32 @arr = 1.1e0, 1.2e0, 1.3e0;
        my num32 $s;
        for @arr { $s += $_ }
        $s
    }, 3.6000001430511475e0, 'meta-assigning into UN-inited num';
}

# R#2533
{
    my int @a = 1,2,3;
    ok @a > 2,  'numification of int array works for > 2';
    nok @a < 3, 'numification of int array works for < 3';
}

# R#2525
{
    my int @a = 1,2,3;
    my $i = 0;
    throws-like { @a[$i-1] }, X::OutOfRange, 'do we check for negative indices';
}

# GH#4485 https://github.com/rakudo/rakudo/issues/4485
{
    for Real, Numeric -> \num-role {
       for int, int8, int16, int32, int64,
           uint, uint8, uint16, uint32, uint64,
           byte, num, num32, num64
       -> \native-type {
           does-ok native-type, num-role,  native-type.^name ~ " does " ~ num-role.^name;
       }
    }

    does-ok str, Stringy, "str does Stringy";
}

# vim: expandtab shiftwidth=4
