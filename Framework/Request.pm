package Framework::Request;

use strict;

use Try::Tiny;
use Data::Dumper;
use base qw(Exporter);

use Plack::Util;
use Plack::Request;
use Plack::Response;

use Framework::Utils;
use Framework::Routes;
use Framework::Strings;

our $error;
our @EXPORT = (
  qw/$req request_handler/,
  #@Framework::Routes::EXPORT
);

sub request_handler {
  my ($self,$env) = @_;
  my ($match,$method,$path,@path_arr,$queryvars,$req);

  try {
    $req = Plack::Request->new($env);
    $path = $req->path_info;
    $method = $req->method;
    @path_arr = map { ($_ ne '') || ($_ eq "0") ? "$_" : () } split '/', $path;

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
            $matches = 1;
          }
          else {
            $matches = 0;
          }
        }
        else {
          if((index $$section{var}, ':') != -1) { # anything goes
            $queryvars->add(substr($$section{var},1) => $path_arr[$i]);
            $matches = 1;
          }
          elsif($path_arr[$i] eq $$section{var}) { # match via string comparison
            $matches = 1;
          }
          else {
            $matches = 0;
          }
        }
      }

      if(($matches) || (($path eq '/') && ($$route{path_str} eq '/'))) {
        $match = $route;
        last;
      }
    }

    return $match->{handler}->($queryvars,$req) if $match != 0;
    $self->make_error(S_INVALID_PATH, 404);
  }
  catch {
    if(get_option('debug_mode',Framework::get_section())) {
      local $SIG{__DIE__} = 'DEFAULT'; # thanks http://blog.64p.org/entry/20101109/1289291797
      die $_;
    }
    return get_error();
  }
}

sub set_error {
  $error = shift;
}

sub get_error {
  return $error;
}

1;
