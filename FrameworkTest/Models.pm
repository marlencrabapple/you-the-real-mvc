package FrameworkTest::Models;

use strict;

use Framework;
use parent 'Exporter';

our @EXPORT = (
  qw(init_ban_table init_user_table init_report_table init_pass_table init_post_table)
);

sub init_table {
  my ($dbh, $table, $columns) = @_;
  my ($sth, @column_arr);

  foreach my $column (@{$columns}) {
    my $column_str = "`$$column{name}` " . ($$column{auto_increment} ?
      $dbh->get_autoincrement() : ($$column{type} || 'TEXT'));

    push @column_arr, $column_str;
  }

  $sth = $dbh->prepare("CREATE TABLE $table (" . join(',', @column_arr) . ")")
    or $dbh->error();
  $sth->execute();
}

sub init_post_table {
  init_table(@_, [
    { name => 'no', type => 'INTEGER', auto_increment => 1},
    { name => 'threadno', type => 'INTEGER'},
    { name => 'created', type => 'INTEGER'},
    { name => 'lasthit', type => 'INTEGER'},

    { name => 'ip' },
    { name => 'id' },
    { name => 'hostname' },

    { name => 'prettydate' },
    { name => 'name' },
    { name => 'trip' },
    { name => 'email' },
    { name => 'subject' },
    { name => 'password' },
    { name => 'comment' },
    { name => 'noformat' },

    { name => 'image' },
    { name => 'filename' },
    { name => 'size', type => 'INTEGER'},
    { name => 'md5' },
    { name => 'width', type => 'INTEGER'},
    { name => 'height', type => 'INTEGER'},
    { name => 'tnwidth', type => 'TINYINT'},
    { name => 'tnheight', type => 'TINYINT'},

    { name => 'sticky', type => 'TINYINT'},
    { name => 'permasage', type => 'TINYINT'},
    { name => 'locked', type => 'TINYINT'},
    { name => 'tnmask', type => 'TINYINT'},
    { name => 'staffpost' },
    { name => 'passnum', type => 'TINYINT'},
  ])
}

sub init_ban_table { }
sub init_user_table { }
sub init_report_table { }
sub init_pass_table { }

1;
