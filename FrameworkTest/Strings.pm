package FrameworkTest::Strings;

use strict;

use Framework;

add_option('s_home', 'Home');										# Forwards to home page
add_option('s_admin', 'Manage');									# Forwards to Management Panel
add_option('s_return', 'Return');									# Returns to image board
add_option('s_posting', 'Posting mode: Reply');					# Prints message in red bar atop the reply screen

add_option('s_name', 'Name');										# Describes name field
add_option('s_email', 'Link');									# Describes e-mail field
add_option('s_subject', 'Subject');								# Describes subject field
add_option('s_submit', 'Submit');									# Describes submit button
add_option('s_comment', 'Comment');								# Describes comment field
add_option('s_uploadfile', 'File');								# Describes file field
add_option('s_nofile', 'No File');									# Describes file/no file checkbox
add_option('s_captcha', 'Verification');							# Describes captcha field
add_option('s_parent', 'Parent');									# Describes parent field on admin post page
add_option('s_delpass', 'Password');								# Describes password field
add_option('s_delexpl', '(for post and file deletion)');			# Prints explanation for password box (to the right)
add_option('s_spamtrap', 'Leave these fields empty (spam trap): ');

add_option('s_thumb', 'Thumbnail displayed, click image for full size.');	# Prints instructions for viewing real source
add_option('s_hidden', 'Thumbnail hidden, click filename for the full image.');	# Prints instructions for viewing hidden image reply
add_option('s_nothumb', 'No<br />thumbnail');								# Printed when there's no thumbnail
add_option('s_picname', 'File: ');											# Prints text before upload name/link
add_option('s_reply', 'Reply');											# Prints text for reply link
add_option('s_old', 'Marked for deletion (old).');							# Prints text to be displayed before post is marked for deletion, see: retention
add_option('s_abbr', '%d posts omitted. Click Reply to view.');			# Prints text to be shown when replies are hidden
add_option('s_abbrimg', '%d posts and %d images omitted. Click Reply to view.');						# Prints text to be shown when replies and images are hidden
add_option('s_abbr_m', '<strong>%d posts omitted</strong>');			# Prints text to be shown when replies are hidden
add_option('s_abbrimg_m', '<strong>%d posts</strong><br /><em>(%d have images)</em>');						# Prints text to be shown when replies and images are hidden
add_option('s_abbrtext', 'Comment too long. Click <a href="%s">here</a> to view the full text.');

add_option('s_repdel', 'Delete Post ');							# Prints text next to 'S_DELPICONLY' (left)
add_option('s_delpiconly', 'File Only');							# Prints text next to checkbox for file deletion (right)
add_option('s_delkey', 'Password ');								# Prints text next to password field for deletion (left)
add_option('s_delete', 'Delete');									# Defines deletion button's name

add_option('s_prev', 'Previous');									# Defines previous button
add_option('s_firstpg', 'Previous');								# Defines previous button
add_option('s_next', 'Next');										# Defines next button
add_option('s_lastpg', 'Next');									# Defines next button

add_option('s_weekdays', ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']);	# Defines abbreviated weekday names.

add_option('s_manaret', 'Return');										# Returns to HTML file instead of PHP--thus no log/SQLDB update occurs
add_option('s_manamode', 'Manager Mode');								# Prints heading on top of Manager page

add_option('s_manalogin', 'Manager Login');							# Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
add_option('s_adminpass', 'Manager Key:');							# Prints login prompt

add_option('s_manapanel', 'Management Panel');							# Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
add_option('s_manabans', 'Bans/Whitelist');							# Defines Bans Panel button
add_option('s_manaproxy', 'Proxy Panel');
add_option('s_manaspam', 'Spam');										# Defines Spam Panel button
add_option('s_manasqldump', 'SQL Dump');								# Defines SQL dump button
add_option('s_manasqlint', 'SQL Interface');							# Defines SQL interface button
add_option('s_manapost', 'Manager Post');								# Defines Manager Post radio button--allows the user to post using HTML code in the comment box
add_option('s_manarebuild', 'Rebuild caches');							#
add_option('s_mananuke', 'Nuke board');								#
add_option('s_manalogout', 'Log out');									#
add_option('s_manasave', 'Remember me on this computer');				# Defines Label for the login cookie checbox
add_option('s_manasub', 'Go');											# Defines name for submit button in Manager Mode

add_option('s_notags', 'HTML tags allowed. If you set the \'Format Text\' option to 1, no formatting will be done, and you will have to use HTML for line breaks and paragraphs.'); # Prints message on Management Board

add_option('s_mpdeleteip', 'Delete all');
add_option('s_mpdelete', 'Delete');									# Defines for deletion button in Management Panel
add_option('s_mparchive', 'Archive');
add_option('s_mpreset', 'Reset');										# Defines name for field reset button in Management Panel
add_option('s_mponlypic', 'File Only');								# Sets whether or not to delete only file, or entire post/thread
add_option('s_mpdeleteall', 'Del&nbsp;all');							#
add_option('s_mpban', 'Ban');											# Sets whether or not to delete only file, or entire post/thread
add_option('s_mptable', '<th>Post No.</th><th>Time</th><th>Subject</th>'.
                          '<th>Name</th><th>Comment</th><th>IP</th>');	# Explains names for Management Panel
add_option('s_imgspaceusage', '[ Space used: %d KB ]');				# Prints space used KB by the board under Management Panel

add_option('s_bantable', '<th>Type</th><th>Value</th><th>Comment</th><th>Action</th>'); # Explains names for Ban Panel
add_option('s_baniplabel', 'IP');
add_option('s_banmasklabel', 'Mask');
add_option('s_bancommentlabel', 'Comment');
add_option('s_banwordlabel', 'Word');
add_option('s_banip', 'Ban IP');
add_option('s_banword', 'Ban word');
add_option('s_banwhitelist', 'Whitelist');
add_option('s_banremove', 'Remove');
add_option('s_bancomment', 'Comment');
add_option('s_bantrust', 'No captcha');
add_option('s_bantrusttrip', 'Tripcode');

add_option('s_proxytable', '<th>Type</th><th>IP</th><th>Expires</th><th>Date</th>'); # Explains names for Proxy Panel
add_option('s_proxyiplabel', 'IP');
add_option('s_proxytimelabel', 'Seconds to live');
add_option('s_proxyremoveblack', 'Remove');
add_option('s_proxywhitelist', 'Whitelist');
add_option('s_proxydisabled', 'Proxy detection is currently disabled in configuration.');
add_option('s_badip', 'Bad IP value');

add_option('s_spamexpl', 'This is the list of domain names Wakaba considers to be spam.<br />'.
                           'You can find an up-to-date version <a href="http://wakaba.c3.cx/antispam/antispam.pl?action=view&amp;format=wakaba">here</a>, '.
                           'or you can get the <code>spam.txt</code> file directly <a href="http://wakaba.c3.cx/antispam/spam.txt">here</a>.');
add_option('s_spamsubmit', 'Save');
add_option('s_spamclear', 'Clear');
add_option('s_spamreset', 'Restore');

add_option('s_sqlnuke', 'Nuke password:');
add_option('s_sqlexecute', 'Execute');

add_option('s_toobig', 'This image is too large!  Upload something smaller!');
add_option('s_toobigornone', 'Either this image is too big or there is no image at all.  Yeah.');
add_option('s_reporterr', 'Error: Cannot find reply.');					# Returns error when a reply (res) cannot be found
add_option('s_upfail', 'Error: Upload failed.');							# Returns error for failed upload (reason: unknown?)
add_option('s_norec', 'Error: Cannot find record.');						# Returns error when record cannot be found
add_option('s_nocaptcha', 'Error: No verification code on record - it probably timed out.');	# Returns error when there's no captcha in the database for this IP/key
add_option('s_badcaptcha', 'Error: Wrong verification code entered.');		# Returns error when the captcha is wrong
add_option('s_badformat', 'Error: File format not supported.');			# Returns error when the file is not in a supported format.
add_option('s_strref', 'Error: String refused.');							# Returns error when a string is refused
add_option('s_unjust', 'Error: Unjust POST.');								# Returns error on an unjust POST - prevents floodbots or ways not using POST method?
add_option('s_nopic', 'Error: No file selected. Did you forget to click "Reply"?');	# Returns error for no file selected and override unchecked
add_option('s_notext', 'Error: No comment entered.');						# Returns error for no text entered in to subject/comment
add_option('s_toolong', 'Error: Too many characters in text field.');		# Returns error for too many characters in a given field
add_option('s_notallowed', 'Error: Posting not allowed.');					# Returns error for non-allowed post types
add_option('s_unusual', 'Error: Abnormal reply.');							# Returns error for abnormal reply? (this is a mystery!)
add_option('s_badhost', 'Error: You are banned.<br />Reason:');							# Returns error for banned host ($badip string)
add_option('s_badhostproxy', 'Error: This proxy is banned!');	# Returns error for banned proxy ($badip string)
add_option('s_renzoku', 'Error: Flood detected, post discarded.');			# Returns error for $sec/post spam filter
add_option('s_renzoku2', 'Error: Flood detected, file discarded.');		# Returns error for $sec/upload spam filter
add_option('s_renzoku3', 'Error: Flood detected.');						# Returns error for $sec/similar posts spam filter.
add_option('s_proxy', 'Error: Open proxy detected.');						# Returns error for proxy detection.
add_option('s_dupe', 'Error: This file has already been posted <a href="%s">here</a>.');	# Returns error when an md5 checksum already exists.
add_option('s_dupename', 'Error: A file with the same name already exists.');	# Returns error when an filename already exists.
add_option('s_nothreaderr', 'Error: Thread does not exist.');				# Returns error when a non-existant thread is accessed
add_option('s_baddelpass', 'Error: Incorrect password for deletion.');		# Returns error for wrong password (when user tries to delete file)
add_option('s_wrongpass', 'Error: Management password incorrect.');		# Returns error for wrong password (when trying to access Manager modes)
add_option('s_virus', 'Error: Possible virus-infected file.');				# Returns error for malformed files suspected of being virus-infected.
add_option('s_notwrite', 'Error: Could not write to directory.');				# Returns error when the script cannot write to the directory, the chmod (777) is wrong
add_option('s_spam', 'Spammers are not welcome here.');					# Returns error when detecting spam

add_option('s_sqlconf', 'SQL connection failure');							# Database connection failure
add_option('s_sqlfail', 'Critical SQL problem!');							# SQL Failure

add_option('s_redir', 'If the redirect didn\'t work, please choose one of the following mirrors:');    # Redir message for html in REDIR_DIR

add_option('s_class', 'Your user class does not have permission to do this.'); # Permissions error
add_option('s_reports', 'Report Queue'); # Report Queue

add_option('s_locked', 'You cannot reply to a locked thread.'); # Thread is locked

add_option('s_invalidwebm', 'Invalid or corrupt WebM file.');
add_option('s_webmaudio', 'WebM files with audio are not allowed.');


1;
