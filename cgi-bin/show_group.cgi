#!/usr/bin/perl
use strict;
# show information on a user, using the auth-lib

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'auth_define.pl';
require 'auth_lib.pl';
use CGI qw(:cgi-lib); 

my($my_main) = auth::localize_sub(\&main);
&$my_main;

sub main
{

my $this_cgi = $ENV{'SCRIPT_NAME'};
print "Content-type: text/html\n\n\n";

my %in;

&ReadParse(\%in);
my $groupname = $in{'group'};
if( $groupname =~ m:[^\w-]: )
{
  print "Illegal char\n";
  exit;
}

if( ! defined($groupname) )
{
  print "Group not defined\n";
  exit;
}

my $group_info = &auth::get_group_info($groupname);

print "
<html>
<head>
<title>Group Info</title>
</head>
<body>
<H1>Group: $group_info->{\"Name\"}</H1> ";

my($username);
print "<table border=\"1\"><tr><th>Full Name</th><th>User Name</th><th>email</th><th>web page</th></tr>\n";

for $username (split(',', $group_info->{"Members"}))
{
   my($user_info) = &auth::get_user_info($username);
   
# below was put in to allow user info (outside of wkn) to be linked to
# anyone use it?
#   my($username_more) = (defined($auth::define::userinfocgi) ? ("<a href=\"$auth::define::userinfocgi$username\">$username</a>") : $username);
   my($username_more) = $username;
   if(defined($user_info->{"Name"}))
   {
   print "<tr><td>$user_info->{\"Name\"}</td>
         <td>$username_more </td>
<td><a href=\"mailto:$user_info->{\"Email\"}\">$user_info->{\"Email\"}</a></td>
<td><a href=\"$user_info->{\"Webpage\"}\">$user_info->{\"Webpage\"}</a></td></tr>";
   }
   else
   {
      print "<tr><td></td><td>$username_more</td></tr>\n";
   }
}
print "</table>\n";

print "</body></html>";
}
