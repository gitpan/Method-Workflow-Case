package Method::Workflow::Case;
use strict;
use warnings;
use Method::Workflow;
use Method::Workflow::SubClass;
use Exodist::Util qw/ alias blessed /;
alias qw/
    Method::Workflow
    Method::Workflow::Task
    Method::Workflow::Case::Action
    Method::Workflow::Case::Case
/;

our $VERSION = '0.201';

keyword 'cases';

sub after_import {
    my ( $class, $caller, $specs ) = @_;
    Workflow->after_import( $caller, $specs );
    $_->export_to( $caller ) for Workflow, Action, Case;
}

sub pre_child_run_hook {
    my $self = shift;
    my ( $invocant, $result ) = @_;
    my @tasks;

    my @actions = $self->pull_children( Action );
    my @cases   = $self->pull_children( Case   );

    for my $case ( @cases ) {
        push @tasks => Task->new(
            name => $case->name,
            method => $case->method,
            subtasks_ref => [ @actions ],
            $self->ordering
                ? ( $self->ordering => 1 )
                : (),
            $self->parent_ordering
                ? ( parent_ordering => $self->parent_ordering )
                : (),
        );
    }

    $result->push_tasks( @tasks );
}

1;

=head1 NAME

Method::Workflow::Case - Run multiple actions against multiple scenarios.

=head1 DESCRIPTION

This is particularily useful in testing. Say you have 5 distinct sets of tests,
and you want to run these tests against 5 distinct scenarios. You can set up 2
loops, where the outer sets up the scenarios, and an inner loop that iterates
the actions. This becomes far more difficult when the scenarios get more
complicated, specially if they cannot be set up the same way each one.

Method::Workflow::Case lets you declare your variables, then declare actions
that are essentially methods that are run to set those variables. You then
declare your actions once again as methods. Method::Workflow::Case takes care
of the details of running each action and scenario.

=head1 SYNOPSYS

    use strict;
    use warnings;
    use Test::More;
    use Method::Workflow::Case;

    my $target;
    my @complete;

    cases the_cases {
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

=head1 FENNEC PROJECT

This module is part of the Fennec project. See L<Fennec> for more details.
Fennec is a project to develop an extendable and powerful testing framework.
Together the tools that make up the Fennec framework provide a potent testing
environment.

The tools provided by Fennec are also useful on their own. Sometimes a tool
created for Fennec is useful outside the greator framework. Such tools are
turned into their own projects. This is one such project.

=over 2

=item L<Fennec> - The core framework

The primary Fennec project that ties them all together.

=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Method-Workflow-Case is free software; Standard perl licence.

Method-Workflow-Case is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the license for more details.
