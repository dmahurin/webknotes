#!/usr/bin/perl
use strict;
# cgi login scrip using auth-lib

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'auth_define.pl';
require 'auth_lib.pl';
use CGI qw(:cgi-lib);

my(%in);
&ReadParse(\%in);

my($user) = $in{'user'};

my($password) = $in{'password'};

#$this_cgi = 'login.cgi';
my($this_cgi) = $ENV{'SCRIPT_NAME'};

if ( ! defined($user) )
{
print "Content-type: text/html\n\n";
   print <<"END";
<html>
<head>
<title>Login</title>
</head>
<body>
<H1>User Login</H1> 
<P>
<HR>   
<form method="POST" action="$this_cgi">
User Name <input type=text name="user" size=20><br>
Password <input type=password name="password" size=20><p>
<input type=submit value="Login"><input type=reset>
</form>
</body>
</html>
END
   exit 0;
}

if(auth::check_pass($user, auth::get_user_info($user), $password))
{
   if(auth::create_session($user))
   {
      my $line;
      print "Content-type: text/html\n\n";
      print "Now logged in\n";
   }
   else
   {
      print "Content-type: text/html\n\n";
      print "Could not create session\n";
   }
}
else
{
   print "Content-type: text/html\n\n";
   print "login failed\n";
}