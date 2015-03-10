package JustATest;

use Framework;

sub build {
  get('/', sub {
    res('Hello, world!')
  });

  get('/:name', sub {
    res('Hello, ' . shift->{name} . '!')
  });

  get('/user/:userid', sub {
    my $params = shift;
    view_user($$params{userid});
  });

  prefix('/api', sub {
    get('/user/:userid', sub {
      my $params = shift;
      view_user($$params{userid}, 1)
    })
  })
}

sub view_user {
  my ($userid, $ajax) = @_;
  my $msg = 'If this wasn\'t an example you\'d be viewing details for user'
    . " #$userid.";

  if($ajax) {
    res({ userid => $userid, msg => $msg })
  }

  res($msg)
}

my $app = JustATest->new;
$app->run
