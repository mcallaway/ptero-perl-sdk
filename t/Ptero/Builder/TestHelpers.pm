package Ptero::Builder::TestHelpers;

use strict;
use warnings FATAL => 'all';

use Ptero::Builder::ShellCommand;
use Ptero::Builder::Workflow;

use Exporter 'import';
our @EXPORT_OK = qw(
    build_nested_workflow
    build_basic_workflow
    create_basic_task
);

sub echo_test { shift }
sub sleep_echo_test { sleep(2); return shift }
sub sleep_fail_test { sleep(2); die "Bad news"; }

sub build_nested_workflow {
    my $name = shift;

    my $workflow = Ptero::Builder::Workflow->new(name => $name);
    my $task = $workflow->create_task(
        name => 'A',
        methods => [
            build_basic_workflow('inner'),
        ],
    );
    $workflow->connect_input(
        source_property => 'A_in',
        destination => $task,
        destination_property => 'A_in',
    );
    $workflow->connect_output(
        source => $task,
        source_property => 'A_out',
        destination_property => 'A_out',
    );
    return $workflow;
}

sub build_basic_workflow {
    my $name = shift;

    my $workflow = Ptero::Builder::Workflow->new(name => $name);
    my $task = $workflow->create_task(
        name => 'A',
        methods => [
            Ptero::Builder::ShellCommand->new(
                name => 'do something',
                parameters => {
                    commandLine => ['echo', 'basic-workflow'],
                    user => 'testuser',
                    workingDirectory => '/test/working/directory',
                },
            ),
        ],
    );
    $workflow->connect_input(
        source_property => 'A_in',
        destination => $task,
        destination_property => 'A_in',
    );
    $workflow->connect_output(
        source => $task,
        source_property => 'A_out',
        destination_property => 'A_out',
    );
    return $workflow;
}

sub create_basic_task {
    my $workflow = shift;
    my $name = shift;

    return $workflow->create_task(
        name => $name,
        methods => [
            Ptero::Builder::ShellCommand->new(
                name => 'do something',
                parameters => {
                    commandLine => ['echo', 'basic-task'],
                    user => 'testuser',
                    workingDirectory => '/test/working/directory',
                },
            ),
        ],
    );
}

1;
