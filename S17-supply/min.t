use Test;
use lib $*PROGRAM.parent(2).add("packages/Test-Helpers");
use Test::Tap;

plan 10;

dies-ok { Supply.min }, 'can not be called as a class method';
dies-ok { Supply.new.min(23) }, 'must be code if specified';

for ThreadPoolScheduler.new, CurrentThreadScheduler -> $*SCHEDULER {
    diag "**** scheduling with {$*SCHEDULER.WHAT.raku}";

    tap-ok Supply.from-list(1..10).min, [1],
      "ascending min works";
    tap-ok Supply.from-list(10...1).min, [10...1],
      "descending min works";
    tap-ok Supply.from-list(("a".."e").Slip,("A".."E").Slip).min(*.uc), ["a"],
      "ascending alpha works";
    tap-ok Supply.from-list("E"..."A",("e".."a").Slip).min(*.lc), [<E D C B A>],
      "descending alpha works";
}

# vim: expandtab shiftwidth=4
