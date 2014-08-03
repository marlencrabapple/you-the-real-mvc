package FrameworkTest::Templates::Pass;

use strict;
use Framework;

our ($templates,$sections);

$$templates{pass_template} = compile_template($$sections{main_header}.q{
fourchan pass
}.$$sections{main_footer});

1;
