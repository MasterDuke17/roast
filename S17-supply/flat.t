use Test;
use lib $*PROGRAM.parent(2).add("packages/Test-Helpers");
use Test::Tap;

plan 16;

for ThreadPoolScheduler.new, CurrentThreadScheduler -> $*SCHEDULER {
    diag "**** scheduling with {$*SCHEDULER.WHAT.raku}";

    tap-ok Supply.from-list( [1,2],[3,4,5] ).flat,
      [1..5], "On demand publish with flat";

    my $s = Supplier.new;
    my $f = $s.Supply.flat;

    my $seen1 = [];
    my $t1 = $f.tap( { $seen1.push: $_ } );
    $s.emit([1,2]);
    is $seen1, [1,2], 'did we get the first emit (1)';

    my $seen2 = [];
    my $t2 = $f.tap( { $seen2.push: $_ } );
    $s.emit([3,4]);
    is $seen1, [1,2,3,4], 'did we get the second emit (1)';
    is $seen2, [3,4],     'did we get the second emit (2)';

    $t1.close;
    $s.emit([5,6]);
    is $seen1, [1,2,3,4], 'did we get the third emit (1)';
    is $seen2, [3,4,5,6], 'did we get the third emit (2)';

    $t2.close;
    $s.emit([7,8]);
    is $seen1, [1,2,3,4], 'did we not get the fourth emit (1)';
    is $seen2, [3,4,5,6], 'did we not get the fourth emit (2)';
}

# vim: expandtab shiftwidth=4
