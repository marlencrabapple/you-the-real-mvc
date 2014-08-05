package Framework::Routes;

use strict;
use base qw(Exporter);
use Plack::Util;
use Plack::Request;
use Plack::Response;
use Framework::Utils;

our @EXPORT = qw(get post $routes);

our $routes = {
  GET => [],
  POST => []
};

sub get {
  my ($self,$path,$sub,$pathhandlers) = @_;

  add_route('GET',$path,$sub,$pathhandlers);
}

sub post {
  my ($self,$path,$sub,$pathhandlers) = @_;

  add_route('POST',$path,$sub,$pathhandlers);
}

sub add_route {
  my ($method,$path,$sub,$pathhandlers) = @_;

  push $$routes{$method}, {
    handler => $sub,
    path_str => $path,
    path_arr => [
      map {
        $_ ? sub {
          return {
            var => "$_",
            handler => (index $_, ':') == 0 ? $$pathhandlers{ substr $_, 1 } : undef
          }
        }->() : ()
      } split('/', $path)
    ]
  };
}

1;
