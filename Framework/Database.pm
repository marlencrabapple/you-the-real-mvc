package Framework::Database;

use strict;
use base qw(Exporter);
use DBI;
use Plack::Util;
use Plack::Request;
use Plack::Response;

sub get_decoded_hashref {
  my ($sth) = @_;
}

1;
