# You The Real MVC #

You The Real MVC is a minimal PSGI/Plack web framework (more of a mostly MVC interface or wrapper really) created to fill a niche between simply using Plack::App::WrapCGI and using a full featured framework like Dancer or Catalyst.

# How To Use #

```
# app.psgi
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
```

Run app.psgi with plackup and you're done!
