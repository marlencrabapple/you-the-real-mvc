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

sub post_stuff {
  my ($params) = @_;

  process_file($req->upload('file'));
  
  res("File uploaded!");
}

1;
