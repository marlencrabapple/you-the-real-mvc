package Framework;

use strict;

use base qw(Exporter); # exporting exporter doesn't work as expected...
use Framework::Base;
use Framework::Defaults;

our @EXPORT = (
  @Framework::Base::EXPORT,
  qw(new build run)
);

sub new {
  my $self = shift;
  $self->build();
  return $self;
}

sub build {
  # wat
}

sub run {
  my ($self) = @_;

  my $app = sub {
    foreach my $sub (@Framework::Base::before_process_request) {
      $sub->();
    }

    $self->request_handler(@_);
  };

  return $app;
}

1;
