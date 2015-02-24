package FrameworkTest;

use strict;

use Framework;

use FrameworkTest::Utils;
use FrameworkTest::Strings;
use FrameworkTest::ConfigDefault;
use FrameworkTest::Config;

#
# Routes
#

our $session = {};

sub build {
  before_process_request(sub{

  });

  before_dispatch(sub{
    my ($env, $req, $params, $pathstr, $patharr) = @_;

    # check if user is banned before they can do anything
    if(my $ban = check_ban($req)) {
      if(is_ajax()) {
        res($ban)
      }

      res(template('banned')->(%{$ban}))
    }

    if(@{$patharr}[0] eq 'admin') {
      if((my $crypt = password_hash($$params{berra}, get_option('mana_pass'))) ne get_option('mana_pass')) {
        #make_error(get_option('s_wrongpass'));
        redirect(get_script_name() . '/login?notice=1');
      }
      else {
        $session = { crypt => $crypt };
      }
    }
  });

  get('/', sub {
    res(template('index')->(
      title => 'Just a test',
      content => 'Hello world!'
    ));
  });

  get('/derefer', sub {
    my ($params, $req) = @_;

    my $url = $$params{url};
    my $url_regexp = url_regexp();

    make_error(get_option('s_invalidurl')) unless ($url =~ /$url_regexp/sg);

    res(template('dereferrer')->(
      url => $url
    ))
  });

  get('/login', sub {
    my ($params) = @_:
    my $msg = get_string($$params{notice});

    res(template('index')->(
      title => 'Login',
      content => 'Login faget'.
      msg => $msg
    ))
  });

  get('/json', sub {
    res(['wait', 'what']);
  });

  get('/upload', sub {
    res(template('form_test')->(title => 'File Upload'));
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
    post_stuff(@_)
  });

  get('/admin/:board', sub {
    res("Congrats!");
  });
}

#
# Controllers
#

sub post_stuff {
  my ($params, $req) = @_;
  my ($file, $fileinfo);

  # handle file
  $file = $req->upload('file');

  if($file) {
    $fileinfo = process_file($file, time());

    if($$fileinfo{width}) {
      ($$fileinfo{tn_width}, $$fileinfo{tn_height}) = (get_thumbnail_dimensions($$fileinfo{width}, $$fileinfo{height}, 1));
      $$fileinfo{thumb} = $$fileinfo{filebase} . "s.$$fileinfo{tn_ext}";

      if($$filename{other}->{has_tn}) {
        $$fileinfo{tn_ext} = $$fileinfo{other}->{tn_ext}
      }
      else {
        if($$fileinfo{ext} eq 'webm') {
          $$fileinfo{tn_ext} = 'jpg'
        }
        else {
          $$fileinfo{tn_ext} = $$fileinfo{ext}
        }

        make_thumbnail(path_to('img_dir') . $$fileinfo{filename},
          path_to('thumb_dir') . $$fileinfo{thumb}, $$fileinfo{ext},
          $$fileinfo{tn_width}, $$fileinfo{tn_height}) if $$fileinfo{ext} =~ /webm|gif|jpg|jpeg|png/;
      }

      $$fileinfo{thumb_url} = path_to('thumb_dir', 1) . $$fileinfo{thumb};
      $$fileinfo{file_url} = path_to('img_dir', 1) . $$fileinfo{filename};
    }
    elsif() {

    }
  }
  else {
    make_error(get_option('s_nopic'))
  }

  res(template('form_test')->(file => $fileinfo, title => 'File Upload'))
}

1;
