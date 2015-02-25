use Plack::App::File;
use Plack::Builder;

use FrameworkTest;

my $script = FrameworkTest->new;

my $static = Plack::App::File->new(root => "./static", content_type => sub {
  if(substr($_[0], rindex($_[0], '.')) =~ /\.webm/i) {
    return 'video/webm';
  }
  else {
    Plack::MIME->mime_type($_[0]) || 'text/plain';
  }
})->to_app;

my $app = builder {
  #enable 'Session', store => 'File';
  mount "/" => $static,
  mount "/app" => $script->run
}
