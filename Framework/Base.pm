package Framework::Base;

use strict;

use JSON;
use Try::Tiny;
use File::Find;
use Plack::Util;
use Data::Dumper;
use HTML::Entities;
use Plack::Request;
use Plack::Response;
use base qw(Exporter);
use Encode qw(decode encode);
use Plack::Util::Accessor qw(rethrow);

our ($self, $env, $req, $section, $error, $templates, @before_process_request);
our $options = { global => {} };

our $routes = {
  GET => [],
  POST => []
};

our @EXPORT = (
  @Plack::Util::EXPORT,
  @Data::Dumper::EXPORT,
  @Plack::Request::EXPORT,
  @Plack::Response::EXPORT,
  qw($req $env rethrow encode decode Dumper get_option add_option set_section),
  qw(get_section before_process_request request_handler get post res),
  qw(make_error compile_template template add_template to_json from_json)
);

#
# Config Utils
#

sub get_option {
  my ($key, $section) = @_;

  $section = $section ? $section : 'global';
  return $$options{$section}->{$key} || $$options{'global'}->{$key};
}

sub add_option {
  my ($key, $val, $section) = @_;

  $section = $section ? $section : 'global';
  $$options{$section}->{$key} = $val;
}

sub set_section {
  $section = shift;
}

sub get_section {
  return $section;
}

#
# Requests, responses, etc.
#

sub before_process_request {
  my $self = shift;
  push @before_process_request, shift;
}

sub get {
  my ($path, $sub, $pathhandlers) = @_;
  add_route('GET', $path, $sub, $pathhandlers);
}

sub post {
  my ($path, $sub, $pathhandlers) = @_;
  add_route('POST', $path, $sub, $pathhandlers);
}

sub add_route {
  my ($method, $path, $sub, $pathhandlers) = @_;

  push $$routes{$method}, {
    handler => $sub,
    path_str => $path,
    path_arr => [
      map {
        $_ ? sub {
          return {
            var => "$_",
            handler => (index $_, ':') == 0 ? $$pathhandlers{ substr $_, 1 } : undef
          }
        }->() : ()
      } split('/', $path)
    ]
  };
}

sub set_error {
  $error = shift;
}

sub get_error {
  return $error;
}

sub request_handler {
  my ($self, $env) = @_;
  my ($match, $method, $path, @path_arr, $queryvars);
  ($Framework::Base::self, $Framework::Base::env) = ($self, $env);

  try {
    $req = Plack::Request->new($env);
    $path = $req->path_info;
    $method = $req->method;
    @path_arr = map { ($_ ne '') || ($_ eq "0") ? "$_" : () } split '/', $path;

    # get traditional query vars. vars from path are appended later.
    # might omit uploads. should probably check that out
    $queryvars = $method eq 'GET' ? $req->query_parameters : $req->body_parameters;

    # loop through defined routes
    foreach my $route (@{$$routes{$method}}) {
      my $matches = 0;

      for(my $i = 0; $i < scalar(@path_arr); $i++) {
        last unless scalar(@path_arr) == scalar(@{$$route{path_arr}});
        my $section = $$route{path_arr}->[$i];

        if(defined $$section{handler}) {
          my ($okay, $var);
          ($okay, $var) = $$section{handler}->($path_arr[$i]);

          if($okay) {
            $queryvars->add(substr($$section{var}, 1) =>
              ($var = defined $var ? $var : $path_arr[$i]));
            $matches = 1;
          }
          else {
            $matches = 0;
          }
        }
        else {
          if((index $$section{var}, ':') != -1) { # anything goes
            $queryvars->add(substr($$section{var}, 1) => $path_arr[$i]);
            $matches = 1;
          }
          elsif($path_arr[$i] eq $$section{var}) { # match via string comparison
            $matches = 1;
          }
          else {
            $matches = 0;
          }
        }

        # not sure if there's any case where a route is valid if this changes back to 1
        last if $matches == 0;
      }

      if(($matches) || (($path eq '/') && ($$route{path_str} eq '/'))) {
        $match = $route;
        last;
      }
    }

    return $match->{handler}->($queryvars, $req) if $match != 0;
    make_error(get_option('invalid_path'), 404);
  }
  catch {
    if(get_option('debug_mode', get_section())) {
      local $SIG{__DIE__} = 'DEFAULT'; # thanks http://blog.64p.org/entry/20101109/1289291797
      die $_;
    }

    return get_error();
  }
}

sub res {
  my ($content, $contenttype, $status) = @_;

  if(ref($content)) {
    $content = to_json($content);
    $contenttype = 'application/json' unless $contenttype
  }

  return [
    $status || 200,
    [ 'Content-type', ($contenttype || 'text/html; charset='
      . get_option('charset', get_section())) ],
    [ encode_string($content, get_section()) ]
  ]
}

sub make_error {
  my ($content, $status, $contenttype) = @_;
  my $res;

  if((($req->header('HTTP_X_REQUESTED_WITH') =~ /xmlhttprequest/i) && (!$contenttype)) || (ref($content))) {
    $res = { error => $content }
  }
  else {
    $res = template('error')->(error => $content)
  }

  set_error(
    res($res, $contenttype, ($status || 500))
  );

  die $_, $content;
}

#
# Templates
#

sub init_templates {
  # scan template dir for templates (parts first), eval them, and add them with
  # add template

  find(sub {
    if(!-d $_) {
      my ($fn, $ext) = split '\.', $_;
      my $str;

      # File::Find uses chdir so we only need the file name, not the full path
      open my $fh, '<:encoding(UTF-8)', $_ or die get_option('template_io_error'), "$!";
      while(my $row = <$fh>) {
        $str .= $row;
      }
      close $fh;

      # if($ext eq 'wakap') {
      #   add_template($fn, $str)
      # }
      # else {
      #   add_template($fn, compile_template($str))
      # }

      add_template($fn, compile_template($str))
    }
  }, get_option('template_dir'));
}

sub template {
  my ($key) = @_;
  return $$templates{$key};
}

sub add_template {
  my ($key, $template) = @_;
  $$templates{$key} = $template;
}

sub compile_template {
  my ($str, $nostrip) = @_;
  my $code;

  while($str =~ m!(.*?)(<(/?)(var|\!var|part|const|if|loop)(?:|\s+(.*?[^\\]))>|$)!sg) {
    my ($html, $tag, $closing, $name, $args) = ($1, $2, $3, $4, $5);

    $html =~ s/(['\\])/\\$1/g;
    $code .= "\$res.='$html';" if(length $html);
    $args =~ s/\\>/>/g;

    if($tag) {
      if($closing) {
        if($name eq 'if') { $code .= '}' }
        elsif($name eq 'loop') { $code .= '$$_=$__ov{$_} for(keys %__ov);}}' }
      }
      else {
        if($name eq '!var') { $code .= '$res.=eval{' . $args . '};' }
        elsif($name eq 'var') { $code .= '$res.=clean_string(eval{' . $args . '});' }
        elsif($name eq 'part') { $code .= '$res.=eval{template(' . $args . ')->()};' }
        elsif($name eq 'const') { my $const = eval $args; $const =~ s/(['\\])/\\$1/g; $code .= '$res.=\'' . $const . '\';' }
        elsif($name eq 'if') { $code .= 'if(eval{'.$args.'}){' }
        elsif($name eq 'loop')
        { $code .= 'my $__a=eval{' . $args . '};if($__a){for(@$__a){my %__v=%{$_};my %__ov;for(keys %__v){$__ov{$_}=$$_;$$_=$__v{$_};}' }
      }
    }
  }

  my $sub = eval 'no strict; sub { '
    . 'my $port=$ENV{SERVER_PORT}==80?"":":$ENV{SERVER_PORT}";'
    . 'my $self=$ENV{SCRIPT_NAME};'
    . 'my $absolute_self="http://$ENV{SERVER_NAME}$port$ENV{SCRIPT_NAME}";'
    . 'my ($path)=$ENV{SCRIPT_NAME}=~m!^(.*/)[^/]+$!;'
    . 'my $absolute_path="http://$ENV{SERVER_NAME}$port$path";'
    . 'my %__v=@_;my %__ov;for(keys %__v){$__ov{$_}=$$_;$$_=$__v{$_};}'
    . 'my $res;'
    . 'my $section=get_section();'
    . $code
    . '$$_=$__ov{$_} for(keys %__ov);'
    . 'return $nostrip ? $res : minify_html($res); }';

  die "Template format error" unless $sub;

  return $sub;
}

sub include {
  my ($filename, $nostrip) = @_;

  open FILE, $filename or return '';
  my $file = do { local $/; <FILE> };

  $file = minify_html($file) unless $nostrip;

  return $file;
}

#
# Sanitation, serialization, etc.
#

sub forbidden_unicode {
  my ($dec, $hex) = @_;

  return 1 if length($dec) > 7 or length($hex) > 7; # too long numbers

  my $ord = ($dec or hex $hex);
  return 1 if $ord > get_option('max_unicode'); # outside unicode range
  return 1 if $ord < 32; # control chars
  return 1 if $ord >= 0x7f and $ord <= 0x84; # control chars
  return 1 if $ord >= 0xd800 and $ord <= 0xdfff; # surrogate code points
  return 1 if $ord >= 0x202a and $ord <= 0x202e; # text direction
  return 1 if $ord >= 0xfdd0 and $ord <= 0xfdef; # non-characters
  return 1 if $ord % 0x10000 >= 0xfffe; # non-characters
  return 0;
}

sub encode_string {
  my ($str, $section) = @_;
  return encode(get_option('charset', $section), $str, 0x0400);
}

sub decode_string {
  my ($str, $charset, $noentities) = @_;
  my $use_unicode = $charset ? 1 : 0;

  $str = decode($charset, $str) if $use_unicode;

  $str =~ s{(&#([0-9]*)([;&])|&#([x&])([0-9a-f]*)([;&]))}{
    my $ord=($2 or hex $5);
    if($3 eq '&' or $4 eq '&' or $5 eq '&') { $1 } # nested entities, leave as-is.
    elsif(forbidden_unicode($2,$5))  { "" } # strip forbidden unicode chars
    elsif($ord==35 or $ord==38) { $1 } # don't convert & or #
    elsif($use_unicode) { chr $ord } # if we have unicode support, convert all entities
    elsif($ord<128) { chr $ord } # otherwise just convert ASCII-range entities
    else { $1 } # and leave the rest as-is.
  }gei unless $noentities;

  $str =~ s/[\x00-\x08\x0b\x0c\x0e-\x1f]//g; # remove control chars

  return $str;
}

sub clean_string {
  my ($str, $cleanentities) = @_;

  if($cleanentities) { $str =~ s/&/&amp;/g } # clean up &
  else {
    $str =~ s/&(#([0-9]+);|#x([0-9a-fA-F]+);|)/
      if($1 eq "") { '&amp;' } # change simple ampersands
      elsif(forbidden_unicode($2,$3))  { "" } # strip forbidden unicode chars
      else { "&$1" } # and leave the rest as-is.
    /ge  # clean up &, excluding numerical entities
  }

  $str =~ s/\</&lt;/g; # clean up brackets for HTML tags
  $str =~ s/\>/&gt;/g;
  $str =~ s/"/&quot;/g; # clean up quotes for HTML attributes
  $str =~ s/'/&#39;/g;
  $str =~ s/,/&#44;/g; # clean up commas for some reason I forgot

  $str =~ s/[\x00-\x08\x0b\x0c\x0e-\x1f]//g; # remove control chars

  return $str;
}

sub escamp {
  my ($str) = @_;
  $str =~ s/&/&amp;/g;
  return $str;
}

sub urlenc {
  my ($str) = @_;
  $str =~ s/([^\w ])/"%".sprintf("%02x",ord $1)/sge;
  $str =~ s/ /+/sg;
  return $str;
}

sub clean_path {
  my ($str) = @_;
  $str =~ s!([^\w/._\-])!"%".sprintf("%02x",ord $1)!sge;
  return $str;
}

sub minify_html {
  my ($str) = @_;

  $str =~ s/^\s+//;
  $str =~ s/\s+$//;
  $str =~ s/\n\s*/ /sg;

  return $str;
}

sub clean_to_js {
  my $str = shift;

  $str =~ s/&amp;/\\x26/g;
  $str =~ s/&lt;/\\x3c/g;
  $str =~ s/&gt;/\\x3e/g;
  $str =~ s/&quot;/\\x22/g; #"
  $str =~ s/(&#39;|')/\\x27/g;
  $str =~ s/&#44;/,/g;
  $str =~ s/&#[0-9]+;/sprintf "\\u%04x",$1/ge;
  $str =~ s/&#x[0-9a-f]+;/sprintf "\\u%04x",hex($1)/gie;
  $str =~ s/(\r\n|\r|\n)/\\n/g;

  return "'$str'";
}

sub js_string {
  my $str = shift;

  $str =~ s/\\/\\\\/g;
  $str =~ s/'/\\'/g;
  $str =~ s/([\x00-\x1f\x80-\xff<>&])/sprintf "\\x%02x",ord($1)/ge;
  eval '$str=~s/([\x{100}-\x{ffff}])/sprintf "\\u%04x",ord($1)/ge';
  $str =~ s/(\r\n|\r|\n)/\\n/g;

  return "'$str'";
}

sub js_array {
  return "[" . (join ",", @_) . "]";
}

sub js_hash {
  my %hash = @_;
  return "{" . (join ",", map { "'$_':$hash{$_}" } keys %hash) . "}";
}

1;
