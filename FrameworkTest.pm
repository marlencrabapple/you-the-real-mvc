package FrameworkTest;

use strict;
use parent 'Framework';

our ($self,$env,$templates,$board,$dbh);

use FrameworkTest::Config;
use FrameworkTest::Templates;

#
# Routes
#

sub build {
  ($self,$env) = @_;

  #
  # Init
  #

  $self->before_process_request(sub {
    $dbh = Framework::Database->new();
    $board = "";
  });

  $self->get('/', sub {
    my ($params) = @_;

    $self->res("Hello, World!")
  });

  $self->get('/:name', sub {
    my ($params) = @_;

    $self->res("Hello, $params->{name}")
  });

  $self->get('/admin/:board', sub {
    make_admin_page(0);
  }, {
    board => sub { board_handler(shift) }
  });

  $self->get('/admin/:board/:page', sub {
    my ($params) = @_;

    make_admin_page($params->{page});
  }, {
    board => sub { board_handler(shift) },
    page => sub {
      return shift =~ /^[0-9]+$/
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

    if($replyoffset < 0) {
      $replyoffset = 0;
    }
    else {
      @threads[(scalar @threads) - 1]->{omitted} = $replyoffset;
    }

    my $sth2 = $dbh->prepare("SELECT COUNT(*) FROM "
      . get_option('sql_post_table',$board)
      . " WHERE parent=? AND image IS NOT NULL") or $self->make_error($dbh->errstr);

    $sth2->execute($$row{num}) or $self->make_error($dbh->errstr);

    my $imagecount = ($sth2->fetchrow_array)[0];

    $sth2 = $dbh->prepare(
      "SELECT * FROM " . get_option('sql_post_table',$board)
      . " WHERE parent=? ORDER BY num ASC LIMIT "
      . "$replyoffset,"
      . get_option('max_replies_index',$board)) or $self->make_error($dbh->errstr);

    $sth2->execute($$row{num}) or $self->make_error($dbh->errstr);

    my $visibleimages = 0;

    while(my $row2 = get_decoded_hashref($sth2)) {
      $$row2{reported} = defined $$reports{$$row2{num}};
      $visibleimages++ if $$row2{image};
      push @threads[(scalar @threads) - 1]->{posts}, $row2;
    }

    @threads[(scalar @threads) - 1]->{omittedimages} = $imagecount - $visibleimages;
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

sub board_handler {
  my $_board = shift;

  foreach (keys $options) {
    if($_ eq $_board) {
      $board = $_;
      Framework::set_section($_board);
      return 1;
    }
  }

  $self->make_error('Invalid board',404);
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
