package Framework::Defaults;

use strict;

use Framework::Base;

#
# Options
#

add_option('charset', 'UTF-8');
add_option('debug_mode', 1);
add_option('max_unicode', 1114111);

#
# Strings
#

add_option('invalid_path', 'Invalid path.');

#
# Templates
#

add_template('error', compile_template(q{
  <h1>Error!</h1>
  <p><var $error></p>
}));

1;
