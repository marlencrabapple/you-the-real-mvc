package FrameworkTest::Templates;

use strict;
use Framework;
use parent 'FrameworkTest';
use base qw(Exporter);

use FrameworkTest::Config;
use FrameworkTest::Strings;

our ($sections,$templates);
our @EXPORT = (
  @FrameworkTest::EXPORT,
  qw($sections $templates)
);

#die @FrameworkTest::Strings::EXPORT;

#use FrameworkTest::Templates::Pass;

#die Dumper(\@Framework::EXPORT,\@FrameworkTest::EXPORT);

$$sections{main_header} = q{
<!doctype html>
<head>
  <title>asdf</title>
  <meta charset="<!var get_option('charset',$board)>">
  <loop $styles>
    <if $default>
    </if>
  </loop>
</head>
<body>
<div class="nav topnav">
  <div class="leftnav">
    <loop $groups>
      [
      <loop $boards>

      </loop>
      ]
    </loop>
  </div>
  <div class="rightnav">
  </div>
</div>
<div class="boardheader">
  <div class="logo">
  </div>
  <div class="title">
    <h1>
      <var $title><br>
      <small><var $subtitle></small>
    </h1>
  </div>
</div>
};

$$sections{main_footer} = q{
<div class="footer">
</div>
</body>
};

$$sections{post_form} = q{

};

$$sections{reply} = q{

};

$$sections{op} = q{

};

$$templates{board_index_template} = compile_template($$sections{main_header}.q{
<div class="postformwrapper">
  <form class="postform" id="mainpostform">
    <div class="postrow">
      <div class="postblock">
        <var S_NAME_FIELD>
      </div>
      <div class="postfield">
        <input type="text" name="name" class="postinput">
      </div>
    </div>
    <div class="postrow">
      <div class="postblock">
        <const S_LINK_FIELD>
      </div>
      <div class="postfield">
        <input type="text" name="link" class="postinput">
      </div>
    </div>
    <div class="postrow">
      <div class="postblock">
        <const S_SUBJECT_FIELD>
      </div>
      <div class="postfield">
        <input type="text" name="subject" class="postinput">
      </div>
    </div>
    <div class="postrow">
      <div class="postblock">
        <const S_COMMENT_FIELD>
      </div>
      <div class="postfield">
        <textarea name="comment" class="postinput"></textarea>
      </div>
    </div>
    <if get_option('enable_recaptcha', $board)>
    <div class="postrow">
      <div class="postblock">
        <const S_CAPTCHA_FIELD>
      </div>
      <div class="postfield">
        <script type="text/javascript">
          var RecaptchaOptions = {
            theme : 'custom',
            custom_theme_widget: 'recaptcha_widget'
          };
        </script>
        <div id="recaptcha_widget" style="display:none">
          <div id="recaptcha_image"></div>
          <div class="recaptcha_only_if_incorrect_sol" style="color:red">Incorrect please try again</div>

          <span class="recaptcha_only_if_image">Enter the words above:</span>
          <span class="recaptcha_only_if_audio">Enter the numbers you hear:</span>

          <input type="text" id="recaptcha_response_field" name="recaptcha_response_field" />

          <div><a href="javascript:Recaptcha.reload()">Get another CAPTCHA</a></div>
          <div class="recaptcha_only_if_image"><a href="javascript:Recaptcha.switch_type('audio')">Get an audio CAPTCHA</a></div>
          <div class="recaptcha_only_if_audio"><a href="javascript:Recaptcha.switch_type('image')">Get an image CAPTCHA</a></div>

          <div><a href="javascript:Recaptcha.showhelp()">Help</a></div>
        </div>

        <script type="text/javascript"
          src="http://www.google.com/recaptcha/api/challenge?k=<!var get_option('recaptcha_public_key')>">
        </script>

        <noscript>
          <iframe src="http://www.google.com/recaptcha/api/noscript?k=<!var get_option('recaptcha_public_key')>"
            height="300" width="500" frameborder="0"></iframe><br>
          <textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
          <input type="hidden" name="recaptcha_response_field"
            value="manual_challenge">
        </noscript>

			  <if get_option('pass_enabled')>
				  <div class="passnotice">
					  Bypass this CAPTCHA.
					  <!-- glaukaba pass message -->
				  </div>
			  </if>
      </div>
    </div>
    </if>
  </form>
</div>
<div class="threads">
  <loop $threads>
  <div class="thread">
    <loop $posts>
      <div class="postcontainer">
        <if !$parent>
        <div class="post op">
          <div class="postinfo">
            No. <!var $num>
          </div>
          <blockquote>
            <!var $comment>
          </blockquote>
        </div>
        <div class="omitted">
          Omitted Replies: <!var $omitted>, Omitted Images: <!var $omittedimages>
        </div>
        </if>
        <if $parent>
        <div class="post reply">
          <div class="postinfo">
            No. <!var $num>
          </div>
          <blockquote>
            <!var $comment>
          </blockquote>
        </div>
        </if>
    </div>
    </loop>
  </div>
  <hr>
  </loop>
</div>
}.$$sections{main_footer});

1;
