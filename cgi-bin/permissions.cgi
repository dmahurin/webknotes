#!/usr/bin/perl
use strict;
# CGI script to edit a file using auth-lib user verification

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'auth_define.pl';
require 'auth_lib.pl';
require 'filedb_lib.pl';
use CGI qw(:cgi-lib); 

my($my_main) = auth::localize_sub(\&main);
&$my_main;

sub main
{

#$this_cgi = $ENV{'SCRIPT_NAME'};
my $this_cgi = "permissions.cgi";
print "Content-type: text/html\n\n";

# uses doc_dir filedb_define.pl

my $illegal_dir = "cgi-bin";

my %in;
&ReadParse(\%in);

my $dir = $in{'path'};
my $permissions = $in{'permissions'};
my $group = $in{'group'};
my $owner = $in{'owner'};

if( !defined( $dir ) )
{
   print ("No dir defined\n");
   exit(0);
}

if($dir =~ m:(^|/+)\.+:)
{
   print "Illegal chars\n";
   exit(0);
}
#untaint dir
if( $dir =~ m:^(.*)$:)
{
   $dir = $1;
}
$dir =~ s:^/+::;

my $user = auth::get_user();
my $user_info = auth::get_user_info($user);

if( ! defined($permissions) )
{
   if( ! auth::check_file_auth( $user, $user_info, 'r', $dir ) )
   {
      print "You are not authorized to change permissions  on: $dir\n";
      exit 0;
   }
   $permissions = filedb::get_hidden_data($dir, "permissions");
   $group = filedb::get_hidden_data($dir, "group");
   $owner = filedb::get_hidden_data($dir, "owner");

   print <<"EOT";
<pre>
The permission flags are as follows:
r - read
n - add note
o - owner permissions
c - create
m - modify
d - delete
p - change dir permissions
s - system privalege

"-" takes away permissions. ex: -cmd
"+" adds permission. ex: +m
"=" sets permission. ex: =rno
</pre>

<form action="$this_cgi" method="post">
<input type=hidden name=path value="$dir">
Permissions <input type=text name=permissions value="$permissions">   
<br>Owner <input type=text name=owner value="$owner">   
<br>Group <input type=text name=group value="$group">   
<br><INPUT TYPE=submit VALUE="Change">
</form>
EOT
}
else
{
   if( ! auth::check_file_auth( $user, $user_info, 'p', $dir ) )
   {
      print "You are not authorized to change permissions  on: $dir\n";
      exit 0;
   }
   
   
   if( $permissions eq "")
   {
      undef($permissions);
      print "Using default permissions for: $dir<br>\n";
   }
   if(filedb::set_hidden_data($dir, "permissions", $permissions))
   {
      print "Wrote permissions for: $dir<br>\n";
   }
   else
   {
      print "failed to write permissions: $dir<br>\n";
   }
   
   if( $group eq "")
   {
      undef($group);
      print "No group defined for: $dir<br>\n";
   }
   if(filedb::set_hidden_data($dir, "group", $group))
   {
      print "Wrote group for: $dir<br>\n";
   }
   else
   {
      print "failed to write group: $dir<br>\n";
   }
   
   if( $owner eq "")
   {
      unef($owner);
      print "No owner defined for: $dir<br>\n";

   }
   if(filedb::set_hidden_data($dir, "owner", $owner))
   {
      print "Wrote owner for: $dir<br>\n";
   }
   else
   {
      print "failed to write owner: $dir<br>\n";
   }
}
}
