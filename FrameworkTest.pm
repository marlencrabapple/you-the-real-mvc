package FrameworkTest;

use strict;
use Framework;

use Data::Dumper;
use base qw(Exporter);

our $self;
our $templates;

our @EXPORT = (
  @Framework::EXPORT
);

use FrameworkTest::Templates;

sub build {
  $self = shift;

  $self->get('/', sub {
    $self->res('Hello, World!');
  });

  $self->get('/:id', sub {
    my ($params) = @_;

    $self->res("Hello, $params->{id}!");
  }, {
    id => sub {
      return shift =~ /^[0-9]+$/
    }
  });

  $self->get('/:name', sub {
    my ($params) = @_;

    $self->res("Hello, $params->{name}!");
  });

  $self->get('/test', sub {
    my ($params) = @_;

    make_test_template($params->{num});
  });

  $self->get('/pass', sub {
    my ($params) = @_;

    make_pass_template($params->{num});
  });
}

sub make_test_template {
  my ($num) = @_;

  $self->res($$templates{test_template}->(
    escape_test => "&&&&& &&&&"
  ));
}

sub make_pass_template {
  $self->res($$templates{pass_template}->());
}
1;
