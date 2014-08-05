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

$$templates{admin_index_template} = compile_template($$sections{main_header}.q{
<h1><var $title></h1>
  <loop $threads>
    <loop $posts>
      <div style="background:#ddd;margin:5px 0<if $parent>;margin-left:150px</if>">
        <!var $num>.
        <blockquote><!var $comment></blockquote>
      </div>
      <if !$parent>
      <em>Ommited Replies: <!var $omitted>, Omitted Images: <!var $omittedimages></em>
      </if>
    </loop>
    <hr>
  </loop>
}.$$sections{main_footer});

1;
