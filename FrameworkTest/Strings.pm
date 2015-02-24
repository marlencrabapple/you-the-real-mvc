package FrameworkTest::Strings;

use strict;

use Framework;

add_strings({
  s_home => 'Home',										# Forwards to home page
  s_admin => 'Manage',									# Forwards to Management Panel
  s_return => 'Return',									# Returns to image board
  s_posting => 'Posting mode: Reply',					# Prints message in red bar atop the reply screen

  s_name => 'Name',										# Describes name field
  s_email => 'Link',									# Describes e-mail field
  s_subject => 'Subject',								# Describes subject field
  s_submit => 'Submit',									# Describes submit button
  s_comment => 'Comment',								# Describes comment field
  s_uploadfile => 'File',								# Describes file field
  s_nofile => 'No File',									# Describes file/no file checkbox
  s_captcha => 'Verification',							# Describes captcha field
  s_parent => 'Parent',									# Describes parent field on admin post page
  s_delpass => 'Password',								# Describes password field
  s_delexpl => '(for post and file deletion)',			# Prints explanation for password box (to the right)
  s_spamtrap => 'Leave these fields empty (spam trap):',

  s_thumb => 'Thumbnail displayed => click image for full size.',	# Prints instructions for viewing real source
  s_hidden => 'Thumbnail hidden => click filename for the full image.',	# Prints instructions for viewing hidden image reply
  s_nothumb => 'No<br />thumbnail',								# Printed when there',s no thumbnail
  s_picname => 'File:',											# Prints text before upload name/link
  s_reply => 'Reply',											# Prints text for reply link
  s_old => 'Marked for deletion (old).',							# Prints text to be displayed before post is marked for deletion => see: retention
  s_abbr => '%d posts omitted. Click Reply to view.',			# Prints text to be shown when replies are hidden
  s_abbrimg => '%d posts and %d images omitted. Click Reply to view.',						# Prints text to be shown when replies and images are hidden
  s_abbr_m => '<strong>%d posts omitted</strong>',			# Prints text to be shown when replies are hidden
  s_abbrimg_m => '<strong>%d posts</strong><br /><em>(%d have images)</em>',						# Prints text to be shown when replies and images are hidden
  s_abbrtext => 'Comment too long. Click <a href="%s">here</a> to view the full text.',

  s_repdel => 'Delete Post',							# Prints text next to 'S_DELPICONLY' (left)
  s_delpiconly => 'File Only',							# Prints text next to checkbox for file deletion (right)
  s_delkey => 'Password',								# Prints text next to password field for deletion (left)
  s_delete => 'Delete',									# Defines deletion button',s name

  s_prev => 'Previous',									# Defines previous button
  s_firstpg => 'Previous',								# Defines previous button
  s_next => 'Next',										# Defines next button
  s_lastpg => 'Next',									# Defines next button

  s_weekdays => ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'],	# Defines abbreviated weekday names.

  s_manaret => 'Return',										# Returns to HTML file instead of PHP--thus no log/SQLDB update occurs
  s_manamode => 'Manager Mode',								# Prints heading on top of Manager page

  s_manalogin => 'Manager Login',							# Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
  s_adminpass => 'Manager Key:',							# Prints login prompt

  s_manapanel => 'Management Panel',							# Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
  s_manabans => 'Bans/Whitelist',							# Defines Bans Panel button
  s_manaproxy => 'Proxy Panel',
  s_manaspam => 'Spam',										# Defines Spam Panel button
  s_manasqldump => 'SQL Dump',								# Defines SQL dump button
  s_manasqlint => 'SQL Interface',							# Defines SQL interface button
  s_manapost => 'Manager Post',								# Defines Manager Post radio button--allows the user to post using HTML code in the comment box
  s_manarebuild => 'Rebuild caches',							#
  s_mananuke => 'Nuke board',								#
  s_manalogout => 'Log out',									#
  s_manasave => 'Remember me on this computer',				# Defines Label for the login cookie checbox
  s_manasub => 'Go',											# Defines name for submit button in Manager Mode

  s_mpdeleteip => 'Delete all',
  s_mpdelete => 'Delete',									# Defines for deletion button in Management Panel
  s_mparchive => 'Archive',
  s_mpreset => 'Reset',										# Defines name for field reset button in Management Panel
  s_mponlypic => 'File Only',								# Sets whether or not to delete only file => or entire post/thread
  s_mpdeleteall => 'Del&nbsp;all',							#
  s_mpban => 'Ban',											# Sets whether or not to delete only file => or entire post/thread
  s_mptable => '<th>Post No.</th><th>Time</th><th>Subject</th>'.
                            '<th>Name</th><th>Comment</th><th>IP</th>',	# Explains names for Management Panel
  s_imgspaceusage => '[ Space used: %d KB ]',				# Prints space used KB by the board under Management Panel

  s_bantable => '<th>Type</th><th>Value</th><th>Comment</th><th>Action</th>', # Explains names for Ban Panel
  s_baniplabel => 'IP',
  s_banmasklabel => 'Mask',
  s_bancommentlabel => 'Comment',
  s_banwordlabel => 'Word',
  s_banip => 'Ban IP',
  s_banword => 'Ban word',
  s_banwhitelist => 'Whitelist',
  s_banremove => 'Remove',
  s_bancomment => 'Comment',
  s_bantrust => 'No captcha',
  s_bantrusttrip => 'Tripcode',

  s_badip => 'Bad IP value',

  s_spamexpl => 'This is the list of domain names Wakaba considers to be spam.<br />'.
                             'You can find an up-to-date version <a href="http://wakaba.c3.cx/antispam/antispam.pl?action=view&amp;format=wakaba">here</a> => '.
                             'or you can get the <code>spam.txt</code> file directly <a href="http://wakaba.c3.cx/antispam/spam.txt">here</a>.',
  s_spamsubmit => 'Save',
  s_spamclear => 'Clear',
  s_spamreset => 'Restore',

  s_sqlnuke => 'Nuke password:',
  s_sqlexecute => 'Execute',

  s_error => 'Error!',
  s_toobig => 'This image is too large!  Upload something smaller!',
  s_empty => 'The file you tried to upload is empty.',
  s_toobigornone => 'Either this image is too big or there is no image at all. Yeah.',
  s_reporterr => 'Cannot find reply.',					# Returns error when a reply (res) cannot be found
  s_upfail => 'Upload failed.',							# Returns error for failed upload (reason: unknown?)
  s_norec => 'Cannot find record.',						# Returns error when record cannot be found
  s_nocaptcha => 'No verification code on record - it probably timed out.',	# Returns error when there',s no captcha in the database for this IP/key
  s_badcaptcha => 'Wrong verification code entered.',		# Returns error when the captcha is wrong
  s_badformat => 'File format not supported.',			# Returns error when the file is not in a supported format.
  s_strref => 'String refused.',							# Returns error when a string is refused
  s_unjust => 'Unjust POST.',								# Returns error on an unjust POST - prevents floodbots or ways not using POST method?
  s_nopic => 'No file selected. Did you forget to click "Reply"?',	# Returns error for no file selected and override unchecked
  s_notext => 'No comment entered.',						# Returns error for no text entered in to subject/comment
  s_toolong => 'Too many characters in text field.',		# Returns error for too many characters in a given field
  s_notallowed => 'Posting not allowed.',					# Returns error for non-allowed post types
  s_unusual => 'Abnormal reply.',							# Returns error for abnormal reply? (this is a mystery!)
  s_badhost => 'You are banned.',							# Returns error for banned host ($badip string)
  s_badhostproxy => 'This proxy is banned!',	# Returns error for banned proxy ($badip string)
  s_renzoku => 'Flood detected => post discarded.',			# Returns error for $sec/post spam filter
  s_renzoku2 => 'Flood detected => file discarded.',		# Returns error for $sec/upload spam filter
  s_renzoku3 => 'Flood detected.',						# Returns error for $sec/similar posts spam filter.
  s_proxy => 'Open proxy detected.',						# Returns error for proxy detection.
  s_dupe => 'This file has already been posted <a href="%s">here</a>.',	# Returns error when an md5 checksum already exists.
  s_dupename => 'A file with the same name already exists.',	# Returns error when an filename already exists.
  s_nothreaderr => 'Thread does not exist.',				# Returns error when a non-existant thread is accessed
  s_baddelpass => 'Incorrect password for deletion.',		# Returns error for wrong password (when user tries to delete file)
  s_wrongpass => 'Management password incorrect.',		# Returns error for wrong password (when trying to access Manager modes)
  s_virus => 'Possible virus-infected file.',				# Returns error for malformed files suspected of being virus-infected.
  s_notwrite => 'Could not write to directory.',				# Returns error when the script cannot write to the directory => the chmod (777) is wrong
  s_spam => 'Spammers are not welcome here.',					# Returns error when detecting spam\

  s_invalidurl => 'Invalid URL.',
  s_derefer_title => 'Redirecting...',
  s_derefer_msg => 'Redirecting you to: '
,
  s_sqlconf => 'SQL connection failure',							# Database connection failure
  s_sqlfail => 'Critical SQL problem!',							# SQL Failure

  s_redir => 'If the redirect didn\'t work => please choose one of the following mirrors:',    # Redir message for html in REDIR_DIR

  s_class => 'Your user class does not have permission to do this.', # Permissions error
  s_reports => 'Report Queue', # Report Queue

  s_locked => 'You cannot reply to a locked thread.', # Thread is locked

  s_invalidwebm => 'Invalid or corrupt WebM file.',
  s_webmaudio => 'WebM files with audio are not allowed.',
  s_webmduration => 'WebM file is too long.',

  s_version => 'dev',
  s_footer => 'All trademarks and copyrights on this page are owned by their respective parties. Images uploaded are the responsibility of the Poster. Comments are owned by the Poster.'
});

1;
