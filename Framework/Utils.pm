package Framework::Utils;

use strict;

use Plack::Util::Accessor qw(rethrow);

use base qw(Exporter);
use Encode qw(decode encode);
use Data::Dumper;

use constant MAX_UNICODE => 1114111;

our $_section;
our ($options) = { global => {} };
our @EXPORT = (
  @Data::Dumper::EXPORT,
  qw/$options get_option add_option get_ip forbidden_unicode encode_string decode_string clean_string set_section get_section rethrow/
);

sub get_option {
  my ($key,$section) = @_;

  $section = $section ? $section : 'global';
  return $$options{$section}->{$key} || $$options{'global'}->{$key};
}

sub add_option {
  my ($key,$val,$section) = @_;

  $section = $section ? $section : 'global';
  $$options{$section}->{$key} = $val;
}

sub set_section {
  $_section = shift;
}

sub get_section {
  return $_section;
}

sub get_ip {

}

sub forbidden_unicode {
	my ($dec,$hex) = @_;
	return 1 if length($dec)>7 or length($hex)>7; # too long numbers
	my $ord = ($dec or hex $hex);

	return 1 if $ord>MAX_UNICODE; # outside unicode range
	return 1 if $ord<32; # control chars
	return 1 if $ord>=0x7f and $ord<=0x84; # control chars
	return 1 if $ord>=0xd800 and $ord<=0xdfff; # surrogate code points
	return 1 if $ord>=0x202a and $ord<=0x202e; # text direction
	return 1 if $ord>=0xfdd0 and $ord<=0xfdef; # non-characters
	return 1 if $ord % 0x10000 >= 0xfffe; # non-characters
	return 0;
}


sub encode_string {
  my ($str,$section)=@_;

	return encode(get_option('charset',$section),$str,0x0400);
}

sub decode_string {

}

sub clean_string {
  my ($str,$cleanentities) = @_;

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

1;
