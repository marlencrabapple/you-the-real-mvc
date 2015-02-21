package FrameworkTest;

use strict;

use Framework;
use FrameworkTest::Config;

sub build {
  get('/', sub {
    res("Hello world!");
  });

  get('/json', sub {
    make_error(['wait', 'what'], 403);
    res({ hello => 'world'});
  });

  get('/admin/:board', sub {
    my ($params) = @_;

    res("Just a test");
  }, {
    board => sub { 1 }
  });

  get('/admin/:board/:page', sub {
    my ($params) = @_;

    res("Just a test\n\nPage: $$params{page} of $$params{board}");
  }, {
    board => sub { 1 },
    page => sub {
      # This doesn't work because aetting the page to '0' causes request_handler()
      # to think we didn't return anything after the initial 1 because of Perl's
      # lack of typing.
      #
      # Update: Got it working, but its bad practice anyways so we'll throw a 404
      # like any other site.

      # # Set page to zero if invalid and avoid a 404
      # my $page = shift;
      # $page = ($page =~ /[0-9]+/) ? $page : '0';
      #
      # return (1, $page);

      return 1 if shift =~ /[0-9]+/;
      return 0;
    }
  });
}

1;
