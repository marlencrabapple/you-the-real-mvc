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

our $manapass = '$2a$10$2sSGbOusRZbGYc2tgZPrr.yJUURMjLFurK1mPivACsMNoQTK8LxDy';

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

  get('/upload', sub {
    res(template('form_test')->('File Upload'));
  });

  get('/newhash', sub {
    res(template('hash_form')->(title => 'password_hash() Test'));
  });

  post('/newhash', sub {
    my ($params) = @_;

    make_error('You must enter a password to be hashed.') unless $$params{berra};

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

  # handle file
  my $fileinfo = process_file($req->upload('file'), time());
  ($$fileinfo{tn_width}, $$fileinfo{tn_height}) = (get_thumbnail_dimensions($$fileinfo{width}, $$fileinfo{height}, 1));

  # get proper thumbnail extension
  if($$fileinfo{other}->{tn_ext}) {
    $$fileinfo{tn_ext} = $$fileinfo{other}->{tn_ext}
  }
  elsif($$fileinfo{ext} eq 'webm') {
    $$fileinfo{tn_ext} = 'jpg'
  }
  else {
    $$fileinfo{tn_ext} = $$fileinfo{ext}
  }

  # make thumbnail
  $$fileinfo{thumb} = $$fileinfo{filebase} . "s.$$fileinfo{tn_ext}";

  make_thumbnail(get_option('img_dir') . $$fileinfo{filename},
    get_option('thumb_dir') . $$fileinfo{thumb}, $$fileinfo{ext},
    $$fileinfo{tn_width}, $$fileinfo{tn_height}) if $$fileinfo{ext} =~ /webm|gif|jpg|jpeg|png/;

  res(template('form_test')->(file => $fileinfo, title => 'File Upload'))
}

1;
