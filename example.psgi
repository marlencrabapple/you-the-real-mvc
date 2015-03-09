package JustATest;

use Framework;

sub build {
  get('/', sub{
    res('Hello, world!')
  });

  get('/:name', sub{
    res('Hello, ' . shift->{name} . '!')
  })
}

my $app = JustATest->new;
$app->run
