use Test;
use lib $*PROGRAM.parent(2).add("packages/Test-Helpers");
use Test::Util;

plan 43;

# L<S32::IO/IO::Path>

constant @Path-Types
= IO::Path, IO::Path::Cygwin, IO::Path::QNX, IO::Path::Unix, IO::Path::Win32;

my $path = '/foo/bar.txt'.IO;
isa-ok $path, IO::Path, "Str.IO returns an IO::Path";
is IO::Path.new('/foo/bar.txt'), $path,
   "Constructor works without named arguments";

is IO::Path.new(:basename<bar.txt>), IO::Path.new('bar.txt'),
    "Can use either :basename or positional argument";

is IO::Path.new(:dirname</foo>, :basename<bar.txt>).cleanup, $path.cleanup,
    "Can construct path from :dirname and :basename";

# This assumes slash-separated paths, so it will break on, say, VMS

is $path.volume,          '', 'volume';
is $path.dirname,     '/foo', 'dirname';
is $path.basename, 'bar.txt', 'basename';
is $path.parent,    '/foo',    'parent';
is $path.parent.parent, '/',   'parent of parent';
is $path.is-absolute, True,    'is-absolute';
is $path.is-relative, False,   'is-relative';

isa-ok $path.path, Str,      'IO::Path.path returns Str';
isa-ok $path.IO,   IO::Path, 'IO::Path.IO returns IO::Path';

# Try to guess from context that the correct backend is loaded:
#?DOES 2
{
  if $*DISTRO.name eq any <win32 mswin32 os2 dos symbian netware> {
      ok "c:\\".IO.is-absolute, "Win32ish OS loaded (volume)";
      is "/".IO.cleanup, "\\", "Win32ish OS loaded (back slash)"
  }
  elsif $*DISTRO.name eq 'cygwin' {
      ok "c:\\".IO.is-absolute, "Cygwin OS loaded (volume)";
      is "/".IO.cleanup, "/", "Cygwin OS loaded (forward slash)"
  }
  else { # assume POSIX
      nok "c:\\".IO.is-absolute, "POSIX OS loaded (no volume)";
      is "/".IO.cleanup, "/", "POSIX OS loaded (forward slash)"
  }
}

# https://github.com/Raku/old-issue-tracker/issues/4877
# https://github.com/Raku/old-issue-tracker/issues/6200
subtest '.raku.EVAL rountrips' => {
    my @tests = gather {
        .IO.take for q/\x[308]foo|ba"'\''r/, "/foo|\\bar", "/foo\tbar";
        # use spec that is NOT the default for the OS
        ($*DISTRO.is-win ?? IO::Path::Unix !! IO::Path::Win32)
          .new('.', :CWD<foo>).take;

        for @Path-Types {
            .take;
            with .new('/foo', :CWD<bar>) {
                .is-absolute; # set internal `is-absolute` flag, if any
                .take
            }
        }
    }

    plan +@tests;
    for @tests {
        if .DEFINITE {
            subtest "using {.raku}" => {
                plan 4;
                is-path   .raku.EVAL,      $_,      'equivalent object';
                is-deeply .raku.EVAL.path, .path, 'same .path';
                is-deeply .raku.EVAL.CWD,  .CWD,  'same .CWD';
                is-deeply .raku.EVAL.SPEC, .SPEC, 'same .SPEC';
            }
        }
        else {
            is-deeply .raku.EVAL, $_, "new eqv old using {.raku}";
        }
    }
}

# https://github.com/Raku/old-issue-tracker/issues/5265
{
    try IO::Path.new: 'foo', 'bar';
    cmp-ok $!, &[!~~], X::Constructor::Positional,
      'IO::Path.new with wrong args must not claim it only takes named ones';
}

# https://github.com/Raku/old-issue-tracker/issues/5306
{
    is IO::Handle.new(:path('-')).path.gist, '"-".IO', '"-" as the path of an IO::Handle gists correctly';
    is '-'.IO.gist, '"-".IO', '"-".IO gists correctly';
}

# https://github.com/Raku/old-issue-tracker/issues/6111
{
    my $file = ("S32-io-path-RT-130889-test" ~ rand);
    LEAVE $file.IO.unlink;

    my $p1 = $file.IO;
    is-deeply $p1.e, False, 'temporary test file does not exist';

    my $p2 = $file.IO.spurt: "test";
    is-deeply $p1.e, True,
        '.e detects change on filesystem and returns True now';
}

subtest 'IO::Path.ACCEPTS' => { # coverage 2017-03-31 (IO grant)
    my @true = "foo"     => "foo".IO.absolute, "/foo" => "/../foo",
               "////foo" => "////.././/foo",        4 => 4;
    .append: .map: {[.key] => [.value] } with @true; # Make some more Cools

    my @false = "a" => "b", "/a" => "/b", 4 => 5,
                "non-existent-blarg/../foo" => "foo";
    .append: .map: { [.key] => [.value] } with @false; # Make some more Cools
    plan 4 * (@true + @false);

    for @true -> \t {
        is-deeply t.key      ~~ t.value.IO, True,  "{t.key  }    ~~ {t.value}.IO";
        is-deeply t.value    ~~ t.key  .IO, True,  "{t.value}    ~~ {t.key  }.IO";
        is-deeply t.key.IO   ~~ t.value.IO, True,  "{t.key  }.IO ~~ {t.value}.IO";
        is-deeply t.value.IO ~~ t.key  .IO, True,  "{t.value}.IO ~~ {t.key  }.IO";
    }

    for @false -> \t {
        is-deeply t.key      ~~ t.value.IO, False, "{t.key  }    ~~ {t.value}.IO";
        is-deeply t.value    ~~ t.key  .IO, False, "{t.value}    ~~ {t.key  }.IO";
        is-deeply t.key.IO   ~~ t.value.IO, False, "{t.key  }.IO ~~ {t.value}.IO";
        is-deeply t.value.IO ~~ t.key  .IO, False, "{t.value}.IO ~~ {t.key  }.IO";
    }
}

{ # .Str tests
    is-deeply '.'.IO.Str, '.', 'Str does not include CWD [relative path]';
    is-deeply '/'.IO.Str, '/', 'Str does not include CWD [absolute path]';
    is-deeply IO::Path.new(
        :volume<foo:>, :dirname<bar>, :basename<ber>, :SPEC(IO::Spec::Win32.new)
    ).Str, 'foo:\bar\ber', 'Str does not include CWD [multi-part .new()]'
}

subtest '.add' => {
    plan 4 * my @tests = gather for 'bar', '../bar', '../../bar', '.', '..' {
        take %(:orig</foo/>, :with($_), :res("/foo/$_"));
        take %(:orig<foo/>,  :with($_), :res("foo/$_"));
    }

    for @tests -> (:$orig, :$with, :$res) {
        for IO::Path::Unix, IO::Path::Win32, IO::Path::Cygwin, IO::Path::QNX {
            is-path .new($orig).add($with), .new($res),
                "$orig add $with => $res {.gist}";
        }
    }
}

subtest '.resolve' => {
    plan 5 + @Path-Types;

    my $root = make-temp-dir;
    sub p { $root.add: $^path }
    .&p.mkdir for 'level1a', 'level1b/level2a', 'level1c/level2b/level3a';

    is-deeply p('level1a/../not-there').resolve.absolute,
              p('not-there').absolute,
        ".resolve() cleans up paths it can't resolve";

    fails-like { p('level1a/../not-there/foo').resolve(:completely) },
        X::IO::Resolve, '.resolve(:completely) fails with X::IO::Resolve';

    is-deeply
        p('level1a/../level1b/level2a/../../level1c/level2b/'
            ~ '../level2b/level3a').resolve.absolute,
        p('level1c/level2b/level3a').absolute,
        ".resolve() cleans up paths it can resolve";

    is-deeply
        p('level1a/../level1b/level2a/../../level1c/level2b/'
            ~ '../level2b/level3a').resolve(:completely).absolute,
        p('level1c/level2b/level3a').absolute,
        ".resolve(:completely) cleans up paths it can resolve";

    is-deeply p('level1a/../not-there').resolve(:completely).absolute,
              p('not-there').absolute,
        '.resolve(:completely) succeeds even when last part does not exist';

    for @Path-Types.map(*.new: 'foo') {
        # windows friendly path types include the volume
        my $expected-cwd = $_.^name ~~ any(<IO::Path IO::Path::Win32 IO::Path::Cygwin>)
            ?? .CWD.IO.volume ~ .SPEC.dir-sep
            !! .SPEC.dir-sep;
        is .resolve.CWD, $expected-cwd,
            ".resolve sets CWD to SPEC's dir-sep for {.raku}"
    }
}

subtest '.link' => {
    plan 2 * 5; # $n tests for method and sub forms
    for IO::Path.^lookup('link'), &link -> &l {
        my $target = make-temp-file;
        my $link   = make-temp-file;
        fails-like { l($target, $link) }, X::IO::Link, :$target, :name($link),
            'fail when target does not exist';

        $target.spurt: 'foo';
        is-deeply l($target, $link),   True, 'can create links';
        is-deeply ($link ~~ :e & :!l), True,
            'created link filetests True for .e and False for .l';
        is-deeply $link.slurp, 'foo', 'slurping from a link gives right data';

        fails-like { l($target, $link) }, X::IO::Link, :$target, :name($link),
            'fail when link already exists';
    }
}

subtest '.sibling' => {
    my @tests = 'foo' => 'bar', '/foo' => '/bar', '../foo' => '../bar',
        'C:/foo' => 'C:/bar', 'C:/foo/../meow' => 'C:/foo/../bar',
        '/' => '/bar', './' => 'bar', '/foo/' => '/bar', '/foo/.' => '/foo/bar';
    plan 1 + @tests * @Path-Types;

    for @tests -> (:key($start-path), :value($res-path)) {
        for @Path-Types -> $Path {
            is-path $Path.new($start-path).sibling('bar'), $Path.new($res-path),
                "$Path.raku() with $start-path.raku()";
        }
    }

    is-path IO::Path::Win32.new('C:/').sibling('bar'),
        IO::Path::Win32.new('C:/bar'), '"C:/" with IO::Path::Win32';
}

subtest '.IO on :U gives right class' => {
    plan +@Path-Types;
    cmp-ok $_, '===', .IO, .raku for @Path-Types;
}

subtest '.gist' => {
    my @tests = (
      'foo', '-', 'bar/ber', ｢foo/bar\ber.txt｣, 'I ♥ Raku'
    ).map: -> $root {
        ($root, "/$root").map( -> $path {
            @Path-Types.map(*.new: $path).Slip
        }).Slip
    }
    plan +@tests;

    { # make $*CWD different from what it was when we made the paths
        temp $*CWD = make-temp-dir;

        for @tests {
            my $gist = .is-absolute ?? .absolute !!.path;
            like .gist, /$gist/, $_;
        }
    }
}

subtest 'combiners on "/" do not interfere with absolute path detection' => {
    plan +@Path-Types;
    is-deeply .is-absolute, True, .raku for @Path-Types.map: *.new: "/\x[308]";
}

subtest '.parts attribute' => {
    plan 5 + 6*@Path-Types;

    sub check-parts($in, $desc, *%parts) {
        subtest 'parts match' => {
            plan 1 + %parts;
            does-ok $in, Associative, 'parts does the Associative role';
            is-deeply $in{$_}, %parts{$_}, "$_ is correct" for %parts.keys;
        }
    }

    for @Path-Types {
        check-parts .new('foo').parts, "foo {.raku}",
            :basename<foo>, :dirname<.>, :volume('');

        check-parts .new('./foo').parts, "./foo {.raku}",
            :basename<foo>, :dirname<.>, :volume('');

        check-parts .new('bar/foo').parts, "bar/foo {.raku}",
            :basename<foo>, :dirname<bar>, :volume('');

        check-parts .new('/bar/foo').parts, "/bar/foo {.raku}",
            :basename<foo>, :dirname</bar>, :volume('');

        my $p = .new('/').parts;
        check-parts $p, "/ {.raku}", :dirname</>, :volume('');
        cmp-ok $p<basename>, 'eq', <\ />.any, "/ {.raku} (basename)";
    }

    check-parts IO::Path::Win32.new('C:foo').parts, "C:foo",
        :basename<foo>,:dirname<.>,:volume<C:>;

    check-parts IO::Path::Win32.new('C:./foo').parts, "C:./foo",
        :basename<foo>,:dirname<.>,:volume<C:>;

    check-parts IO::Path::Win32.new('C:bar/foo').parts, "C:bar/foo",
        :basename<foo>,:dirname<bar>,:volume<C:>;

    check-parts IO::Path::Win32.new('C:/bar/foo').parts, "C:/bar/foo",
        :basename<foo>,:dirname</bar>,:volume<C:>;

    check-parts IO::Path::Win32.new('C:/').parts, "C:/",
        :basename(｢\｣ | ｢/｣),:dirname(｢\｣ | ｢/｣),:volume<C:>;
}

subtest '.SPEC attribute' => {
    plan 5;
    temp $*SPEC = my class Meow is IO::Spec {}

    is-deeply IO::Path.new('.').SPEC, $*SPEC, '.new defaults to $*SPEC';
    is-deeply '.'.IO                .SPEC, $*SPEC, '.IO  defaults to $*SPEC';

    my class Foos is IO::Spec {}
    is-deeply IO::Path.new('.', :SPEC(Foos)).SPEC, Foos,
        '.new accepts :SPEC param';
    is-deeply '.'.IO(:SPEC(Foos)).SPEC, $*SPEC, '.IO ignores :SPEC param';

    throws-like { '.'.IO.SPEC = my class :: is IO::Spec {} }, X::Assignment::RO,
        'cannot change .SPEC by assignment';
}

subtest '.CWD attribute' => {
    plan 5;
    temp $*CWD = make-temp-dir;

    # It is by design that .CWD returns stringified IO::Path
    is-deeply IO::Path.new('.').CWD, $*CWD.Str, '.new defaults to $*CWD';
    is-deeply '.'.IO           .CWD, $*CWD.Str, '.IO  defaults to $*CWD';

    my $cwd = make-temp-dir;
    is-deeply IO::Path.new('.', :CWD($cwd)).CWD, $cwd.Str,
        '.new accepts :CWD param';
    is-deeply '.'.IO(:CWD($cwd)).CWD, $*CWD.Str, '.IO ignores :CWD param';

    throws-like { '.'.IO.CWD = make-temp-dir.Str }, X::Assignment::RO,
        'cannot change .CWD by assignment';
}

subtest '.path attribute' => {
    plan 3;
    my $str-path1 = make-temp-dir.absolute ~ '/foo.txt';
    my $path1     = IO::Path.new: $str-path1;

    my $str-path2 = $str-path1;
    my $path2     = $str-path1.IO;

    my $str-path3 = IO::Spec::Win32.join: 'foo', 'bar', 'ber';
    my $path3     = IO::Path.new: :volume<foo> :dirname<bar> :basename<ber>
                                  :SPEC(IO::Spec::Win32);

    # we change dirs because unlike .absolute/.relative, .path is
    # not affected by directory changes
    indir make-temp-dir, {
        is-deeply $path1.path, $str-path1, '.path of .new($path)';
        is-deeply $path2.path, $str-path2, '.path of $path.IO';
        is-deeply $path3.path, $str-path3, '.path of .new(from parts)';
    }
}

subtest '.Numeric and related methods' => {
    plan 25;
    my $p = make-temp-file;
    is-deeply    $p.add('3.5' ).Numeric, 3.5,  'Rat (.Numeric)';
    is-deeply    $p.add('3e5' ).Numeric, 3e5,  'Num (.Numeric)';
    is-deeply    $p.add('305' ).Numeric, 305,  'Int (.Numeric)';
    is-deeply    $p.add('1+1i').Numeric, 1+1i, 'Complex (.Numeric)';
    fails-like { $p.add('mew' ).Numeric }, X::Str::Numeric,
        'non-numeric  (.Numeric)';

    # The following should fall out out of IO::Path being Cool and can be
    # handled via .Numeric method, without requiring individual impls:

    is-deeply    $p.add('3.5' ).Rat, 3.5,   'Rat (.Rat)';
    is-deeply    $p.add('3e1' ).Rat, 30.0,  'Num (.Rat)';
    is-deeply    $p.add('305' ).Rat, 305.0, 'Int (.Rat)';
    is-deeply    $p.add('3+0i').Rat, 3.0,   'Complex (.Rat)';
    fails-like { $p.add('mew' ).Rat }, X::Str::Numeric, 'non-numeric (.Rat)';

    is-deeply    $p.add('3.5' ).Num, 35e-1, 'Rat (.Num)';
    is-deeply    $p.add('3e1' ).Num, 30e0,  'Num (.Num)';
    is-deeply    $p.add('305' ).Num, 305e0, 'Int (.Num)';
    is-deeply    $p.add('3+0i').Num, 3e0,   'Complex (.Num)';
    fails-like { $p.add('mew' ).Num }, X::Str::Numeric, 'non-numeric (.Num)';

    is-deeply    $p.add('3.5' ).Int, 3,   'Rat (.Int)';
    is-deeply    $p.add('3e1' ).Int, 30,  'Num (.Int)';
    is-deeply    $p.add('305' ).Int, 305, 'Int (.Int)';
    is-deeply    $p.add('3+0i').Int, 3,   'Complex (.Int)';
    fails-like { $p.add('mew' ).Int }, X::Str::Numeric, 'non-numeric (.Int)';

    is-deeply    $p.add('3.5' ).FatRat, 3.5   .FatRat, 'Rat (.FatRat)';
    is-deeply    $p.add('3e1' ).FatRat, 3e1   .FatRat, 'Num (.FatRat)';
    is-deeply    $p.add('305' ).FatRat, 305   .FatRat, 'Int (.FatRat)';
    is-deeply    $p.add('3+0i').FatRat, <3+0i>.FatRat, 'Complex (.FatRat)';
    fails-like { $p.add('mew' ).FatRat }, X::Str::Numeric,
        'non-numeric (.FatRat)';
}

subtest 'Ensure <0> can be used to make an IO::Path' => {
    my @nums = <0>, <0.0>, <0e0>, < 0/1>, < 0+0i>;
    plan @nums * (1 + @Path-Types);

    for @nums -> $num {
        lives-ok { .new: $num }, "$num.raku() with {.raku}" for @Path-Types;
        lives-ok {    $num.IO }, "$num.raku() with .IO coercer";
    }
}

subtest '.parent(Int)' => {
    plan 8*my @paths :=
        (<foo/bar/ber.txt  /foo/bar/ber.txt  .  ../  C:/foo/bar/ber.txt>, ｢\foo\bar\ber｣).flat.map({
            IO::Path::Unix.new($_),
            IO::Path::Win32.new($_),
            IO::Path::Cygwin.new($_),
            IO::Path::QNX.new($_),
        }).flat.List;

    for @paths -> $p is raw {
        my $d := $p.raku;
        dies-ok { $p.parent(-1) }, 'negative parents handled ok';
        is-deeply $p.parent(0), $p, "0 $d";
        is-deeply $p.parent(1), $p.parent, "1 $d";
        is-deeply $p.parent(2), $p.parent.parent, "2 $d";

        is-deeply $p.parent(3), $p.parent.parent.parent, "3 $d";
        is-deeply $p.parent(4), $p.parent.parent.parent.parent, "4 $d";
        is-deeply $p.parent(5), $p.parent.parent.parent.parent.parent, "5 $d";
        is-deeply $p.parent(6), $p.parent.parent.parent.parent.parent.parent, "6 $d";
    }
}

{
    my $io := $?FILE.IO;
    ok $io.created < now, 'was this script created before now';
    ok $io.modified < now, 'was this script modified before now';
    ok $io.accessed < now, 'was this script accessed before now';
    ok $io.changed < now, "was this script's meta-date changed before now";
}

# vim: expandtab shiftwidth=4
