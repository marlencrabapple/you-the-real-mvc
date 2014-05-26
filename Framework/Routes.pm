package Framework::Routes;

use base qw(Exporter);
use Plack::Util;
use Plack::Request;
use Plack::Response;
use Data::Dumper;

our @EXPORT = qw(get post $routes);

#
# Dispatch Table Structure
#

#{
#  GET => [
#    { 
#      path_str => ''
#      path_arr => [
#        { 
#          var => '',
#          handler => sub { }
#        }
#      ]
#    }
#  ],
#  POST => [
#    { 
#      path_str => ''
#      path_arr => [
#        { 
#          var => '',
#          handler => sub { }
#        }
#      ]
#    }
#  ]
#};

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
    path_str => $path,
    path_arr => [ 
      map { 
        $_ ? sub { 
          return { 
            var => $_,
            handler => (index $_, ':') == 0 ? $$pathhandlers{ substr $_,1 } : undef
          } 
        }->() : ()
      } split '/', $path
    ]
  };
  
  #push $$routes{$method}, $dispatch_obj;
  
  
  #push $$routes{$method}, {
  #  path_str => $path,
  #  path_arr => (map { { var => $_, handler => (index($_,':') ? $pathhandlers{substr($_,1)} : undef) } } split '/', $path)
  #};
}

1;
