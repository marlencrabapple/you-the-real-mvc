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
  
  die Dumper($self,$env,$req,$path,$method,$routes);
  
  @patharr = split '/', @path;
  
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
