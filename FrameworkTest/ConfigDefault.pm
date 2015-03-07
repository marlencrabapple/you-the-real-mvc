package FrameworkTest::ConfigDefault;

use strict;

use Framework;

add_options({
  global => {
    site_name => 'Glaukaba',
    board_name => 'Glaukaba Image Board',
    subtitle => 'Nothing to see here',
    
    sql_ban_table => 'bans',
    sql_user_table => 'users',
    sql_report_table => 'reports',
    sql_pass_table => 'pass',

    max_threads_index => 15,
    max_replies_index => 5,
    max_replies_thread => 300,
    max_images_thread => 150,

    img_dir => 'src/',
    thumb_dir => 'thumb/',
    res_dir => 'res/',

    max_kb => 4 * 1024,
    max_image_width => 10000,
    max_image_height => 10000,
    max_image_pixels => 10000 * 10000,

    tn_max_width => 125,
    tn_max_height => 125,
    tn_max_width_op => 250,
    tn_max_height_op => 250,
    animated_thumbnails => 1,
    convert_path => 'gm convert',
    thumbnail_quality => 70,

    allow_webm => 1,
    ffmpeg_path => 'ffmpeg',
    ffprobe_path => 'ffprobe',
    webm_max_length => 300,
    webm_allow_audio => 1,
    webm_tn_offset => 0,

    forbidden_extensions => ['php', 'php3' ,'php4', 'phtml', 'shtml', 'cgi', 'pl',
      'pm', 'py', 'r', 'exe', 'dll', 'scr', 'pif', 'asp', 'cfm', 'jsp', 'vbs'],
    munge_unknown => '.unknown',
    allow_unknown => 0,

    debug_mode => 0,
    minify => 0,
    static_dir => './static',
    template_dir => './templates',
    secretkey_file => 'secret'
  }
});

1;
