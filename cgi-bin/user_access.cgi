#!/usr/bin/perl
use strict;
# CGI script that acts as index to other cgi auth cgi scripts

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'auth_define.pl';
require 'auth_lib.pl';

print "Content-type: text/html\n\n\n";

my $user = auth::get_user();

print "
<html>
<body>
<p><h1>User Access</h1></p>

<hr>

";

if(defined($user))
{
   print "You are logged as user: $user\n";
   print "<p><A href=\"logout.cgi\"> Logout </a></p>";
}
else
{
   print "You are not logged in\n<p>
<p><A href=\"login.cgi\">Login</a>:</p>
<form method=\"POST\" action=\"login.cgi\">
User Name <input type=text name=\"user\" size=20><br>
Password <input type=password name=\"password\" size=20><br>
<input type=submit value=\"Login\"><input type=reset><br>
</form>
      <hr>\n";
}   
   print"<p><form method=\"POST\" action=\"user_info.cgi\">
Change user info for
<input type=text name=\"username\" value=\"$user\" size=20>
<input type=submit value=\"Change User Info\">
</form>

<p><A href=\"add_user.cgi\"> Add new user </a></p>

<form method=\"POST\" action=\"show_user.cgi\">
Show info for another username <input type=text name=\"username\" size=20>
<input type=submit value=\"Show Info\">
</form>

<form method=\"POST\" action=\"show_group.cgi\">
Show info for a group <input type=text name=\"group\" size=20>
<input type=submit value=\"Show Group Info\">
</form>

</html>
</body>
";
