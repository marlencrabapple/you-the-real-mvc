package FrameworkTest::Utils;

use strict;

use parent 'Exporter';
use Framework;

our @EXPORT = (
  qw(analyze_image process_file make_thumbnail)
);

#
# Image Utilities
#

sub analyze_image {
  my ($file, $name) = @_;
	my (@res);

	safety_check($file);

	return ("jpg", @res) if(@res = analyze_jpeg($name));
	return ("png", @res) if(@res = analyze_png($name));
	return ("gif", @res) if(@res = analyze_gif($name));

	if(get_option('allow_webm')) {
		return ("webm", @res) if(@res = analyze_webm($file));
	}

	# find file extension for unknown files
	my ($ext) = $name =~ /\.([^\.]+)$/;
	return (lc($ext), 0, 0);
}

sub safety_check {
	my ($file) = @_;

	# Check for IE MIME sniffing XSS exploit - thanks, MS, totally appreciating this
	read $file, my $buffer, 256;
	seek $file, 0, 0;
	die "Possible IE XSS exploit in file" if $buffer =~ /<(?:body|head|html|img|plaintext|pre|script|table|title|a href|channel|scriptlet)/;
}

sub analyze_jpeg {
	my ($file) = @_;
	my ($buffer);

	read($file, $buffer, 2) or die $!;

	if($buffer eq "\xff\xd8") {
		OUTER:
		for(;;) {
			for(;;) {
				last OUTER unless(read($file, $buffer, 1));
				last if($buffer eq "\xff");
			}

			last unless(read($file, $buffer, 3) == 3);
			my ($mark, $size) = unpack("Cn", $buffer);
			last if($mark == 0xda or $mark == 0xd9); # SOS/EOI
			die "Possible virus in image" if($size < 2); # MS GDI+ JPEG exploit uses short chunks

      # SOF0..SOF2 - what the hell are the rest?
			if($mark >= 0xc0 and $mark <= 0xc2) {
				last unless(read($file, $buffer, 5) == 5);

				my ($bits, $height, $width) = unpack("Cnn", $buffer);
				seek($file, 0, 0);

				return($width, $height);
			}

			seek($file ,$size - 2, 1);
		}
	}

	seek($file, 0, 0);
	return ();
}

sub analyze_png {
	my ($file) = @_;
	my ($bytes, $buffer);

	$bytes = read($file, $buffer, 24);
	seek($file, 0, 0);
	return () unless($bytes == 24);

	my ($magic1, $magic2, $length, $ihdr, $width, $height) = unpack("NNNNNN", $buffer);

	return () unless($magic1 == 0x89504e47 and $magic2 == 0x0d0a1a0a and $ihdr == 0x49484452);
	return ($width, $height);
}

sub analyze_gif {
	my ($file) = @_;
	my ($bytes, $buffer);

	$bytes = read($file, $buffer, 10);
	seek($file, 0, 0);
	return () unless($bytes == 10);

	my ($magic, $width, $height) = unpack("A6 vv", $buffer);

	return () unless($magic eq "GIF87a" or $magic eq "GIF89a");
	return ($width, $height);
}

sub analyze_webm {
	my ($file) = @_;
	my ($ffprobe, $stdout, $width, $height);

	$ffprobe = get_option('ffprobe_path');

	# get webm info
	$stdout = `$ffprobe -v quiet -print_format json -show_format -show_streams $file`;
	$stdout = decode_json($stdout) or return 1;

	# check if file is legitimate
	return 1 if(!%$stdout); # empty json response from ffprobe
	return 1 unless($$stdout{format}->{format_name} eq 'matroska,webm'); # invalid format
	return 2 if(scalar @{$$stdout{streams}} > 1); # too many streams
	return 1 if(@{$$stdout{streams}}[0]->{codec_name} ne 'vp8'); # stream isn't webm
	return 1 unless(@{$$stdout{streams}}[0]->{width} and @{$$stdout{streams}}[0]->{height});
	return 1 if(!$$stdout{format} or $$stdout{format}->{duration} > 120);

	($width, $height) = (@{$$stdout{streams}}[0]->{width}, @{$$stdout{streams}}[0]->{height});
}

sub make_thumbnail {

}

sub process_file {

}

1;
