package FrameworkTest;

use strict;

use Framework;

use FrameworkTest::Utils;
use FrameworkTest::Config;
use FrameworkTest::Strings;

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

  my $fileinfo = process_file($req->upload('file'), time());
  ($$fileinfo{tn_width}, $$fileinfo{tn_height}) = (get_thumbnail_dimensions($$fileinfo{width}, $$fileinfo{height}, 1));

  if($$fileinfo{other}->{tn_ext}) {
    $$fileinfo{tn_ext} = $$fileinfo{other}->{tn_ext}
  }
  elsif(($$fileinfo{ext} eq 'gif') && (!get_option('animated_thumbnails'))) {
    $$fileinfo{tn_ext} = 'jpg'
  }
  else {
    $$fileinfo{tn_ext} = $$fileinfo{ext}
  }

  $$fileinfo{thumb} = $$fileinfo{filebase} . "s.$$fileinfo{tn_ext}";

  make_thumbnail(get_option('img_dir') . $$fileinfo{filename},
    get_option('thumb_dir') . $$fileinfo{thumb}, $$fileinfo{ext},
    $$fileinfo{tn_width}, $$fileinfo{tn_height}) if $$fileinfo{ext} =~ /webm|gif|jpg|jpeg|png/;

  res({ fileinfo => $fileinfo });
}

1;
