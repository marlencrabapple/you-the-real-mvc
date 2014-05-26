package Framework;

use base 'Exporter';
use Plack;
use Plack::Util;
use Framework::Routes;
use Framework::Request;
use Framework::Response;
use Framework::Database;

our @EXPORT = (
  @Framework::Routes::EXPORT,
  @Framework::Request::EXPORT,
  @Framework::Response::EXPORT,
  @Framework::Database::EXPORT,
);

#
# Init Framework
#

sub new {
  my $self = shift;
  $self->build();
  return $self;
}

sub build {
  # wat
}

sub run {
  my $self = shift;
  my $app = sub { $self->request_handler(@_) };
  return $app;
}

1;
