package Ptero::WorkflowBuilder::Detail::Node;
use Moose::Role;
use MooseX::Aliases;
use warnings FATAL => 'all';

requires 'to_hashref';
requires 'from_hashref';

has name => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has parallel_by => (
    is => 'rw',
    isa => 'Str',
    alias => 'parallelBy',
    predicate => 'has_parallel_by',
);

my $_INVALID_NAMES = new Set::Scalar('input connector', 'output connector');

sub _validate_name {
    my $self = shift;
    my @errors;

    if ($_INVALID_NAMES->contains($self->name)) {
        push @errors, sprintf(
            'Node may not be named %s',
            Data::Dump::pp($self->name)
        );
    }

    return @errors;
}

sub input_properties {
    my $self = shift;
    my @properties;
    if ($self->has_parallel_by) {
        push @properties, $self->parallel_by;
    }
    return @properties;
}

sub output_properties {
    my $self = shift;
    return;
}

sub is_input_property {
    my ($self, $property_name) = @_;
    return List::MoreUtils::any {$property_name eq $_} $self->input_properties;
}

sub is_output_property {
    my ($self, $property_name) = @_;
    return List::MoreUtils::any {$property_name eq $_} $self->output_properties;
}

1;

