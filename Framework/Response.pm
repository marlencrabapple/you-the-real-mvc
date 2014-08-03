package Framework::Response;

use strict;
use base qw(Exporter);
use Plack::Util;
use Plack::Request;
use Plack::Response;
use Framework::Routes;
use Framework::Strings;

our @EXPORT = (
  qw/make_error res/,
  #@Framework::Routes::EXPORT
);

sub make_error {
  my ($status,$content,$contenttype) = @_;

  return [
    $status || 500,
    ['Content-type', $contenttype || 'text/html'],
    [$content]
  ]
}

sub res {
  my ($self,$content,$contenttype,$status) = @_;

  return [
    $status || 200,
    ['Content-type', $contenttype || 'text/html'],
    [$content]
  ]
}

1;
