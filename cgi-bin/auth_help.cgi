#!/usr/bin/perl
use strict;
# CGI script that acts as index to other cgi auth cgi scripts

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-2002 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

print "Content-type: text/html\n\n\n";

print "
<html>
<body>
<p><h1>User Access</h1></p>

<hr>


<p><A href=\"login.cgi\">Login</a>:</p>
<form method=\"POST\" action=\"login.cgi\">
User Name <input type=text name=\"user\" size=20><br>
Password <input type=password name=\"password\" size=20><br>
<input type=submit value=\"Login\"><input type=reset><br>
</form>
<hr>

<p><form method=\"POST\" action=\"user_info.cgi\">
Change user info for
<input type=text name=\"username\" size=20>
<input type=submit value=\"Change User Info\">(blank=current user)
</form>
<p><A href=\"logout.cgi\"> Logout </a></p>

<p><A href=\"add_user.cgi\"> Add new user </a></p>

<form method=\"POST\" action=\"show_user.cgi\">
Show info for another username <input type=text name=\"username\" size=20>
<input type=submit value=\"Show Info\">
</form>

</html>
</body>
";
