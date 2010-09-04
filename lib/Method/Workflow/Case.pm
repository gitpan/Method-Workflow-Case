package Method::Workflow::Case;
use strict;
use warnings;
use Method::Workflow;
use base 'Method::Workflow::Base';
require Method::Workflow::Case::Action;
use aliased 'Method::Workflow::Task';
use Method::Workflow::Meta qw/ meta_for /;
use Scalar::Util qw/ blessed /;

our $VERSION = '0.001';

keyword 'case';

sub import_hook {
    my ( $class, $caller, $specs ) = @_;
    Method::Workflow::Case::Action->export_to( $caller );
}

sub pre_run_hook {
    Case => sub {
        my %params = @_;
        my $order;

        if ( $params{current}->isa( 'Method::Workflow::Base' )) {
            ($order) = grep { $params{current}->$_ } Task->order_options;
        }

        unless ( $order ) {
            my $importer = blessed( $params{current} ) || $params{current};
            my $spec = meta_for( __PACKAGE__ )->prop( $importer );
            ($order) = grep { $spec->{$_} } Task->order_options
                if $spec;
        }

        my @cases   = $params{meta}->pull_items( __PACKAGE__ );
        my @actions = $params{meta}->pull_items( 'Method::Workflow::Case::Action' );
        my @subtasks = map { Task->new(
            task            => $_,
            workflow        => $params{current},
            owner           => $params{root},
            _ordering       => $order || undef,
        )} @actions;

        my @tasks = map { Task->new(
            before_all_ref  => [$_],
            subtasks_ref    => \@subtasks,
            _ordering       => $order || undef,
            workflow        => $params{current},
            owner           => $params{root},
        )} @cases;

        meta_for( $params{root} )->add_task(
            $order ? Task->new(
                subtasks_ref    => \@tasks,
                _ordering       => $order || undef,
                workflow        => $params{current},
                owner           => $params{root},
            ) : @tasks
        );
    }
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
