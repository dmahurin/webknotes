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
my $username = $in{'group'};
if( $username =~ m:[^\w-]: )
{
  print "Illegal char\n";
  exit;
}

if( ! defined($username) )
{
  print "Group not defined\n";
  exit;
}

my($members, $access, $name, @other) = &auth::get_group_info($username);

print <<"EOT";
<html>
<head>
<title>Group Info</title>
</head>
<body>
<H1>Group: $name</H1> 
EOT
my($username);
print "<table border=\"1\"><tr><th>Full Name</th><th>User Name</th><th>email</th><th>web page</th></tr>\n";

for $username (split(',', $members))
{
   my($password, $path, $access, $fullname, $email, $webpage, @otherinfo) =
&auth::get_user_info($username);
   
   my($username_more) = (defined($auth::define::userinfocgi) ? ("<a href=\"$auth::define::userinfocgi$username\">$username</a>") : $username);
   if(defined($fullname))
   {
   print "
         <tr><td>$fullname</td>
         <td>$username_more </td>
<td><a href=\"mailto:$email\">$email</a></td>
<td><a href=\"$webpage\">$webpage</a></td></tr>";
   }
   else
   {
      print "<tr><td></td><td>$username_more</td></tr>\n";
   }
}
print "</table>\n";

print "</body></html>";
