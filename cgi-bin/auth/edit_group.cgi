#!/usr/bin/perl
use strict;
# CGI script to add a user, using the auth-lib.

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'auth_define.pl';
require 'auth-lib.pl';
use CGI qw(:cgi-lib); 

my $this_cgi = $ENV{'SCRIPT_NAME'};
print "Content-type: text/html\n\n\n";

my(%in);
&ReadParse(\%in);

if( ! defined ( $in{'group'}))
{
   print <<"EOT";
<html>
<head>
<title>Modify Group</title>
</head>
<body>

<p><H1>Modify Group</H1></p>

<HR>   

<form method="POST" action="$this_cgi">
Group <input type=text name="group" size=20>
<input type=submit value="Modify Group"> <input type=reset>
</form>
</body>
</html>
EOT
}
elsif( ! defined ( $in{'users'}))
{
   my($users,$permissions,$comment) = auth::get_group_info($in{group});
   print <<"EOT";
<html>
<head>
<title>Modify Group</title>
</head>
<body>

<p><H1>Modify Group</H1></p>

<HR>   
   
   Group: $in{group}
<form method="POST" action="$this_cgi">
   <input type=hidden name="group" value="$in{group}">
Users <input type=text name="users" value="$users" size=20>(user1,user2,...)<br>
Permissions <input type=text name="permissions" value="$permissions" size=20><br>
Comment <input type=text name="comment" value="$comment" size=20><br>
<input type=submit value="Modify"> <input type=reset>
</form>
</body>
</html>
EOT
}
else
{
   if(! auth::modify_group_info($in{'group'}, $in{'users'}, $in{'permissions'}, $in{'comment'}))
   {
      print "Sorry: Could not modify group info.\n";
   }
   else
   {
      print "Group modified: $in{group}\n";
   }
}
