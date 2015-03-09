# You The Real MVC #
You The Real MVC is a minimal PSGI/Plack web framework (more of a mostly MVC interface or wrapper really) created to fill a niche between simply using Plack::App::WrapCGI and using a full featured framework like Dancer or Catalyst.

# How To Use #
1. Clone this repo.

        $ git clone https://github.com/marlencrabapple/kareha-psgi.git

2. Write your application.

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


3. Use cpanminus to handle dependencies and run your application with plackup.

        $ cd <your install dir>
        $ sudo cpanm --installdeps .
        $ plackup app.psgi
        ...
        $ curl http://localhost:5000
        Hello, world!
