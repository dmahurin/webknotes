#!/usr/bin/perl
use strict;
# show information on a user, using the auth-lib

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'auth_define.pl';
require 'auth-lib.pl';
use CGI qw(:cgi-lib); 

my $this_cgi = $ENV{'SCRIPT_NAME'};
print "Content-type: text/html\n\n\n";

my %in;

&ReadParse(\%in);
my $username = $in{'username'};
if( $username =~ m:\W: )
{
   print "Illegal char\n";
   exit;
}

if( ! defined($username) )
{
   print "Username not defined\n";
   exit;
}

my($password, $path, $access, $fullname, $email, $webpage, @otherinfo) =
&auth::get_user_info($username);

print <<"EOT";
<html>
<head>
<title>User Info</title>
</head>
<body>
<H1>User Info</H1> 
<HR>   
EOT
if(defined($fullname))
{
   print "
User Name: $username <br>
Full Name: $fullname <br>
Email: <a href=\"mailto:$email\">$email</a> <br>
Web Page: <a href=\"$webpage\">$webpage</a> <br>
";
}
else
{
   print "User info not found for user: $username.\n";
}

print "</body></html>";
