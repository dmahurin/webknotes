#!/usr/bin/perl
use strict;
# edit information on a user, using the auth-lib

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'auth_define.pl';
require 'auth_lib.pl';
use CGI qw(:cgi-lib); 

my $this_cgi = $ENV{'SCRIPT_NAME'};
print "Content-type: text/html\n\n\n";

my(%in);
&ReadParse(\%in);
my $username = auth::get_user();
if( ! defined($username) )
{
  print "Not logged in\n";
  exit(0);
}
my($user_info) = auth::get_user_info($username);


my $system_access;
if($user_info->{"Permissions"} =~ m:s:)
{
   $system_access = 1;
}

if( $in{"username"} and $in{"username"} ne $username )
{
   if($system_access)
   {
      $username = $in{username};
      $user_info = auth::get_user_info($username);
   }
   else
   {
      print "You do not have acces to change user info\n";
      exit(0);
   }
}

my($path, $access, $fullname, $email, $webpage) =
( $user_info->{"AuthRoot"}, $user_info->{"Permissions"},
  $user_info->{"Name"}, $user_info->{"Email"}, $user_info->{"Webpage"});

if( ! defined ( $in{'fullname'}))
{
   print <<"EOT";
<html>
<head>
<title>User Info</title>
</head>
<body>

<p><H1>Change User Info</H1></p>

<HR>   

<form method="POST" action="$this_cgi">
<p>User Name: $username</p>
EOT
   if($system_access)
   {
print <<"EOT";
<input type=hidden name="username" value="$username">
User Path<input type=text name="path" size=20 value="$path"><br>
Access Flags <input type=text name="access" value="$access" size=20>
(o-owner, r-read, c-create, m-modify, d-delete, u-upload, s-system)<br>
EOT
   }
   else
   {
print <<"EOT";
   <p>User Path: $path</p>
   <p>User Access: $access</p>
EOT
   }
   
print <<"EOT";
Password <input type=password name="password" size=20>
Password <input type=password name="password_verify" size=20><br>
Full Name <input type=text name="fullname" size=20 value="$fullname"><br>
Email <input type=text name="email" value="$email" size=20><br>
Web Page <input type=text name="webpage" value="$webpage" size=20><br>
<input type=submit value="Change User Info"> <input type=reset>
</form>
</body>
</html>
EOT
exit(0);
}

my $password;
if( defined($in{'password'}) and $in{password} ne "" )
{
   if($in{'password'} eq $in{'password_verify'})
   {
     $password = $in{'password'};
   }
   else
   {
     print "password verify did not match\n";
     exit(0);
   }
}
if($password eq "*")
{
   $user_info->{"PassKey"} ='*';
}
elsif($password ne "")
{
   $user_info->{"PassKey"}=auth::pcrypt1($password);
}

$user_info->{"Name"} = $in{'fullname'};
$user_info->{"Email"} =  $in{'email'};
$user_info->{"Webpage"} = $in{'webpage'};
if($system_access)
{
   $username = $in{username};
   $user_info->{"AuthRoot"} = $in{path};
   $user_info->{"Permissions"} = $in{access};
}

if(! &auth::write_user_info(auth::check_user_name($username), $user_info))
{
   print "Could not modify user information?\n";
   exit(0);
}
print "User information modified\n";
