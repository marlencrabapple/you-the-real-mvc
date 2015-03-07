package Framework::Database;

use strict;

use Framework::Base;

use DBI;
use Encode;
use parent 'Exporter';

our ($AUTOLOAD, $dbh, $verbose, $dieonerror, @dbiargs);

#
# TBD: Figure out a way to utilize DBI's methods automatically without 'subclassing'.
# Maybe we can return a subroutine that handles this sort of thing as $self.
#
# Update: Looks like AUTOLOAD is precisely what we need!
#

sub AUTOLOAD {
  my $self = shift;
  my $sub = $AUTOLOAD;
  $sub =~ s/.*:://;

  $dbh->$sub(@_) or print "$!\n";
}

sub new {
  my ($self, $dbiargs, $verbose, $dieonerror ,$no_connect) = @_;

  unless($no_connect) {
    $Framework::Database::verbose = $verbose;
    $Framework::Database::dieonerror = $dieonerror;
    @Framework::Database::dbiargs = @{$dbiargs};

    $dbh = _init_connection(@dbiargs);
  }

  return $self;
}

sub _init_connection {
  $dbh = DBI->connect_cached(@_);
}

sub wakeup {
  _init_connection(@dbiargs);
}

#
# Database Utils
#

sub get_autoincrement {
  return 'INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT' if($dbiargs[0] =~ /^DBI:mysql:/i);
  return 'INTEGER PRIMARY KEY' if($dbiargs[0] =~ /^DBI:SQLite:/i);
  return 'INTEGER PRIMARY KEY' if($dbiargs[0] =~ /^DBI:SQLite2:/i);
}

sub table_exists {
  my ($self, $table) = @_;
  my ($sth);

  return 0 unless($sth = $dbh->prepare("SELECT * FROM " . $table . " LIMIT 1;"));
  return 0 unless($sth->execute());
  return 1;
}

sub get_decoded_hashref {

}

sub get_decoded_arrayref {

}

sub error {
  my ($self) = @_;

  my $dieonerror = shift || $Framework::Database::dieonerror;
  my $error = $verbose ? $dbh->errstr : string('s_sqlfail');

  make_error($error) if $dieonerror && $Framework::req;
  return $error;
}

sub test {
  die "test";
}

1;
