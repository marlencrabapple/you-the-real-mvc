package Framework::IP;

use strict;

use Framework::Base;
use parent 'Net::IP';

#
# This seems a little excessive but its probably better not to polute the our
# namespace with anything more than our own stuff
#

sub in_range {
  my ($netip) = @_;

  if($$netip->version() == 4) {

  }
  elsif($$netip->version() == 6) {

  }
}

1;
