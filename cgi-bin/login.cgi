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

my($my_main) = auth::localize_sub(\&main);
&$my_main;

sub main
{

my(%in);
&ReadParse(\%in);

my($user) = $in{'user'};

my($password) = $in{'password'};
my($path) = $in{'path'};
my($path_encoded) = CGI::escape($path);
my($next) = $in{'next'};

my $prefix = 
   $filedb::define::default_browse_index ?
   "$filedb::define::doc_wpath/" : "browse.cgi?";

if(defined($next))
{
  $next=$prefix if($next eq "");
  my $current_user =  auth::get_user();
  if(defined($current_user) and ((!defined($user)) or $current_user eq $user))
  {
   redirect("$next$path_encoded");
   exit(0);
  }
}

#$this_cgi = 'login.cgi';
my($this_cgi) = $ENV{'SCRIPT_NAME'};

if ( ! defined($password) )
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
END
if(defined($path))
{
   print "<input type=\"hidden\" name=\"path\" value=\"$path\">\n";
}
if(defined($next))
{
   print "<input type=\"hidden\" name=\"next\" value=\"$next\">\n";
}

   print <<"END";
User Name <input type=text name="user" value="$user" size=20><br>
Password <input type=password name="password" size=20><p>
<input type=submit value="Login"><input type=reset>
</form>
<p>
New users: Create a <a href="add_user.cgi">new account</a>.
<p>
Or, skip the login, and <a href="$next">login anonymously</a>.
</body>
</html>
END
   exit 0;
}

if(auth::check_pass($user, auth::get_user_info($user), $password))
{
   if(auth::create_session($user))
   {


      $next = $prefix unless(defined($next));
      my $line;
      print "Content-type: text/html\n\n";
 print "<html><head><meta HTTP-EQUIV=\"Refresh\" CONTENT=\"1; url=$next$path_encoded\"></head><html>\n";
      print "Now logged in <br>\n";
      print "Back to main <a href=\"${prefix}\">page</a>.\n";
      print "</html>";
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
}

sub redirect
{
   my($ref) = @_;

print "Content-type: text/html\n\n";
print <<"END";
<html><head>
<meta HTTP-EQUIV="Refresh" CONTENT="1; url=$ref">
</head>
<body>
<a href="$ref">$ref</a> should load automatically.

</body>
</html>
END
}
