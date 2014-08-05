package FrameworkTest;

use strict;
use parent 'Framework';

our ($self,$env,$templates,$board,$dbh);

use FrameworkTest::Config;
use FrameworkTest::Templates;

#
# Database init
#



#
# Routes
#

sub build {
  ($self,$env) = @_;

  $dbh = Framework::Database->new();
  $board = "";

  $self->get('/', sub {
    my ($params) = @_;

    $self->res("Hello, World!")
  });

  $self->get('/:name', sub {
    my ($params) = @_;

    $self->res("Hello, $params->{name}")
  });

  $self->get('/admin/:board/:page', sub {
    my ($params) = @_;

    make_admin_page($params->{page});
  }, {
    board => sub {
      my $_board = shift;

      foreach (keys $options) {
        if($_ eq $_board) {
          $board = $_;
          Framework::set_section($_board);
          return 1;
        }
      }

      $self->make_error('Invalid board',404);
    },
    page => sub {
      return shift =~ /^[0-9]*$/ # no page is fine
    }
  });
}

#
# View Controllers
#

sub make_admin_page {
  my ($page) = @_;
  my ($session,$sth,$row,$reports,$postcount,$pages,$pageoffset,@threads);

  $session = verify_admin();
  $reports = get_reported_posts();

  $sth = $dbh->prepare("SELECT COUNT(*) FROM " . get_option('sql_post_table',$board))
    or $self->make_error($dbh->errstr);

  $sth->execute() or $self->make_error($dbh->errstr);

  $postcount = ($sth->fetchrow_array)[0];
  $pages = $postcount / get_option('max_threads_index',$board);
  $pageoffset = $page * get_option('max_threads_index',$board);

  $sth = $dbh->prepare(
    "SELECT * FROM " . get_option('sql_post_table',$board)
    . " WHERE parent IS NULL OR parent=0 ORDER BY sticky DESC,lasthit DESC LIMIT "
    . "$pageoffset,"
    . get_option('max_threads_index',$board)) or $self->make_error($dbh->errstr);

  $sth->execute() or $self->make_error($dbh->errstr);

  while($row = get_decoded_hashref($sth)) {
    $$row{reported} = defined $$reports{$$row{num}};
    push @threads, {posts => [$row]};

    my $sth2 = $dbh->prepare("SELECT COUNT(*) FROM "
      . get_option('sql_post_table',$board)
      . " WHERE parent=?") or $self->make_error($dbh->errstr);

    $sth2->execute($$row{num}) or $self->make_error($dbh->errstr);

    my $replyoffset = ($sth2->fetchrow_array)[0] - get_option('max_replies_index',$board);
    $replyoffset = 0 if $replyoffset < 0;

    $sth2 = $dbh->prepare(
      "SELECT * FROM " . get_option('sql_post_table',$board)
      . " WHERE parent=? ORDER BY num ASC LIMIT "
      . "$replyoffset,"
      . get_option('max_replies_index',$board)) or $self->make_error($dbh->errstr);

    $sth2->execute($$row{num}) or $self->make_error($dbh->errstr);

    while(my $row2 = get_decoded_hashref($sth2)) {
      $$row2{reported} = defined $$reports{$$row2{num}};
      push @threads[(scalar @threads) - 1]->{posts}, $row2;
    }
  }

  $self->res($$templates{admin_index_template}->(
    title => "Page No. $page",
    threads => \@threads,
    page => $page,
    pages => $pages
  ));
}

#
# Misc Controllers
#

sub verify_admin {

}

sub get_reported_posts {
  my ($reports,$sth,$row);

  $sth = $dbh->prepare("SELECT * FROM " . get_option('sql_report_table')) or $self->make_error($dbh->errstr);
  $sth->execute() or $self->make_error($dbh->errstr);

  while($row = get_decoded_hashref($sth)) {
    die Dumper($row);
    $$reports{$$row{postno}} = $row;
  }

  return $reports;
}
1;
