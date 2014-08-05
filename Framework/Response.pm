package Framework::Response;

use strict;
use base qw(Exporter);
use Plack::Util;
use Plack::Request;
use Plack::Response;

use Framework::Utils;
use Framework::Routes;
use Framework::Request;
use Framework::Strings;

our @EXPORT = (
  qw/make_error res/,
  #@Framework::Routes::EXPORT
);

# sub make_error {
#   my ($content,$contenttype,$status) = @_;
#
#   return [
#     $status || 200,
#     ['Content-type', ($contenttype || 'text/html; charset=' . get_option('charset'))],
#     [$content]
#   ];
# };

#sub make_error {
#  my ($content,$contenttype,$status) = @_;
#
#  return res($content,$contenttype,($status || 500))
#}

sub make_error {
  my ($content,$status,$contenttype) = @_;

  Framework::Request::set_error(
    res($content,$contenttype,($status || 500))
  );

  die;
}

sub res {
  my ($content,$contenttype,$status) = @_;

  return [
    $status || 200,
    ['Content-type', ($contenttype || 'text/html; charset=' . get_option('charset',get_section()))],
    [encode_string($content,get_section())]
  ]
}

1;
