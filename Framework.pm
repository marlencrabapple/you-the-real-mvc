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

my @before_process_request = ();
our $_self;

our @EXPORT = (
  @Framework::Strings::EXPORT,
  @Framework::Utils::EXPORT,
  @Framework::Routes::EXPORT,
  @Framework::Request::EXPORT,
  @Framework::Response::EXPORT,
  @Framework::Database::EXPORT,
  @Framework::Template::EXPORT,
  qw($_self new build run env before_process_request)
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
  $_self = $self;

  my $app = sub {
    foreach my $sub (@before_process_request) {
      $sub->();
    }

    $self->request_handler(@_);
  };

  return $app;
}

sub before_process_request {
  my $self = shift;
  push @before_process_request, shift;
}

1;
