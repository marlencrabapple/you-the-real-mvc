package Framework::Request;

use base qw(Exporter);
use Data::Dumper;
use Plack::Util;
use Plack::Request;
use Plack::Response;
use Framework::Routes;

our @EXPORT = (
  qw/request_handler/,
  @Framework::Routes::EXPORT
);

sub request_handler {
  my ($self,$env) = @_;
  my ($req,$method,$path,@path_arr,$queryvars,$handler,$res);
  
  $req = Plack::Request->new($env);
  $path = $req->path_info;
  $method = $req->method;
  @path_arr = map { $_ ? $_ : () } split '/', $path;
  
  # add traditional query vars. path vars get appended later.
  $queryvars = $method eq 'GET' ? $req->query_parameters : $req->body_parameters;
  
  foreach my $req_section (@path_arr) {
    foreach my $route ($$routes{$method}) {
      foreach my $section ($$route{path_arr}) {
        my $match = 0;
        
        if(!$$section{handler}) {
          if((index $section, ':') != -1) { # anything goes
            #$queryvars->section
          }
          else { # match via string comparison
            
          }
        }
        else { # match via handler
          
        }
      }
      
      # return $$route{handler}->($queryvars) if $match;
      # we can probably return the sub reference here
      # i'll assume 
    }
  }
  
  die Dumper($self,$env,$req,$path,\@path_arr,$method,$routes);
  
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
