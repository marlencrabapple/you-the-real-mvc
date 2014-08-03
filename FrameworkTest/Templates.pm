package FrameworkTest::Templates;

use strict;
use Framework;
use base qw(Exporter);

our ($sections,$templates);
our @EXPORT = (
  @Framework::EXPORT,
  qw($sections $templates)
);

use FrameworkTest::Templates::Pass;

$$sections{main_header} = q{
<!doctype html>
<head>
  <title>asdf</title>
</head>
<body>
};

$$sections{main_footer} = q{
</body>
};

$$templates{test_template} = compile_template($$sections{main_header}.q{
<div style="background:#ddd;width:1024px;margin:10px auto 0;">
  <p>oh god how did i get here i am not good with computer</p>
  <ul>
    <li><var $escape_test></li>
    <li><!var $escape_test></li>
  </ul>
</div>
}.$$sections{main_footer});

1;
