package Framework::Response;

use base qw(Exporter);
use Plack::Util;
use Plack::Request;
use Plack::Response;
use Framework::Routes;

our @EXPORT = (
  qw/make_error res/,
  @Framework::Routes::EXPORT
);

sub make_error {
  
}

sub res {
  my ($self,$content,$contenttype,$statuscode) = @_;
  
  return [
    $status || 200,
    [ 'Content-type', $contenttype || 'text/html' ],
    [ $content ]
  ]
}

1;
