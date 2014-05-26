package FrameworkTest;

use strict;
use lib '.';
use parent 'Framework';

sub build {
  my $self = shift;
  
  $self->get('/', sub {
    $self->res('Hello, World!');
  });
  
  $self->get('/foo/:id', sub {
    my ($params) = @_;
    
    $self->res('Hello, Foo!');
  }, {
    id => sub {
      /[0-9]+/;
    }
  });
}

1;
