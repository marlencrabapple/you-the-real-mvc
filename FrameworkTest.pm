package FrameworkTest;

use strict;

use Framework;

use FrameworkTest::Utils;
use FrameworkTest::Config;

#
# Routes
#

sub build {
  get('/', sub {
    res(template('index')->(
      title => 'Just a test',
      content => 'Hello world!'
    ));
  });

  get('/json', sub {
    res(['wait', 'what']);
  });

  get('/form', sub {
    res(template('form_test')->());
  });

  post('/post', sub {
    my ($params) = @_;
    post_stuff($params)
  });
}

#
# Controllers
#

sub post_stuff {
  my ($params) = @_;

  my ($ext, $width, $height) = process_file($req->upload('file'), time());

  res({fileinfo => {
    ext => $ext,
    width => $width,
    height => $height
  }});
}

1;
