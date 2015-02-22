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
  Framework::Base::init_templates();
  $self->build();
  return $self;
}

sub build {
  # wat
}

sub run {
  my ($self) = @_;

  my $app = sub {
    my ($env) = @_;

    foreach my $sub (@Framework::Base::before_process_request) {
      $sub->($env);
    }

    my $res = $self->request_handler($env);
    return $res;

    # currently only for redirect(), but should probably be used for res() too
    RES_OVERRIDE:
      $res = get_res();
      return $res;
  };

  return $app;
}

1;
