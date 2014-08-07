package FrameworkTest::Strings;

use strict;
use base qw(Exporter);
use Package::Constants;

use constant {
  S_NAME_FIELD => 'Name',
  S_LINK_FIELD => 'Link'
};

our @EXPORT = (
  Package::Constants->list(__PACKAGE__),
  qw(get_strings)
);

sub get_strings {
  return Package::Constants->list(__PACKAGE__);
}

1;
