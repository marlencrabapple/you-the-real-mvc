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
  
  # this is probably inside out, but some of the logic inside seems promising
  #foreach my $req_section (@path_arr) {
    #foreach my $route ($$routes{$method}) {
      #foreach my $section ($$route{path_arr}) {
        #my $match = 1;
        
        #if(!$$section{handler}) {
          #if((index $section, ':') != -1) { # anything goes
            ##$queryvars->section
          #}
          #else { # match via string comparison
            ##$match = 0 unless $something eq $something
          #}
        #}
        #else { # match via handler
          #$match = 0 unless $$section{handler}->($req_section);
        #}
      #}
      
      ## return $$route{handler}->($queryvars) if $match;
      ## we can probably return the sub reference here
    #}
  #}
  
  # haven't ran through this version in my head yet
  # slightly modified of above
  foreach my $route ($$routes{$method) {
    my $match = 1;
    
    foreach $req_section (@path_arr) {
      foreach my $section ($$route{path_arr}) {
        my $match = 1;
        
        if(!$$section{handler}) {
          if((index $section, ':') != -1) { # anything goes
            #$queryvars->section
          }
          else { # match via string comparison
            #$match = 0 unless $something eq $something
          }
        }
        else { # match via handler
          $match = 0 unless $$section{handler}->($req_section);
        }
      }
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
