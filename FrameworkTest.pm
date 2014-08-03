package FrameworkTest;

use strict;
use Framework;

use Data::Dumper;
use base qw(Exporter);

our ($self,$board,$templates);

our @EXPORT = (
  @Framework::EXPORT
);

use FrameworkTest::Templates;

sub build {
  $self = shift;

  $self->get('/', sub {
    $self->res('Hello, World!');
  });

  $self->get('/:id', sub {
    my ($params) = @_;

    $self->res("Hello, $params->{id}!");
  }, {
    id => sub {
      return shift =~ /^[0-9]+$/
    }
  });

  $self->get('/:name', sub {
    my ($params) = @_;

    $self->res("Hello, $params->{name}!");
  });

  $self->get('/test', sub {
    my ($params) = @_;

    make_test_template($params->{num});
  });

  $self->get('/pass', sub {
    my ($params) = @_;

    make_pass_template($params->{num});
  });
}

sub make_test_template {
  my ($num) = @_;

  $self->res($$templates{test_template}->(
    escape_test => "&&&&& &&&&"
  ));
}

sub make_pass_template {
  $self->res($$templates{pass_template}->());
}

sub make_admin_page {
  my ($page) = @_;
  my ($session,$sth,$row,$reports,$postcount,$pages,@threads);

  $session = verify_admin();
  $reports = get_reported_posts();

  $sth = $dbh->prepare("SELECT count(*) FROM " . get_option('post_table', $board));
  $sth->execute();
  $postcount = ($sth->fetchrow_arrayref)->[0];
  $pages = $postcount / get_option('max_threads_index', $board);

  $sth = $dbh->prepare(
    "SELECT * FROM " . get_option('post_table', $board)
    . " WHERE parent IS NULL LIMIT "
    . get_option('max_threads_index', $board));

  $sth->execute();

  while($row = get_decoded_hashref($sth)) {
    $$row{reported} = defined $$reports{$$row{num}};
    push @threads, { posts => [$row] };

    my $sth2 = $dbh->prepare(
      "SELECT * FROM " . get_option('post_table', $board)
      . " WHERE parent=? ORDER BY num ASC LIMIT "
      . get_option('max_replies_index', $board));

    $sth2->execute($$row{num});

    while(my $row2 = get_decoded_hashref($sth)) {
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

sub make_admin_thread {
  my ($num) = @_;
  my ($session,$sth,$row,$reports,$thread);

  $session = verify_admin();
  $reports = get_reported_posts();

  my $sth = $dbh->prepare("SELECT * FROM $board WHERE parent=? OR num=? ORDER BY num ASC");
  $sth->execute($num,$num);

  while($row = get_decoded_hashref($sth)) {
    $$row{reported} = defined $$reports{$$row{num}};
    push @{$$thread{posts}}, $row;
  }

  $self->res($$templates{admin_thread_template}->(
    title => "No. $$thread{posts}->[0]->{num}",
    thread => $thread
  ));
}

sub get_reported_posts {
  my ($reports,$sth,$row);

  $sth = $dbh->prepare("SELECT * FROM " . get_option('report_table'));
  $sth->execute();

  while($row = get_decoded_hashref($sth)) {
    $$reports{$$row{postno}} = $row;
  }

  return $reports;
}
1;
