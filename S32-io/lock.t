use Test;
use lib $*PROGRAM.parent(2).add("packages/Test-Helpers");
use Test::Util;

# Tests for IO::Handle.lock/.unlock methods
my $SLEEP = 1 * (%*ENV<ROAST_TIMING_SCALE> || 1);
plan 30;

#?DOES 1
sub test-lock (
    Capture :$args1, Str :$args2 = '', :$fails-to-lock,
    :$open-for-write, :$blocks-write, :$fails-write,
    :$open-for-read,  :$blocks-read,  :$fails-read,
    :$fh is copy, :$file is copy, :$no-close,
) is test-assertion {
    $file = make-temp-file :content<test> unless $file;
    $fh = $file.IO.open(:r) if not $fh and $open-for-read;
    $fh = $file.IO.open(:w) if not $fh and $open-for-write;
    $fh.DEFINITE
        or die 'Provide :open-for-read, :open-for-write, or :fh to test';
    LEAVE $fh.close unless $no-close;

    subtest "$args1.raku(), $args2.raku()" => sub {
        quietly plan $fails-to-lock
            ?? 1
            !! (!$blocks-read and !$fails-read) + $blocks-write + $fails-write
                + $blocks-read + $fails-read + 1;

        if $fails-to-lock {
            # XXX TODO: is it meant to be this way for Windows?
            $*DISTRO.is-win
                ?? skip
                    'locking filehandle in wrong mode does not throw on Windows'
                !! fails-like { $fh.lock: |$args1 }, X::IO::Lock,
                    'fails to lock';
            return;
        }

        $fh.lock: |$args1;

        if $blocks-write {
            is_run qq|
                start try \{
                    my \$fh = '$file'.IO.open(:w);
                    say "LOCKING";
                    \$fh.lock($args2); say "FAILED";
                }
                sleep $SLEEP; say "DONE"
            |, {
                :err(''), :out{
                    not .contains: 'FAILED'
                    and .contains: 'LOCKING'
                    and .contains: 'DONE'
                }
            }, 'we got blocked for writing';
        }

        if $fails-write {
            is_run qq|
                my \$fh = '$file'.IO.open(:w);
                say "LOCKING";
                my \$res = \$fh.lock($args2);
                if \$res ~~ Failure and \$res.exception ~~ X::IO::Lock
                    \{ say "DONE"; exit }
                say "FAILED";
            |, {
                :err(''), :out{
                    not .contains: 'FAILED'
                    and .contains: 'LOCKING'
                    and .contains: 'DONE'
                }
            }, 'we received Failure when locking for writing';
        }

        unless $blocks-read or $fails-read {
            is_run qq|
                my \$fh = '$file'.IO.open(:r);
                say "LOCKING";
                \$fh.lock(:shared, :non-blocking);
                say "SUCCESS";
            |, {
                :err(''), :out{.contains: 'LOCKING' and .contains: 'SUCCESS' }
            }, 'we can still lock as shared';
        }

        if $blocks-read {
            is_run qq|
                start try \{
                    my \$fh = '$file'.IO.open(:r);
                    say "LOCKING";
                    \$fh.lock($args2); say "FAILED";
                }
                sleep $SLEEP; say "DONE"
            |, {
                :err(''), :out{
                    not .contains: 'FAILED'
                    and .contains: 'LOCKING'
                    and .contains: 'DONE'
                }
            }, 'we got blocked for reading';
        }

        if $fails-read {
            is_run qq|
                my \$fh = '$file'.IO.open(:r);
                say "LOCKING";
                my \$res = \$fh.lock($args2);
                if \$res ~~ Failure and \$res.exception ~~ X::IO::Lock
                    \{ say "DONE"; exit }
                say "FAILED";
            |, {
                :err(''), :out{
                    not .contains: 'FAILED'
                    and .contains: 'LOCKING'
                    and .contains: 'DONE'
                }
            }, 'we received Failure when locking for reading';
        }

        $fh.unlock;
        with $file.open(:w) {
            ok .lock, '.unlock removes lock';
            .unlock;
        }
    }
}

test-lock :open-for-read,  :fails-to-lock, args1 => \();
test-lock :open-for-read,  :fails-to-lock, args1 => \(:non-blocking);
test-lock :open-for-read,  :fails-to-lock, args1 => \(:!non-blocking);
test-lock :open-for-read,  :fails-to-lock, args1 => \(:!shared);
test-lock :open-for-read,  :fails-to-lock, args1 => \(:!shared,  :non-blocking);
test-lock :open-for-read,  :fails-to-lock, args1 => \(:!shared, :!non-blocking);

test-lock :open-for-read,  :blocks-write, args1 => \(:shared);
test-lock :open-for-read,  :blocks-write, args1 => \(:shared,  :non-blocking);
test-lock :open-for-read,  :blocks-write, args1 => \(:shared, :!non-blocking);

test-lock :open-for-read,  :fails-write, args2 => ':non-blocking',
    args1 => \(:shared);
test-lock :open-for-read,  :fails-write, args2 => ':non-blocking',
    args1 => \(:shared, :non-blocking);
test-lock :open-for-read,  :fails-write, args2 => ':non-blocking',
    args1 => \(:shared, :!non-blocking);

test-lock :open-for-write, :fails-to-lock, args1 => \(:shared);
test-lock :open-for-write, :fails-to-lock, args1 => \(:shared,  :non-blocking);
test-lock :open-for-write, :fails-to-lock, args1 => \(:shared, :!non-blocking);

test-lock :open-for-write, :blocks-write, :blocks-read,
    args1 => \();
test-lock :open-for-write, :blocks-write, :blocks-read,
    args1 => \(:non-blocking);
test-lock :open-for-write, :blocks-write, :blocks-read,
    args1 => \(:!non-blocking);
test-lock :open-for-write, :blocks-write, :blocks-read,
    args1 => \(:!shared);
test-lock :open-for-write, :blocks-write, :blocks-read,
    args1 => \(:!shared,  :non-blocking);
test-lock :open-for-write, :blocks-write, :blocks-read,
    args1 => \(:!shared, :!non-blocking);

test-lock :open-for-write, :fails-write, :fails-read,
    args2 => ':non-blocking', args1 => \();
test-lock :open-for-write, :fails-write, :fails-read,
    args2 => ':non-blocking', args1 => \(:non-blocking);
test-lock :open-for-write, :fails-write, :fails-read,
    args2 => ':non-blocking', args1 => \(:!non-blocking);
test-lock :open-for-write, :fails-write, :fails-read,
    args2 => ':non-blocking', args1 => \(:!shared, :non-blocking);
test-lock :open-for-write, :fails-write, :fails-read,
    args2 => ':non-blocking', args1 => \(:!shared, :!non-blocking);


{
    my $file = make-temp-file :content<test>;
    my $fh = $file.open: :r; LEAVE $fh.close;
    $fh.lock: :shared, :non-blocking;
    start { sleep $SLEEP; $fh.unlock }
    is_run qq|my \$fh = '$file'.IO.open: :w; \$fh.lock; print "DONE"|, {
        :err(''), :out<DONE>
    }, 'we get the write lock after shared lock is unlocked';
}

{
    my $file = make-temp-file :content<test>;
    my $fh = $file.open: :w; LEAVE $fh.close;
    $fh.lock: :non-blocking;
    start { sleep $SLEEP; $fh.unlock }
    is_run qq|my \$fh = '$file'.IO.open: :r; \$fh.lock: :shared; print "DONE"|, {
        :err(''), :out<DONE>
    }, 'we get the shared lock after exclusive lock is unlocked';
}

subtest 'IO::CatHandle' => {
    plan 13;

    is-deeply IO::CatHandle.new.lock,   Nil, '.lock on zero-handle cat handle';
    is-deeply IO::CatHandle.new.unlock, Nil,
        '.unlock on zero-handle cat handle';

    my $cat = IO::CatHandle.new:
        make-temp-file(:content<foo>).absolute,
        make-temp-file(:content<bar>),
        make-temp-file(:content<ber>).open;

    for ^3 {
      test-lock :fh($cat), :file($cat.path), :fails-to-lock, :no-close,
          args1 => \();
      test-lock :fh($cat), :file($cat.path), :blocks-write,  :no-close,
          args1 => \(:shared);
      test-lock :fh($cat), :file($cat.path),  :no-close,
          args2 => ':non-blocking',
          args1 => \(:shared, :non-blocking);

      $cat.next-handle;
    }

    is-deeply $cat.lock,   Nil, '.lock on exhausted cat handle';
    is-deeply $cat.unlock, Nil, '.unlock on exhausted cat handle';
}

# https://github.com/rakudo/rakudo/issues/3742
subtest 'check leaking of file descriptors with lock/close' => {
    my $p = $*CWD.child("foo1.txt").open(:w);
    isa-ok $p, IO::Handle, 'did the first open work';

    $p.lock; $p.unlock; $p.lock;
    my $descriptor = $p.native-descriptor;
    $p.close;

    my $q = $*CWD.child("foo1.txt").open(:w);
    isa-ok $p, IO::Handle, 'did the second open work';
    is $q.native-descriptor, $descriptor, 'did we not leak';
    $q.close;

    LEAVE {
        $*CWD.child("foo1.txt").unlink;
        $*CWD.child("foo2.txt").unlink;
    }
}

# vim: expandtab shiftwidth=4
