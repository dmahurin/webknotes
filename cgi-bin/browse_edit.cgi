#!/usr/bin/perl
#this is a plain browsing method that has access to all files including README's
use strict;


print "Content-type: text/html

<HTML>
<BODY>
";

$|=1;

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'auth_define.pl';
require 'auth_lib.pl';


my($this_cgi) = "browse_edit.cgi";
my $notes_path_encoded = $ENV{QUERY_STRING} || $ARGV[0];
$notes_path_encoded =~ s:/+$::g;
my($notes_path) = &auth::path_check(&auth::url_unencode_path($notes_path_encoded));
exit(0) unless(defined($notes_path));


$notes_path =~ m:([^/]+)$:;
my($notes_name) = $1;


unless (auth::check_current_user_file_auth( 'r',  $notes_path) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}
 

my($real_path) = "$auth::define::doc_dir/${notes_path}";

print <<"_EOT";
<title>${notes_path}</title>
_EOT


print $notes_path . '<br>';

   print "<hr>\n";
   
if(-f $real_path)
{
   print "[ <a href=\"$auth::define::doc_wpath/$notes_path_encoded\">View</a> ] \n";
	       
   if(auth::check_current_user_file_auth( 'm',  $notes_path) )
   {
      print "[ <a href=\"edit.cgi?$notes_path_encoded\">Edit</a> ] \n";
   }
}

if(auth::check_current_user_file_auth( 'd',  $notes_path) and 
   $notes_path ne "")
{
   print "[ <a href=\"delete.cgi?$notes_path_encoded\">Delete</a> ] \n";
}

if(-d $real_path and opendir(DIR, $real_path))
{
   print "[ <a href=\"$auth::define::doc_wpath/$notes_path\">Browse</a> ] \n";
   if(auth::check_current_user_file_auth( 'p',  $notes_path) )
   {
      print "[ <a href=\"permissions.cgi?path=$notes_path_encoded\">Permissions</a> ] \n";
   }
   if(auth::check_current_user_file_auth(  'u',  $notes_path) )
   {
      print "[ <a href=\"upload.cgi?path=$notes_path_encoded\">Upload</a> ] \n";
   }
}

my($user) = auth::get_user();

if(defined($user))
{
   print " - You are <a href=\"user_access.cgi\">logged</a> in as: $user<br>\n";
}
else
{
   print " - You are not <a href=\"user_access.cgi\">logged</a> in<br>\n";
}

if(-d $real_path and opendir(DIR, $real_path))
{
   print "<hr>\n";
   
   my $file;
   while($file = readdir(DIR))
   {
      next if($file =~ m:^\.:);
      my $file_encoded = auth::url_encode_path($file);
      print "<a href=\"${this_cgi}?$notes_path_encoded/$file_encoded\">$file</a><br>\n";
      
   }
   closedir(DIR);
}


print "</BODY>\n";
print "</HTML>\n";
