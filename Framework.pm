package Framework;

use strict;
use base qw(Exporter);
use Try::Tiny;
use Plack;
use Plack::Util;
#use Plack::Util::Accessor qw(rethrow);
use Framework::Utils;
use Framework::Routes;
use Framework::Strings;
use Framework::Template;
use Framework::Database;
use Framework::Request;
use Framework::Response;

our @EXPORT = (
  @Framework::Strings::EXPORT,
  @Framework::Utils::EXPORT,
  @Framework::Routes::EXPORT,
  @Framework::Request::EXPORT,
  @Framework::Response::EXPORT,
  @Framework::Database::EXPORT,
  @Framework::Template::EXPORT,
  qw(new build run env)
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
  my ($self) = @_;

  my $app = sub {
    $self->request_handler(@_);
  };

  return $app;
}

1;
