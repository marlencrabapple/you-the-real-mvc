package Framework::Database;

use strict;
use base qw(Exporter);
use DBI;
use Plack::Util;
use Plack::Request;
use Plack::Response;
use Framework::Utils;

our $dbh;
our @EXPORT = qw($dbh get_decoded_hashref);

sub new {
  #die Dumper(get_option('sql_dbi_source'));
  $dbh = DBI->connect_cached(get_option('sql_dbi_source'),get_option('sql_username'),get_option('sql_password'),{AutoCommit => 1});
}

sub get_decoded_hashref {
	my ($sth)=@_;
	my $row = $sth->fetchrow_hashref();

	if($row) {
    # don't blame me for this shit, I got this from perlunicode.
		for my $k (keys %$row) {
      defined && /[^\000-\177]/ && Encode::_utf8_on($_) for $row->{$k};
    }
	}

	return $row;
}

sub get_decoded_arrayref {
	my ($sth) = @_;
	my $row = $sth->fetchrow_arrayref();

	if($row) {
		# don't blame me for this shit, I got this from perlunicode.
		defined && /[^\000-\177]/ && Encode::_utf8_on($_) for @$row;
	}

	return $row;
}

1;
