package FrameworkTest;

use strict;
use lib '.';
use parent 'Framework';

use Data::Dumper;

sub build {
  my $self = shift;

  $self->get('/', sub {
    $self->res('Hello, World!');
  });

  $self->get('/foo/:id', sub {
    my ($params) = @_;

    $self->res("Hello, $params->{id}!");
  }, {
    id => sub {
      return shift =~ /^[0-9]+$/;
    }
  });
}

1;
