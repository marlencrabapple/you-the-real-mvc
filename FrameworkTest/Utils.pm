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
	return (undef, undef, 1) if(!%$stdout); # empty json response from ffprobe
	return (undef, undef, 1) unless($$stdout{format}->{format_name} eq 'matroska,webm'); # invalid format
	return (undef, undef, 2) if(scalar @{$$stdout{streams}} > 1); # too many streams
	return (undef, undef, 1) if(@{$$stdout{streams}}[0]->{codec_name} ne 'vp8'); # stream isn't webm
	return (undef, undef, 1) unless(@{$$stdout{streams}}[0]->{width} and @{$$stdout{streams}}[0]->{height});
	return (undef, undef, 1) if(!$$stdout{format} or $$stdout{format}->{duration} > 120);

	($width, $height) = (@{$$stdout{streams}}[0]->{width}, @{$$stdout{streams}}[0]->{height});
  return ($width, $height);
}

sub make_thumbnail {

}

sub process_file {
  my ($file, $time) = @_;

  make_error(get_option('s_toobig')) if $file->size > get_option('max_kb') * 1024;
  make_error(get_option('s_empty')) if $file->size <= 0;

  # Plack::Request::Upload doesn't provide a file handle like CGI.pm so we have
  # to create one on our own.
  open my $fh, "<", $file->path or make_error(get_option('s_upload_io') . ": $!");
  binmode $fh;

  my ($ext, $width, $height, $warning) = analyze_image($file->path, $fh);

  if(($ext eq 'webm') && ($warning)) {
    make_error(get_option('s_invalidwebm')) if $warning == 1;
    make_error(get_option('s_webmaudio')) if $warning == 2;
  }

  my $known = $width || get_options('filetypes')->{$ext};

  make_error(get_option('s_badformat')) unless(get_option('allow_unknown') or $known);
	make_error(get_option('s_badformat')) if(grep { $_ eq $ext } @{get_option('forbidden_extensions')});
	make_error(get_option('s_toobig')) if(get_option('max_image_width') and $width > get_option('max_image_width'));
	make_error(get_option('s_toobig')) if(get_option('max_image_height') and $height > get_option('max_image_height'));
	make_error(get_option('s_toobig')) if(get_option('max_image_pixels') and ($width * $height) > get_option('max_image_pixels'));

  # generate random filename - fudges the microseconds
  my $filebase = $time . sprintf("%03d", int(rand(1000)));
	my $filename = get_option('img_dir') . "$filebase.$ext";
	my $thumbnail = get_option('thumb_dir') . $filebase . "s.$ext";
	$filename .= get_option('munge_unknown') unless($known);

  # copy file, get md5, etc.
  my ($md5, $buffer) = @_;

  open my $out_fh, ">>", $filename or make_error(get_option('s_upload_io') . ": $!");
  binmode $out_fh;
  while(read($fh, $buffer, 1024)) {
    print $out_fh $buffer
  }
  close $fh;
  close $out_fh;

  return ($ext, $width, $height);
}

1;
