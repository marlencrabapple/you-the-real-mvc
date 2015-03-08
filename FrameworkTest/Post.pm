package FrameworkTest::Post;

use strict;

use Framework;

#
# A post class is probably the cleanest way to handle this kind of stuff in the
# long run.
#

our ($name, $subject, $comment, $noformat, $time, $date, $file);

sub new {
  my ($params, $file) = @_;

  #return $self;
}

sub file_handler {

}

1;
