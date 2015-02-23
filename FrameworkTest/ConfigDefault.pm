package FrameworkTest::ConfigDefault;

use strict;

use Framework;

add_option('debug_mode', 1);
add_option('minify', 1);

add_option('static_dir', './static');
add_option('template_dir', './templates');

add_option('sql_ban_table', 'bans');
add_option('sql_user_table', 'users');
add_option('sql_report_table', 'reports');
add_option('sql_pass_table', 'pass');

add_option('max_threads_index', 15);
add_option('max_replies_index', 5);

add_option('img_dir', 'src/');
add_option('thumb_dir', 'thumb/');
add_option('res_dir', 'res/');

add_option('max_kb', 10000);
add_option('max_image_width', 10000);
add_option('max_image_height', 10000);
add_option('max_image_pixels', 10000 * 10000);

add_option('tn_max_width', 150);
add_option('tn_max_height', 150);
add_option('tn_max_width_op', 250);
add_option('tn_max_height_op', 250);
add_option('animated_thumbnails', 1);
add_option('convert_path', 'gm convert');
add_option('thumbnail_quality', 70);

add_option('allow_webm', 1);
add_option('ffmpeg_path', 'ffmpeg');
add_option('ffprobe_path', 'ffprobe');
add_option('webm_max_length', 120);
add_option('webm_allow_audio', 1);

# taken mostly from analyze_webm()
my $videohandler = sub {
  my ($file, $filebase) = @_;
	my ($ffprobe, $stdout, $width, $height, $tn_w, $tn_h, @keep);

  my $filepath = $file->path;
  my $thumbpath = FrameworkTest::path_to('thumb_dir') . $filebase . "s.jpg";

	# get webm info
  $ffprobe = get_option('ffprobe_path') . ' -v quiet -print_format json -show_format '
    . '-show_streams ' . $file->path;

	$stdout = `$ffprobe`;
	$stdout = from_json($stdout) or return 1;

	# check if file is legitimate
	make_error(get_option('s_upfail')) if(!%$stdout); # empty json response from ffprobe
	#make_error(get_option('s_badformat')) if(scalar @{$$stdout{streams}} > 2); # too many streams

  foreach my $stream (@{$$stdout{streams}}) {
    if($$stream{codec_type} eq 'video') {
      make_error(get_option('s_badformat')) unless $$stream{width} and $$stream{height};
      ($width, $height) = ($$stream{width}, $$stream{height});

      #push @keep, "-map 0:$$stream{index}"
    }
    elsif($$stream{codec_type} eq 'audio') {
      #push @keep, "-map 0:$$stream{index}"
    }
  }

  ($tn_w, $tn_h) = FrameworkTest::get_thumbnail_dimensions($width, $height, 1);

  my $ffmpeg = get_option('ffmpeg_path');

  # trying to strip streams we don't know anything about. no idea if its
  # necessary or not.
  # maybe we can add this to some sort of event handler that's ran after the
  # file is copied...

  # if(scalar @keep) {
  #   my $mapcmd = "$ffmpeg -y -i $filepath " . join(' ', @keep) . " -c:v copy -c:a copy out_$filepath";
  #   print `$mapcmd`, "\n";
  #   print $?, "\n";
  # }

  `$ffmpeg -i $filepath -v quiet -ss 00:00:00 -an -vframes 1 -f mjpeg -vf scale=$tn_w:$tn_h $thumbpath 2>&1`;
  return ($width, $height, { tn_width => $tn_w, tn_height => $tn_h, has_thumb => 1, tn_ext => 'jpg' })
};

add_option('filetypes', {
  mp4 => $videohandler,
  mkv => $videohandler,
  flv => $videohandler,
  avi => $videohandler
});

add_option('forbidden_extensions', []);

add_option('munge_unknown', '.unknown');

1;
