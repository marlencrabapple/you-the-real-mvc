package Framework::Request;

use strict;
use base qw(Exporter);
use Data::Dumper;
use Plack::Util;
use Plack::Request;
use Plack::Response;
use Framework::Routes;
use Framework::Strings;

our @EXPORT = (
  qw/request_handler/,
  #@Framework::Routes::EXPORT
);

sub request_handler {
  my ($self,$env) = @_;
  my ($match,$req,$method,$path,@path_arr,$queryvars,$handler,$res);

  $req = Plack::Request->new($env);
  $path = $req->path_info;
  $method = $req->method;
  @path_arr = map { $_ ? $_ : () } split '/', $path;

  # get traditional query vars. vars from path are appended later.
  $queryvars = $method eq 'GET' ? $req->query_parameters : $req->body_parameters;

  # loop through defined routes
  foreach my $route (@{$$routes{$method}}) {
    my $matches = 0;

    for(my $i = 0; $i < scalar(@path_arr); $i++) {
      last unless scalar(@path_arr) == scalar(@{$$route{path_arr}});
      my $section = $$route{path_arr}->[$i];

      if(defined $$section{handler}) { # match via handler
        if($$section{handler}->($path_arr[$i])) {
          $queryvars->add(substr($$section{var},1) => $path_arr[$i]);
          $matches++;
        }
      }
      else {
        if((index $$section{var}, ':') != -1) { # anything goes
          $queryvars->add(substr($$section{var},1) => $path_arr[$i]);
          $matches++;
        }
        elsif($path_arr[$i] eq $$section{var}) { # match via string comparison
          $queryvars->add(substr($$section{var},1) => $path_arr[$i]);
          $matches++;
        }
      }
    }

    if($matches == (scalar @path_arr)) {
      $match = $route ;
      last;
    }
  }

  return $match->{handler}->($queryvars,$req) if $match != 0;
  return Framework::Response::make_error(404,S_INVALID_PATH);
}

1;
