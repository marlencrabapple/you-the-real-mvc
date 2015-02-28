package Framework::Database;

use strict;

use Framework::Base;
use DBI;
use Encode;
use parent 'Exporter';

our ($dbh, $verbose, $dieonerror, @dbiargs);

#
# TBD: Figure out a way to utilize DBI's methods automatically without 'subclassing'.
#

sub new {
  my ($self, $dbiargs, $verbose, $dieonerror ,$no_connect) = @_;

  unless($no_connect) {
    $Framework::Database::verbose = $verbose;
    $Framework::Database::dieonerror = $dieonerror;
    @Framework::Database::dbiargs = @{$dbiargs};

    $dbh = init_connection($self, @dbiargs);
  }

  return $self;
}

sub init_connection {
  $dbh = shift->connect_cached(@_);
}

sub wakeup {
  init_connection(@dbiargs);
}

sub table_exists {

}

sub get_decoded_hashref {

}

sub get_decoded_arrayref {

}

sub error {
  my $dieonerror = shift || $Framework::Database::dieonerror;
  my $error = $verbose ? $dbh->errstr : string('s_sqlfail');

  make_error($error) if $dieonerror;
  return $error;
}

sub test {
  die "test";
}

1;
