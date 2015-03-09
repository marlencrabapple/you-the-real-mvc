package JustATest;

use Framework;

sub build {
  get('/', sub {
    res('Hello, world!')
  });

  get('/:name', sub {
    res('Hello, ' . shift->{name} . '!')
  });

  prefix('/api', sub {
    get('/user/:userid', sub {
      my $params = shift;
      my $userid = $$params{userid};
      my $msg = 'If this weren\'t an example you\'d be viewing details for user'
        . " #$userid.";

      res({ userid => $userid, msg => $msg })
    })
  })
}

my $app = JustATest->new;
$app->run
