#!/usr/bin/perl
use strict;
use warnings;
use Method::Workflow::Case ':ordered';
use Test::More;

start_class_workflow();

my $target;
my @complete;
case a { $target = 'a' }
case b { $target = 'b' }
case c { $target = 'c' }

action 1 { push @complete => $target x 1 }
action 2 { push @complete => $target x 2 }
action 3 { push @complete => $target x 3 }

end_class_workflow();
run_workflow;

is_deeply(
    \@complete,
    [ qw/
        a
        aa
        aaa
        b
        bb
        bbb
        c
        cc
        ccc
    /],
    "All cases and actions"
);

done_testing;
