package Framework::Base;

use strict;

use parent qw(Exporter);

use JSON;
use Try::Tiny;
use File::Find;
use Encode qw(decode encode);
use Data::Entropy::Algorithms qw(rand_bits);
use Crypt::Eksblowfish::Bcrypt qw(bcrypt bcrypt_hash en_base64 de_base64);

use Framework::Request;
use Framework::Options;
use Framework::Strings;

our ($self, $env, $req, $res, $prefix, $templates, $templateglobals, @prefixes,
  @before_process_request, @before_dispatch);

our $routes = {
  GET => [],
  POST => []
};

our @EXPORT = (
  @Framework::Options::EXPORT,
  @Framework::Strings::EXPORT,
  qw(add_options option options add_strings string strings),
  qw(before_process_request before_dispatch request_handler),
  qw(get post route prefix res redirect get_res set_res is_ajax get_script_name),
  qw(header cookie make_error compile_template template add_template template_var),
  qw(decode_string encode_string clean_string urlenc escamp),
  qw(password_hash protocol_regexp url_regexp),
  qw(ip_info)
);

#
# Requests, responses, etc.
#

sub before_process_request {
  my $sub = shift;
  push @before_process_request, $sub;
}

sub before_dispatch {
  my $sub = shift;
  push @before_dispatch, $sub;
}

sub get {
  my ($path, $sub, $pathhandlers) = @_;
  route('GET', $path, $sub, $pathhandlers);
}

sub post {
  my ($path, $sub, $pathhandlers) = @_;
  route('POST', $path, $sub, $pathhandlers);
}

sub route {
  my ($methods, $path, $sub, $pathhandlers) = @_;
  my $methods = [ $methods ] unless ref $methods eq 'ARRAY';

  $path = $prefix . $path if $prefix;

  foreach my $method (@{$methods}) {
    push @{$$routes{$method}}, {
      handler => $sub,
      path_str => $path,
      path_arr => [
        map {
          $_ ? sub {
            return {
              var => "$_",
              handler => (index $_, ':') == 0 ? $$pathhandlers{ substr $_, 1 }
                : undef
            }
          }->() : ()
        } split('/', $path)
      ]
    }
  }
}

sub prefix {
  my ($prefix, $sub) = @_;

  # prefix('admin', sub {
  #   get('/user/:userid', sub {
  #     res(fetch_user(shift->{userid}))
  #   }
  # }

  # Set global prefix
  # route() sees global prefix and prepends it to anything it ads
  # Remove global prefix

  $Framework::Base::prefix = $prefix;
  $sub->();
  $Framework::Base::prefix = ''
}

sub set_res {
  $res = shift;
}

sub get_res {
  return $res;
}

sub request_handler {
  my ($self, $env) = @_;
  my ($match, $method, $path, @path_arr, $queryvars);
  ($Framework::Base::self, $Framework::Base::env) = ($self, $env);
  $templateglobals = {};

  try {
    $req = Framework::Request->new($env);
    $res = $req->new_response;
    $path = $req->path_info || '/';
    $method = $req->method;
    @path_arr = map { ($_ ne '') || ($_ eq "0") ? "$_" : () } split '/', $path;

    # get traditional query vars. vars from path are appended later.
    $queryvars = $method eq 'GET' ? $req->query_parameters : $req->body_parameters;

    foreach my $key (keys %{$req->uploads}) {
      if($queryvars->get($key)) {
        push @{$$queryvars{$key}}, $req->upload($key)
      }
      else {
        $queryvars->add($key, [ $req->upload($key) ])
      }
    }

    foreach my $key (keys %{$req->cookies}) {
      # never more than one value per key
      $queryvars->add($key, $req->cookies->{$key})
    }

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

    foreach my $sub (@before_dispatch) {
      $sub->($req, $queryvars, $path, \@path_arr)
    }

    # Maybe $queryvars and $req should be globals? It would cut down on some
    # boiler plate code...
    return $match->{handler}->($queryvars, $req) if $match != 0;
    make_error(string('s_invalidpath'), 404);
  }
  catch {
    if(option('debug_mode')) {
      local $SIG{__DIE__} = 'DEFAULT'; # thanks http://blog.64p.org/entry/20101109/1289291797
      die $_
    }

    $res = $req->new_response;
    return get_res() || make_error()
  }
}

sub res {
  my ($content, $contenttype, $status, $cookies, $headers, $return) = @_;

  if(ref($content)) {
    $content = to_json($content, { pretty => option('pretty_json') });
    $contenttype = 'application/json;charset='
      . option('charset') unless $contenttype
  }

  $res->content_type($contenttype || ('text/html; charset='
    . option('charset')));

  $res->body(encode_string($content, option('charset')));
  $res->content_encoding('gzip') if option('gzip');
  $res->status($status || 200);

  foreach my $key (keys %{$cookies}) {
    $res->cookies->{$key} = $$cookies{$key}
  }

  foreach my $header (@{$headers}) {
    $res->header($header)
  }

  set_res($res->finalize);

  return $Framework::Base::res if $return;
  goto RES_OVERRIDE
}

sub redirect {
  my ($url, $code) = @_;

  $res->redirect($url, ($code || 302));
  set_res($res->finalize);

  goto RES_OVERRIDE
}

sub header {
  $res->header($_[0])
}

sub cookie {
  $res->cookies->{$_[0]} = $_[1];
}

sub make_error {
  my ($content, $status, $contenttype, $debug) = @_;
  my $res;

  if(((is_ajax()) && (!$contenttype)) || (ref($content))) {
    $res = { error => $content }
  }
  else {
    $res = template('error')->(error => $content)
  }

  set_res(res($res, $contenttype, ($status || 500), undef, $debug));
  die $_, $content;
}

sub is_ajax {
  return 1 if $req->header('X-Requested-With') =~ /xmlhttprequest/i;
  return 0;
}

#
# Templates
#

sub init_templates {
  find(sub {
    if(!-d $_) {
      my ($fn, $ext) = split '\.', $_;
      my $str;

      # File::Find uses chdir so we only need the file name, not the full path
      open my $fh, '<:encoding(UTF-8)', $_ or die option('s_template_io_error'), "$!";
      while(my $row = <$fh>) {
        $str .= $row;
      }
      close $fh;
      chomp($str);

      if($ext eq 'wakap') {
        add_template($fn, compile_template($str, option('minify'), 1))
      }
      else {
        add_template($fn, compile_template($str, option('minify')))
      }
    }
  }, option('template_dir'));
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
  my ($str, $minify, $part) = @_;
  my ($code, $sub);

  $str = $minify ? minify_html($str) : $str;

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
        elsif($name eq 'part') { $code .= '$res.=eval{$$templates{' . $args . '}->()};' }
        elsif($name eq 'const') { my $const = eval $args; $const =~ s/(['\\])/\\$1/g; $code .= '$res.=\'' . $const . '\';' }
        elsif($name eq 'if') { $code .= 'if(eval{' . $args . '}){' }
        elsif($name eq 'loop')
        { $code .= 'my $__a=eval{' . $args . '};if($__a){for(@$__a){my %__v=%{$_};my %__ov;for(keys %__v){$__ov{$_}=$$_;$$_=$__v{$_};}' }
      }
    }
  }

  if(!$part) {
    $sub = eval 'no strict; sub { '
      . 'my $port=$ENV{SERVER_PORT}==80?"":":$ENV{SERVER_PORT}";'
      . 'my $self=$ENV{SCRIPT_NAME};'
      . 'my $absolute_self="http://$ENV{SERVER_NAME}$port$ENV{SCRIPT_NAME}";'
      . 'my ($path)=$ENV{SCRIPT_NAME}=~m!^(.*/)[^/]+$!;'
      . 'my $absolute_path="http://$ENV{SERVER_NAME}$port$path";'
      . 'my %__v=@_;my %__ov;for(keys %__v){$__ov{$_}=$$_;$$_=$__v{$_};}'
      . 'my $res;'
      #. 'my $section=get_section();'
      . $code
      . '$$_=$__ov{$_} for(keys %__ov);'
      . 'my $v=$templateglobals;'
      #. 'return !$minify ? $res : minify_html($res); }';
      . 'return $res; }';

    die "Template format error" unless $sub;
  }
  else {
    $sub = eval 'no strict; sub { my $res; ' . $code
    #. 'return !$minify ? $res : minify_html($res); }';
    . 'return $res }';
    die "Template format error" unless $sub;
  }

  return $sub;
}

sub include {
  my ($filename, $nostrip) = @_;

  open FILE, $filename or return '';
  my $file = do { local $/; <FILE> };

  $file = minify_html($file) unless $nostrip;

  return $file;
}

sub template_var {
  my ($key, $val) = @_;
  $$templateglobals{$key} = $val
}

sub tv {
  return $$templateglobals{$_[0]}
}

#
# HTML Utilities
#

my $protocol_re = qr{(?:http://|https://|ftp://|mailto:|news:|irc:)};
my $url_re = qr{(${protocol_re}[^\s<>()"]*?(?:\([^\s<>()"]*?\)[^\s<>()"]*?)*)((?:\s|<|>|"|\.||\]|!|\?|,|&#44;|&quot;)*(?:[\s<>()"]|$))};

sub protocol_regexp { return $protocol_re }

sub url_regexp { return $url_re }

sub parse_http_date {
	my ($date) = @_;
	my $months = { Jan => 0, Feb => 1, Mar=>2, Apr => 3, May => 4, Jun => 5,
    Jul => 6, Aug => 7, Sep => 8, Oct => 9, Nov => 10, Dec => 11 };

	if($date =~ /^[SMTWF][a-z][a-z], (\d\d) ([JFMASOND][a-z][a-z]) (\d\d\d\d) (\d\d):(\d\d):(\d\d) GMT$/) {
    return eval { timegm($6, $5, $4, $1, $$months{$2}, $3-1900) }
  }

	return undef;
}

#
# Sanitation, serialization, etc.
#

sub forbidden_unicode {
  my ($dec, $hex) = @_;

  return 1 if length($dec) > 7 or length($hex) > 7; # too long numbers

  my $ord = ($dec or hex $hex);
  return 1 if $ord > option('max_unicode'); # outside unicode range
  return 1 if $ord < 32; # control chars
  return 1 if $ord >= 0x7f and $ord <= 0x84; # control chars
  return 1 if $ord >= 0xd800 and $ord <= 0xdfff; # surrogate code points
  return 1 if $ord >= 0x202a and $ord <= 0x202e; # text direction
  return 1 if $ord >= 0xfdd0 and $ord <= 0xfdef; # non-characters
  return 1 if $ord % 0x10000 >= 0xfffe; # non-characters
  return 0;
}

sub encode_string {
  my ($str, $charset) = @_;

  $charset = option('charset') unless $charset;
  return encode($charset, $str, 0x0400);
}

sub decode_string {
  my ($str, $charset, $noentities) = @_;
  my $use_unicode = $charset ? 1 : 0;

  $charset = option('charset') unless $charset;
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

#
# Crypto code
#

sub password_hash {
  my ($password, $salt, $cost) = @_;

  if($salt =~ m/\A\$2(a?)\$([0-9]{2})\$([.\/A-Za-z0-9]{22})/) {
    return bcrypt($password, $salt);
  }
  else {
    {
      use bytes;
      $salt = rand_bits(128) if((length($salt) != 16) || (!$salt));
    }

    $cost = ($cost && $cost =~ /^[0-9]{2}$/ && $cost > 4 && $cost < 31) ? $cost : 10;

    my $hash = bcrypt_hash(
      { key_nul => 1, cost => $cost, salt => $salt }, $password);

    return "\$2a\$$cost\$" . en_base64($salt) . en_base64($hash);
  }
}

#
# Misc
#

sub get_script_name {
  return $$env{SCRIPT_NAME}
}

sub make_date {
	my ($time, $style, $locdays) = @_;

	my @days = qw(Sun Mon Tue Wed Thu Fri Sat);
	my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
	@{$locdays} = @days unless defined $locdays && ref $locdays eq 'ARRAY';

	if($style eq "2ch") {
		my @ltime = localtime($time);

		return sprintf("%04d-%02d-%02d %02d:%02d",
		  $ltime[5]+1900, $ltime[4]+1, $ltime[3], $ltime[2], $ltime[1]);
	}
	elsif($style eq "futaba" or $style eq "0") {
		my @ltime = localtime($time);

		return sprintf("%02d/%02d/%02d(%s)%02d:%02d",
		  $ltime[5]-100, $ltime[4]+1, $ltime[3], @{$locdays}[$ltime[6]], $ltime[2],$ltime[1]);
	}
	elsif($style eq "localtime") {
		return scalar(localtime($time));
	}
	elsif($style eq "tiny") {
		my @ltime = localtime($time);

		return sprintf("%02d/%02d %02d:%02d",
		  $ltime[4]+1, $ltime[3], $ltime[2], $ltime[1]);
	}
	elsif($style eq "http") {
		my ($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime($time);

    return sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT",
		  $days[$wday], $mday, $months[$mon], $year+1900, $hour, $min, $sec);
	}
	elsif($style eq "cookie") {
		my ($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime($time);

    return sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",
		  $days[$wday], $mday, $months[$mon], $year+1900, $hour, $min, $sec);
	}
	elsif($style eq "month") {
		my ($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime($time);

    return sprintf("%s %d",
		  $months[$mon], $year+1900);
	}
	elsif($style eq "2ch-sep93") {
		my $sep93 = timelocal(0,0,0,1,8,93);
		return make_date($time, "2ch") if($time < $sep93);

		my @ltime = localtime($time);

		return sprintf("%04d-%02d-%02d %02d:%02d",
		  1993, 9,int ($time-$sep93)/86400+1, $ltime[2], $ltime[1]);
	}
}

1;
