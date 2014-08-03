package Framework::Utils;

use base qw(Exporter);

our ($options) = { global => {} };
our @EXPORT = (
  qw/$options, get_option get_ip encode_string decode_string clean_string/
);

sub get_option {

}

sub get_ip {
  
}

sub encode_string {

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
