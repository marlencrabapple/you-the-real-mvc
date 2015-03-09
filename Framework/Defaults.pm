package Framework::Defaults;

use strict;

use Framework::Base;

#
# Options
#

add_options({
  'global' => {
    charset => 'UTF-8',
    debug_mode => 1,
    max_unicode => 1114111,
    template_dir => './templates',
    minify => 0,
    pretty_json => 1
  }
});

#
# Strings
#

add_strings({
  s_sqlconf => 'SQL connection failure',
  s_sqlfail => 'Critical SQL problem!',
  s_invalidpath => 'Invalid path.',
  s_template_io_error => 'Error opening template file.'
});

#
# Templates
#

add_template('error', compile_template(q{
  <h1>Error!</h1>
  <p><var $error></p>
}));

1;
