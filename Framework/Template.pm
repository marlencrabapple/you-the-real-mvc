package Framework::Template;

use base qw(Exporter);
use Framework::Utils;

our ($sections,$templates);
our @EXPORT = (
  qw($sections $templates compile_template include strip_whitespace)
);

sub compile_template {
  my ($str,$nostrip) = @_;
  my $code;

  $str = strip_whitespace($str) unless $nostrip;

  while($str =~ m!(.*?)(<(/?)(var|\!var|const|if|loop)(?:|\s+(.*?[^\\]))>|$)!sg) {
		my ($html,$tag,$closing,$name,$args) = ($1,$2,$3,$4,$5);

		$html =~ s/(['\\])/\\$1/g;
		$code .= "\$res.='$html';" if(length $html);
		$args =~ s/\\>/>/g;

		if($tag) {
			if($closing) {
				if($name eq 'if') { $code.='}' }
				elsif($name eq 'loop') { $code.='$$_=$__ov{$_} for(keys %__ov);}}' }
			}
			else {
				if($name eq '!var') { $code .= '$res.=eval{'.$args.'};' }
        elsif($name eq 'var') { $code .= '$res.=clean_string(eval{'.$args.'});' }
				elsif($name eq 'const') { my $const = eval $args; $const =~ s/(['\\])/\\$1/g; $code .= '$res.=\''.$const.'\';' }
				elsif($name eq 'if') { $code .= 'if(eval{'.$args.'}){' }
				elsif($name eq 'loop')
				{ $code .= 'my $__a=eval{'.$args.'};if($__a){for(@$__a){my %__v=%{$_};my %__ov;for(keys %__v){$__ov{$_}=$$_;$$_=$__v{$_};}' }
			}
		}
	}

	my $sub = eval
		'no strict; sub { '.
		'my $port=$ENV{SERVER_PORT}==80?"":":$ENV{SERVER_PORT}";'.
		'my $self=$ENV{SCRIPT_NAME};'.
		'my $absolute_self="http://$ENV{SERVER_NAME}$port$ENV{SCRIPT_NAME}";'.
		'my ($path)=$ENV{SCRIPT_NAME}=~m!^(.*/)[^/]+$!;'.
		'my $absolute_path="http://$ENV{SERVER_NAME}$port$path";'.
		'my %__v=@_;my %__ov;for(keys %__v){$__ov{$_}=$$_;$$_=$__v{$_};}'.
		'my $res;'.
		$code.
		'$$_=$__ov{$_} for(keys %__ov);'.
		'return $res; }';

	die "Template format error" unless $sub;

	return $sub;
}

sub include {
  my ($filename) = @_;

	open FILE,$filename or return '';
	my $file = do { local $/; <FILE> };

	$file =~ s/^\s+//;
	$file =~ s/\s+$//;
	$file =~ s/\n\s*/ /sg;

	return $file;
}

sub strip_whitespace {
  my ($str) = @_;

  $str =~ s/^\s+//;
	$str =~ s/\s+$//;
	$str =~ s/\n\s*/ /sg;

  return $str;
}

1;
