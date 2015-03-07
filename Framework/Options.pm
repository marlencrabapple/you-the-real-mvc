package Framework::Options;

use strict;

use parent 'Exporter';
use Hash::Merge::Simple qw(merge);

our @EXPORT = (
  qw(option options add_option add_options scoped_options)
);

our $options = { global => {} };

sub option {
  my ($key, $section) = @_;

  $section = $section ? $section : 'global';
  return $$options{$section}->{$key} || $$options{'global'}->{$key}
}

sub options {
  return $options;
}

sub add_option {
  my ($key, $value, $section) = @_;
  $$options{($section || 'global')}->{$key} = $value
}

sub add_options {
  my ($options) = @_;
  $Framework::Options::options = merge($Framework::Options::options, $options)
}

sub scoped_options {
  my ($options, $sub) = @_;

  my $options_copy = \@{$options};
  add_options($options);
  $sub->();

  $options = $options_copy # this should be safe...
}

1;
