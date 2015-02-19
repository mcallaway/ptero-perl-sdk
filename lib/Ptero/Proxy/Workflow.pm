package Ptero::Proxy::Workflow;

use Moose;
use warnings FATAL => 'all';

use Params::Validate;
use Ptero::HTTP qw(get_decoded_resource);

my @COMPLETE_STATUSES = qw(success failure error);

has url => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has status_url => (
    is => 'rw',
    isa => 'Str',
    predicate => 'has_status_url',
);

sub wait {
    my $self = shift;
    my %p = Params::Validate::validate(@_, {
        polling_interval => {default => 120},
    });

    while ($self->is_running) {
        sleep $p{polling_interval};
    }

    return $self->status;
}

sub get_status_url {
    my $self = shift;

    my $r = get_decoded_resource(url => $self->url);
    $self->status_url($r->{reports}->{'workflow-status'});
    return $self->status_url;
}

sub status {
    my $self = shift;
    unless ($self->has_status_url) {
        $self->get_status_url();
    }

    my $r = get_decoded_resource(url => $self->status_url);
    return $r->{status};
}

sub is_running {
    my $self = shift;

    return ! defined($self->status)
}

sub outputs {
    my $self = shift;

    my $workflow_detail = get_decoded_resource(url => $self->url);
    my $workflow_output_report = get_decoded_resource(
        url => $workflow_detail->{reports}->{'workflow-outputs'});

    return $workflow_output_report->{outputs};
}

__PACKAGE__->meta->make_immutable;
