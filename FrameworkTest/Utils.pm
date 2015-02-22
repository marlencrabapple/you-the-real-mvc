package FrameworkTest::Utils;

use strict;

use parent 'Exporter';
use Framework;

our @EXPORT = (
  qw(analyze_image process_file get_thumbnail_dimensions make_thumbnail)
);

#
# Image Utilities
#

sub analyze_image {
  my ($file, $handle) = @_;
	my (@res);

	safety_check($file);

	return ("jpg", @res) if(@res = analyze_jpeg($handle));
	return ("png", @res) if(@res = analyze_png($handle));
	return ("gif", @res) if(@res = analyze_gif($handle));

	if(get_option('allow_webm')) {
		return ("webm", @res) if(@res = analyze_webm($file));
	}

	# find file extension for unknown files
	my ($ext) = $file =~ /\.([^\.]+)$/;
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

  my ($filename, $ext) = split('\.', $file);
  return () unless $ext eq 'webm';

	# get webm info
  $ffprobe = get_option('ffprobe_path');
	$stdout = `$ffprobe -v quiet -print_format json -show_format -show_streams $file`;
	$stdout = from_json($stdout) or return 1;

	# check if file is legitimate
	return (undef, undef, { warning => 1 }) if(!%$stdout); # empty json response from ffprobe
	return (undef, undef, { warning => 1 }) unless($$stdout{format}->{format_name} eq 'matroska,webm'); # invalid format
	return (undef, undef, { warning => 2 }) if(scalar @{$$stdout{streams}} > (get_option('webm_allow_audio') ? 2 : 1)); # too many streams
	return (undef, undef, { warning => 3 }) if(!$$stdout{format} or $$stdout{format}->{duration} > get_option('webm_max_length'));

  foreach my $stream (@{$$stdout{streams}}) {
    if($$stream{codec_type} eq 'video') {
      return (undef, undef, { warning => 1 }) if $$stream{codec_name} ne 'vp8';
      return (undef, undef, { warning => 1 }) unless $$stream{width} and $$stream{height};
      ($width, $height) = ($$stream{width}, $$stream{height})
    }
    elsif($$stream{codec_type} ne 'audio') {
      return (undef, undef, { warning => 1 })
    }
  }

  return ($width, $height);
}

sub make_thumbnail {
  my ($file, $thumb, $ext, $tn_width, $tn_height) = @_;
  my $quality = get_option('thumbnail_quality');
  my $convert = get_option('convert_path') || 'convert';

  if($ext eq 'webm') {
	  my $ffmpeg = get_option('ffmpeg_path');
    $thumb =~ s/webm/jpg/i;
	  `$ffmpeg -i '$file' -v quiet -ss 00:00:00 -an -vframes 1 -f mjpeg -vf scale=$tn_width:$tn_height $thumb 2>&1`;

	  return 1 unless $?;
  }
  else {
    my $transparency = $ext =~ /\.(png|gif)$/ ? '-background transparent' : '-background white';
    my $method;

    if($ext eq 'gif') {
      if(get_option('animated_thumbnails')) {
        $method = '-coalesce -sample';
      }
      else {
        $file .= '[0]';
      }
    }
    else {
      $method = '-resize';
    }

    print $method, "\n";

    `$convert $transparency $file $method ${tn_width}x${tn_height}! -quality $quality $thumb`;

    return 2 unless $?;
  }
}

sub get_thumbnail_dimensions {
  my ($width, $height, $op) = @_;
	my ($tn_width, $tn_height, $max_w, $max_h);

  $max_w = $op ? get_option('tn_max_width_op') : get_option('tn_max_width');
  $max_h = $op ? get_option('tn_max_height_op') : get_option('tn_max_height');

	if($width <= $max_w and $height <= $max_h) {
		$tn_width = $width;
		$tn_height = $height;
	}
	else {
		$tn_width = $max_w;
		$tn_height = int(($height * ($max_w)) / $width);

		if($tn_height > $max_h) {
			$tn_width = int(($width * ($max_h)) / $height);
			$tn_height = $max_h;
		}
	}

	return ($tn_width, $tn_height)
}

sub process_file {
  my ($file, $time) = @_;

  make_error(get_option('s_toobig')) if $file->size > get_option('max_kb') * 1024;
  make_error(get_option('s_empty')) if $file->size <= 0;

  # Plack::Request::Upload doesn't provide a file handle like CGI.pm so we have
  # to create one on our own.
  open my $fh, "<", $file->path or make_error(get_option('s_upload_io') . ": $!");
  binmode $fh;

  my ($ext, $width, $height, $other) = analyze_image($file->path, $fh);

  # no reason why we can't throw these errors earlier...
  if(($ext eq 'webm') && ($$other{warning})) {
    make_error(get_option('s_invalidwebm')) if $$other{warning} == 1;
    make_error(get_option('s_webmaudio')) if $$other{warning} == 2;
    make_error(get_option('s_webmduration')) if $$other{warning} == 3;
  }

  my $known = ($width || get_option('filetypes')->{$ext}) ? 1 : 0;

  make_error(get_option('s_badformat')) unless(get_option('allow_unknown') or $known);
	make_error(get_option('s_badformat')) if(grep { $_ eq $ext } @{get_option('forbidden_extensions')});
	make_error(get_option('s_toobig')) if(get_option('max_image_width') and $width > get_option('max_image_width'));
	make_error(get_option('s_toobig')) if(get_option('max_image_height') and $height > get_option('max_image_height'));
	make_error(get_option('s_toobig')) if(get_option('max_image_pixels') and ($width * $height) > get_option('max_image_pixels'));

  # generate random filename - fudges the microseconds
  my $filebase = $time . sprintf("%03d", int(rand(1000)));
	my $filename = "$filebase.$ext";
	$filename .= get_option('munge_unknown') unless($known);

  # check if a handler exists for a custom file type
  if(ref(get_option('filetypes')->{$ext}) eq 'CODE') {
    ($width, $height, $other) = get_option('filetypes')->{$ext}->($file, $filebase);
  }

  # copy file, get md5, etc.
  my ($md5sum, $md5, $buffer) = @_;

  $md5sum = 'md5sum ' . $file->path;
  $md5 = `$md5sum`;
	($md5) = $md5 =~ /^([0-9a-f]+)/ unless($?);

  if($md5) {
    # i guess this is where we would check for dupes
  }

  open my $out_fh, ">>", get_option('img_dir') . $filename
    or make_error(get_option('s_upload_io') . ": $!");

  binmode $out_fh;
  while(read($fh, $buffer, 1024)) {
    print $out_fh $buffer
  }
  close $fh;
  close $out_fh;

  return {
    filename => $filename,
    filebase => $filebase,
    ext => $ext,
    width => $width,
    height => $height,
    md5 => $md5,
    other => $other
  }
}

1;
