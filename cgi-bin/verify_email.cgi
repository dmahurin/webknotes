#!/usr/bin/perl
use strict;
# edit information on a user, using the auth-lib

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'mailer_lib.pl';
require 'auth_define.pl';
require 'auth_lib.pl';
use CGI qw(:cgi-lib); 

my($my_main) = auth::localize_sub(\&main);
&$my_main;

sub main
{

my $this_cgi = $ENV{'SCRIPT_NAME'};
print "Content-type: text/html\n\n\n";

my(%in);
&ReadParse(\%in);
my $thisusername = auth::get_user();
if( ! defined($thisusername) )
{
  print "Not logged in\n";
  exit(0);
}
my($user_info) = auth::get_user_info($thisusername);


my $system_access;
if($user_info->{"Permissions"} =~ m:s:)
{
   $system_access = 1;
}
my $username = $in{username};
unless(defined($username)) { $username = $thisusername}

if( $username ne $thisusername )
{
   if($system_access)
   {
      $user_info = auth::get_user_info($username);
   }
   else
   {
      print "You do not have acces to change user info\n";
      exit(0);
   }
}


if(defined($in{"action"}) and $in{"action"} eq "send_key")
{
   my $newkey = auth::create_vword();
   my $cryptkey = auth::pcrypt1($newkey);
   $user_info->{"EmailVerifyKey"} = $cryptkey;
   if(&auth::write_user_info(auth::check_user_name($username), $user_info))
   {
   print "User information modified<br>\n";
   my $email = $user_info->{"Email"};
   mailer::send_email('WebKNotes email verify key', $mailer::define::admin_email,$email, "Verify key is:\n$newkey\n");
   print "mail sent to $email\n";
   }
   else
   {
      print "Could not modify user information?\n";
   }
}
elsif(defined ($in{"email_verify_key"}))
{
   if($user_info->{"EmailVerifyKey"} eq auth::pcrypt1($in{"email_verify_key"}))
   {
      unless($user_info->{"Permissions"} =~ m:v:)
      { $user_info->{"Permissions"} .= 'v'; }
      undef($user_info->{"EmailVerifyKey"});

if(! &auth::write_user_info(auth::check_user_name($username), $user_info))
{
   print "Could not modify user information?<br>\n";
}
else
{
print "User information modified<br>\n";
}
   }
   else
   {
       print "Incorrect email verify key<br>\n";
   }
}
print <<"EOT";
<html>
<head>
<title>Verify User Email</title>
</head>
<body>

<p><H1>Verify User Email</H1></p>

<HR>   

<p>User Name: $username</p>
<p>email: $user_info->{"Email"}</p>
<form method="POST" action="$this_cgi">
EOT
   if($username ne $thisusername)
   {
       print "<input type=hidden " .
	" name=\"username\" value=\"$username\"><br>\n";
   }
print <<"EOT";
   <input type=hidden name="action" value="send_key">
   <input type=submit value="Send Verify Key">
</form>
EOT
if($user_info->{EmailVerifyKey})
{
print <<"EOT";
<form method="POST" action="$this_cgi">
EOT
   if($username ne $thisusername)
   {
       print "<input type=hidden " .
	" name=\"username\" value=\"$username\"><br>\n";
   }
   
print <<"EOT";
   Email Verify Key<input type=password name="email_verify_key" size=20><br>
   <input type=submit value="Submit"> <input type=reset>
</form>
EOT
}
}
print <<"EOT";
</body>
</html>
EOT
