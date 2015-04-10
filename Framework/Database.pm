package Framework::Database;

use strict;

use Framework::Base;

use DBI;
use Encode;
use parent 'Exporter';

our ($AUTOLOAD, $dbh, $verbose, $dieonerror, @dbiargs);

sub AUTOLOAD {
  my $self = shift;
  my $sub = $AUTOLOAD;
  $sub =~ s/.*:://;

  $dbh->$sub(@_) or return 0;
}

sub new {
  my ($class, $dbiargs, $verbose, $dieonerror ,$no_connect) = @_;

  unless($no_connect) {
    $Framework::Database::verbose = $verbose;
    $Framework::Database::dieonerror = $dieonerror;
    @Framework::Database::dbiargs = @{$dbiargs};

    $dbh = _init_connection(@dbiargs);
  }

  return bless {}, $class;
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

sub init_table {
  my ($self, $table, $columns) = @_;
  my ($sth, @column_arr);

  foreach my $column (@{$columns}) {
    my $column_str = "`$$column{name}` " . ($$column{auto_increment} ?
      get_autoincrement() : sub {
        if($$column{type}) {
          if($$column{type} eq 'ip') {
            return 'TEXT' if option('sql_source') =~ /^DBI:SQLite/i;
            return 'VARBINARY(16)' if option('sql_source') =~ /^DBI:MySQL/i;

            # bytea(16) might be better if it actually works...
            # No idea if this can detect an IP in binary either.
            return 'inet' if option('sql_source') =~ /^DBI:Pg/i;
            return 'TEXT';
          }

          return $$column{type}
        }

        return 'TEXT';
      }->());

    push @column_arr, $column_str;
  }

  $sth = $dbh->prepare("CREATE TABLE $table (" . join(',', @column_arr) . ")")
    or $dbh->error();
  $sth->execute();
}

sub get_decoded_hashref {
  my ($sth) = @_;
  my $row = $sth->fetchrow_hashref;

  if(ref $row eq 'HASH') {
    for my $key (keys %$row) {
      defined && /[^\000-\177]/ && Encode::_utf8_on($_) for $row->{$key};
    }
  }

  return $row;
}

sub get_decoded_arrayref {
  my ($sth) = @_;
  my $row = $sth->fetchrow_arrayref;

  if(ref $row eq 'ARRAY') {
    defined && /[^\000-\177]/ && Encode::_utf8_on($_) for @$row;
  }

  return $row;
}

sub error {
  my ($self) = @_;

  my $dieonerror = shift || $Framework::Database::dieonerror;
  my $error = $verbose ? $dbh->errstr : string('s_sqlfail');

  make_error($error) if $dieonerror && $Framework::req;
  return $error;
}

1;
