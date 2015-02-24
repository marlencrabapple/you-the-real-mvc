package FrameworkTest::ConfigDefault;

use strict;

use Framework;

add_option('debug_mode', 0);
add_option('minify', 0);

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

add_option('max_kb', 4 * 1024);
add_option('max_image_width', 10000);
add_option('max_image_height', 10000);
add_option('max_image_pixels', 10000 * 10000);

add_option('tn_max_width', 125);
add_option('tn_max_height', 125);
add_option('tn_max_width_op', 250);
add_option('tn_max_height_op', 250);
add_option('animated_thumbnails', 1);
add_option('convert_path', 'gm convert');
add_option('thumbnail_quality', 70);

add_option('allow_webm', 1);
add_option('ffmpeg_path', 'ffmpeg');
add_option('ffprobe_path', 'ffprobe');
add_option('webm_max_length', 300);
add_option('webm_allow_audio', 1);

add_option('forbidden_extensions', []);
add_option('munge_unknown', '.unknown');

1;
