package Framework::Request;

use strict;

use Net::IP;

use parent 'Plack::Request';

# Plack::Request's constructor doesn't do anything special, so this should be fine
sub new {
  my ($class, $env) = @_;
  die unless ref($env) eq 'HASH';

  bless { env => $env, net_ip => Net::IP->new($$env{REMOTE_ADDR}) }, $class;
}

sub uri_for {
  my ($self, $path, $args) = @_;
  my $uri = $self->base;
  $uri->path($uri->path . $path);
  $uri->query_form(@$args) if $args;

  return $uri;
}

1;
