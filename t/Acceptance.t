#!/usr/bin/perl
use strict;
use warnings;
use Method::Workflow::Case ':ordered';
use Test::More;

my $target;
my @complete;

cases root {
    case a { $target = 'a' }
    case b { $target = 'b' }
    case c { $target = 'c' }

    action 1 { push @complete => $target x 1 }
    action 2 { push @complete => $target x 2 }
    action 3 { push @complete => $target x 3 }
}

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
