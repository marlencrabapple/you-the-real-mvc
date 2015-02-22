package FrameworkTest;

use strict;

use Framework;

use FrameworkTest::Utils;
use FrameworkTest::Strings;
use FrameworkTest::Config;
use FrameworkTest::ConfigDefault;

#
# Routes
#

our $manapass = '$2y$10$2sSGbOusRZbGYc2tgZPrr.yJUURMjLFurK1mPivACsMNoQTK8LxDy';

sub build {
  before_process_request(sub{
    print "asdf\n\n";
  });

  get('/', sub {
    res(template('index')->(
      title => 'Just a test',
      content => 'Hello world!'
    ));
  });

  get('/json', sub {
    res(['wait', 'what']);
  });

  get('/uploadform', sub {
    res(template('form_test')->());
  });

  get('/newhash', sub {
    res(template('hash_form')->());
  });

  post('/newhash', sub {
    my ($params) = @_;

    res({
      hash => password_hash($$params{berra}, $$params{salt}, $$params{cost})
    });
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

  # check password
  if((my $crypt = password_hash($$params{'berra'}, $manapass)) ne $manapass) {
    make_error(get_option('s_wrongpass'));
  }

  my $fileinfo = process_file($req->upload('file'), time());
  ($$fileinfo{tn_width}, $$fileinfo{tn_height}) = (get_thumbnail_dimensions($$fileinfo{width}, $$fileinfo{height}, 1));

  if($$fileinfo{other}->{tn_ext}) {
    $$fileinfo{tn_ext} = $$fileinfo{other}->{tn_ext}
  }
  else {
    $$fileinfo{tn_ext} = $$fileinfo{ext}
  }

  $$fileinfo{thumb} = $$fileinfo{filebase} . "s.$$fileinfo{tn_ext}";

  make_thumbnail(get_option('img_dir') . $$fileinfo{filename},
    get_option('thumb_dir') . $$fileinfo{thumb}, $$fileinfo{ext},
    $$fileinfo{tn_width}, $$fileinfo{tn_height}) if $$fileinfo{ext} =~ /webm|gif|jpg|jpeg|png/;

  res({ fileinfo => $fileinfo })
}

1;
