Framework::Database;

use strict;

use Framework::Base;
use parent 'Exporter';
use parent DBI;

our @EXPORT = (
  qw(get_handle)
);

our $dbh = get_handle();

sub new {
  my $self = shift;

  $dbh = DBI->connect_cached($source, $user, $password, { AutoCommit => 1 }
    or make_error(string('s_sqlconf'));

  return $self;
}

sub error {

}

sub table_exists {
  my ($table)=@_;
my ($sth);
return 0 unless($sth=$dbh->prepare("SELECT * FROM ".$table." LIMIT 1;"));
return 0 unless($sth->execute());
return 1;
}

sub get_sql_autoincrement(){
return 'INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT' if(SQL_DBI_SOURCE=~/^DBI:mysql:/i);
return 'INTEGER PRIMARY KEY' if(SQL_DBI_SOURCE=~/^DBI:SQLite:/i);
return 'INTEGER PRIMARY KEY' if(SQL_DBI_SOURCE=~/^DBI:SQLite2:/i);
make_error(S_SQLCONF); # maybe there should be a sane default case instead?
}

sub fetchrow_hashref {
my ($sth)=@_;
my $row=$sth->fetchrow_hashref();
if($row){
for my $k (keys %$row) # don't blame me for this shit, I got this from perlunicode.
{ defined && /[^\000-\177]/ && Encode::_utf8_on($_) for $row->{$k}; }
}
return $row;
}

sub fetchrow_arrayref {
my ($sth)=@_;
my $row=$sth->fetchrow_arrayref();
if($row){
# don't blame me for this shit, I got this from perlunicode.
defined && /[^\000-\177]/ && Encode::_utf8_on($_) for @$row;
}
return $row;
}
