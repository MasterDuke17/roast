use MONKEY-TYPING;

use Test;

plan 3;

=begin kwid

Difficulty using a rule in a method of Str.

=end kwid

class C is Str {
    method meth1 () {
        if ("bar" ~~ m/<-[a]>/) {
            "worked";
        } else {
            "didnt";
        }
    }
}

is(C.new.meth1(),"worked",'m/<-[a]>/ in method in C (is Str)');

augment class Str {
    method meth2 () {
        if ("bar" ~~ m/<-[a]>/) {
            "worked";
        } else {
            "didnt";
        }
    }
}

is(Str.new.meth2(),"worked",'m/<-[a]>/ in method in Str');

augment class Str {
    method meth3 () {
        if ("bar" ~~ m/<[a]>/) {
            "worked";
        } else {
            "didnt";
        }
    }
}

is(Str.new.meth3(),"worked",'m/<[a]>/ in method in Str');

# vim: expandtab shiftwidth=4
