#!/usr/bin/perl
use 5.008;
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'Method::Workflow::Case',
    license     => 'perl',
    dist_author => 'Chad Granum <exodist7@gmail.com>',
    create_readme => 1,
    requires => {
        'Method::Workflow' => '0.201',
        'Exodist::Util' => '0.004',
    },
    build_requires => {
        'Test::More' => 0.88,
        'Test::Exception' => 0,
    },
    meta_merge => {
        resources => {
            repository => 'http://github.com/exodist/Method-Workflow-Case',
            bugtracker => 'http://github.com/exodist/Method-Workflow-Case/issues',
            homepage   => 'http://open-exodus.net/projects/Method-Workflow-Case'
        },
    }
);

$build->create_build_script;
