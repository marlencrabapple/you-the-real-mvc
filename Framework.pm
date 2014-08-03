package Framework;

use strict;
use base qw(Exporter);
use Plack;
use Plack::Util;
use Framework::Routes;
use Framework::Request;
use Framework::Strings;
use Framework::Template;
use Framework::Response;
use Framework::Database;

our @EXPORT = (
  @Framework::Utils::EXPORT,
  @Framework::Routes::EXPORT,
  @Framework::Request::EXPORT,
  @Framework::Response::EXPORT,
  @Framework::Database::EXPORT,
  @Framework::Template::EXPORT,
  qw(new build run)
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
