#!/usr/bin/perl
use strict;
# CGI script to add a user, using the auth-lib.

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'auth_define.pl';
require 'auth_lib.pl';
use CGI qw(:cgi-lib); 

my $this_cgi = $ENV{'SCRIPT_NAME'};
print "Content-type: text/html\n\n\n";

my(%in);
&ReadParse(\%in);

if( ! defined ( $in{'username'}))
{
   print <<"EOT";
<html>
<head>
<title>Add User</title>
</head>
<body>

<p><H1>Add User</H1></p>

<HR>   

<form method="POST" action="$this_cgi">
User Name <input type=text name="username" size=20><br>
Password <input type=password name="password" size=20>
Password Verify <input type=password name="password_verify" size=20><br>
Full Name <input type=text name="fullname" size=20><br>
Email <input type=text name="email" size=20><br>
Web Page <input type=text name="webpage" size=20><br>
<input type=submit value="Add User"> <input type=reset>
</form>
</body>
</html>
EOT
exit(0);
}

if( $in{'username'} =~ m:\W: )
{
   print "Illegal char\n";
   exit;
}

if( auth::user_exists($in{'username'}) )
{
   print "Sorry: User already exists\n";
   exit(0);
}

if( $in{password} ne $in{password_verify} )
{
   print "Two different passwords were entered\n";
   exit(0);
}

if(! auth::write_user_info(auth::check_user_name($in{'username'}), 
{ "PassKey"=>auth::pcrypt1($in{'password'}), 
   "AuthPath"=>$auth::define::newuser_path, 
   "Permissions"=>$auth::define::newuser_flags,
   "Name"=>$in{'fullname'},"Email"=> $in{'email'}, "Webpage"=>$in{'webpage'}, "RemoteHost"=>$ENV{REMOTE_HOST}, "RemoteAddr"=>$ENV{REMOTE_ADDR}
}))
{
   print "Sorry: Could not add user.\n";
   exit(0);
}
print "added user.<br>\n";
print "Now, go <a href=\"login.cgi\">login</a>.\n";
