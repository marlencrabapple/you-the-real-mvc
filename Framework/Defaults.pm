package Framework::Defaults;

use strict;

use Framework::Base;

#
# Options
#

add_option('charset', 'UTF-8');
add_option('debug_mode', 1);
add_option('max_unicode', 1114111);
add_option('template_dir', './remplates');
add_option('minify', 0);
add_option('pretty_json', 1);

#
# Strings
#

add_option('s_invalidpath', 'Invalid path.');
add_option('s_template_io_error', 'Error opening template file.');

#
# Templates
#

add_template('error', compile_template(q{
  <h1>Error!</h1>
  <p><var $error></p>
}));

1;