package Framework::Strings;

use strict;

use parent 'Exporter';
use Hash::Merge::Simple qw(merge);

our @EXPORT = (
  qw(string strings add_string add_strings scoped_strings)
);

our $strings = { global => {} };

sub string {
  my ($key, $vars) = @_;

  if(ref($$strings{$key}) eq 'CODE') {
    return $$strings{$key}->($vars)
  }
  else {
    return $$strings{$key}
  }
}

sub strings {
  return $strings
}

sub add_string {
  my ($key, $value) = @_;
  $$strings{$key} = $value
}

sub add_strings {
  my ($strings) = @_;
  $Framework::Strings::strings = merge($Framework::Strings::strings, $strings)
}

1;
