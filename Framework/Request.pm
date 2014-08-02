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
  @Framework::Routes::EXPORT
);

sub request_handler {
  #die Dumper($routes);

  my ($self,$env) = @_;
  my ($match,$req,$method,$path,@path_arr,$queryvars,$handler,$res);

  $req = Plack::Request->new($env);
  $path = $req->path_info;
  $method = $req->method;
  @path_arr = map { $_ ? $_ : () } split '/', $path;

  # add traditional query vars. path vars get appended later.
  $queryvars = $method eq 'GET' ? $req->query_parameters : $req->body_parameters;

  # foreach my $route (@{$$routes{$method}}) {
  #   foreach my $req_section (@path_arr) {
  #     foreach my $section (@{$$route{path_arr}}) {
  #       if(!defined $$section{handler}) {
  #         if((index $$section{var}, ':') != -1) { # anything goes
  #           $queryvars->add(substr($$section{var},1) => $req_section);
  #           $matches++;
  #           last;
  #         }
  #         else { # match via string comparison
  #           if($req_section eq $$section{var}) {
  #             $matches++;
  #             last;
  #           }
  #         }
  #       }
  #       else { # match via handler
  #         if($$section{handler}->($req_section)) {
  #           $queryvars->add(substr($$section{var},1) => $req_section);
  #           $matches++;
  #           last;
  #         }
  #       }
  #     }
  #   }
  # }

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

  #die Dumper(,$path,\@path_arr);
  #die Dumper($matches,$req,$path,\@path_arr,$method,$routes,$queryvars->as_hashref);
  #return $$routes{$method}->[1]->{handler}->($queryvars,$req);

  if($match != 0) {
    return $match->{handler}->($queryvars,$req);
  }
  else {
    $res = Framework::Response::make_error(404,S_INVALID_PATH);
  }

  #if($$routes{) {
  #}

  #if(!$$routes{$method}->{$path}) {
  #  $res = Framework::Response::make_error();
  #}
  #else {
  #  $queryvars = $method eq 'GET' ? $req->query_parameters : $req->body_parameters;
  #  $res = $$routes{$method}->{$path}->{handler}->($queryvars,$req);
  #}

  return $res;
}

sub parse_path {

}

1;
