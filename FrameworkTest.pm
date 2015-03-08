package FrameworkTest;

use strict;

use DBI;
use JSON;
use Data::Dumper;

use Framework;
use FrameworkTest::Post;
use FrameworkTest::Models;
use FrameworkTest::Utils;
use FrameworkTest::Strings;
use FrameworkTest::ConfigDefault;
use FrameworkTest::Config;

#
# Routes
#

our $dbh = Framework::Database->new([ option('sql_source'), option('sql_user'),
  option('sql_pass'), { AutoCommit => 1 } ], 1);

our $session = {};
our $board;

sub build {
  make_tripkey(option('secretkey_file')) if(!-e option('secretkey_file'));

  $dbh->wakeup();

  init_ban_table($dbh) unless $dbh->table_exists(option('sql_ban_table'));
  init_user_table($dbh) unless $dbh->table_exists(option('sql_user_table'));
  init_report_table($dbh) unless $dbh->table_exists(option('sql_report_table'));
  init_pass_table($dbh) unless $dbh->table_exists(option('sql_pass_table'));

  foreach my $board (keys %{options()}) {
    if($board ne 'global') {
      my $table = option('sql_post_table', $board) || $board . '_posts';

      init_post_table($dbh, $table) unless $dbh->table_exists($table);

      mkdir(path_to(undef, $board)) or die string('s_notwrite') . " ($!)"
        if(!-e path_to(undef, $board));
      mkdir(path_to('img_dir', $board)) or die string('s_notwrite') . " ($!)"
        if(!-e path_to('img_dir', $board));
      mkdir(path_to('thumb_dir', $board)) or die string('s_notwrite') . " ($!)"
        if(!-e path_to('thumb_dir', $board));
      mkdir(path_to('res_dir', $board)) or die string('s_notwrite') . " ($!)"
        if(!-e path_to('res_dir', $board))
    }
  }

  before_process_request(sub{
    # not much available here besides $env and $self so there's not much
    # less savvy users could do...
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
        redirect(get_script_name() . '/login?notice=1')
      }
      else {
        $session = { crypt => $crypt }
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

    make_error(string('s_invalidurl')) unless ($url =~ /$url_regexp/sg);

    res(template('dereferrer')->(
      url => $url
    ))
  });

  get('/ipinfo', sub {
    my ($params, $req) = @_;

    res(Dumper($$req{net_ip}))
  });

  get('/ipinfo/:ip', sub {

  });

  get('/:board', sub {
    res('wat');
  }, { board => sub { return is_board($_[0]) } });

  post('/:board/post', sub {
    post_stuff(@_)
  });

  get('/admin/:board', sub {
    res("Congrats!")
  });
}

#
# Controllers
#

sub post_stuff {
  my ($params, $req) = @_;
  my ($time, $post, $file, $fileinfo);

  $time = time();
  $post = FrameworkTest::Post->new($params);

  # file stuff
  $file = $req->upload('file');

  if($file) {
    $fileinfo = process_file($file, time());
    $$fileinfo{original_filename} = $$file{filename};

    # file was an image or webm or had a handler
    if($$fileinfo{width}) {
      ($$fileinfo{tn_width}, $$fileinfo{tn_height}) = (get_thumbnail_dimensions($$fileinfo{width}, $$fileinfo{height}, 1));

      # thumbnail was generated by external handler
      if($$fileinfo{other}->{has_thumb}) {
        $$fileinfo{tn_ext} = $$fileinfo{other}->{tn_ext};
        $$fileinfo{thumb} = $$fileinfo{filebase} . "s.$$fileinfo{tn_ext}";
        $$fileinfo{thumb_url} = path_to('thumb_dir', 1) . $$fileinfo{thumb}
      }
      else {
        # make thumbnail
        if($$fileinfo{ext} eq 'webm') {
          $$fileinfo{tn_ext} = 'jpg'
        }
        else {
          $$fileinfo{tn_ext} = $$fileinfo{ext}
        }

        $$fileinfo{thumb} = $$fileinfo{filebase} . "s.$$fileinfo{tn_ext}";

        make_thumbnail(path_to('img_dir') . $$fileinfo{filename},
          path_to('thumb_dir') . $$fileinfo{thumb}, $$fileinfo{ext},
          $$fileinfo{tn_width}, $$fileinfo{tn_height}, $$fileinfo{other}->{offset})
          if $$fileinfo{ext} =~ /webm|gif|jp(?:e)?g|png/;
      }

      $$fileinfo{thumb_url} = path_to('thumb_dir', 1) . $$fileinfo{thumb}
    }
    else {
      # check if filetype has a default icon
      if(my $icon = option('filetypes')->{$$fileinfo{ext}}) {
        open my $ih, '<', path_to($icon);
        binmode $ih;
        ($$fileinfo{tn_ext}, $$fileinfo{tn_width}, $$fileinfo{tn_height})
          = analyze_image(path_to($icon), $ih);
        close $ih;

        $$fileinfo{thumb} = $icon;
        $$fileinfo{thumb_url} = path_to($icon, 1);
      }
      else {
        # no thumbnail?
      }
    }

    $$fileinfo{file_url} = path_to('img_dir', 1) . $$fileinfo{filename};
  }
  else {
    make_error(get_option('s_nopic'))
  }

  res(template('form_test')->(file => $fileinfo, title => 'File Upload'))
}

sub is_board {
  my ($board) = @_;
  return 1 if options()->{$_[0]}->{sql_post_table};
  return 0
}

1;
