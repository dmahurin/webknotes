#!/usr/bin/perl
use strict;
# CGI script to edit a file using auth-lib user verification

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-2002 Don Mahurin.
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

my $this_cgi = "delete.cgi";
print "Content-type: text/html\n\n\n";

my $illegal_dir = "cgi-bin";

my %in;
&ReadParse(\%in);

my $filepath = $in{'file'};
if(!defined( $filepath )) { $filepath=$ENV{'QUERY_STRING'}};
if(!defined( $filepath ) or $filepath eq "" ) { $filepath=$ARGV[0]};
if( !defined( $filepath ) or $filepath eq "" )
{
   print ("No file defined\n");
   exit(0);
}

if($filepath =~ m:(^|/+)\.+:)
{
   print "Illegal chars\n";
   exit(0);
}
#untaint file
if( $filepath =~ m:^(.*)$:)
{
   $filepath = $1;
}
$filepath =~ s:^/+::;

my $filepath_encoded = $filepath;
$filepath = auth::url_unencode_path($filepath);

if( $filepath =~ m:$illegal_dir: )
{
   print "Illegal dir\n";
   exit(0);
}

my $user = auth::get_user();
if( ! defined ($user) )
{
   print "You are not logged in\n";
   exit(0);
}

if(! auth::check_current_user_file_auth( 'd', $filepath ) )
{
   print "You are not authorized to delete this file: $filepath\n";
   exit 0;
}

if( ! defined($in{confirm}))
{
   my $ftype;
   if( filedb::is_link($filepath))
   {
     $ftype = "Link";
   }
   elsif ( filedb::is_dir($filepath) )
   {
     $ftype = "Dir";
   }
   else
   {
     $ftype = "File";
   }
      
   print <<"EOT";
<h1>Confirm delete</h1>
<form action="delete.cgi" method="post">
<input type=hidden name=file value="$filepath_encoded">
<input type=hidden name=confirm value="yes">
Delete $ftype: "$filepath"<br>
<INPUT TYPE=submit VALUE="Delete $ftype">
</form>
EOT
}
else
{
   if( filedb::is_link($filepath) or filedb::is_file($filepath))
   {
      print "<h1>Delete File</h1>\n";
            if(filedb::remove_file($filepath))
      {
          print "Sucessfull deleting: $filepath\n";
      }
      else
      {
         print "Failed deleting: $filepath\n";
      }
   }
   elsif( filedb::is_dir($filepath) )
      {
      my @dirlist = filedb::get_directory_list($filepath);
      my $file = filedb::default_file($filepath);
      if(@dirlist < 1 || @dirlist == 1 && $dirlist[0] eq $file)
         {
         if(@dirlist == 1)
         {
            filedb::remove_file($filepath, $file);
         }
         if(filedb::unset_all_hidden_data($filepath) &&
         filedb::remove_dir($filepath))
         {
            print "Sucessfull deleting: $filepath\n";
         }
         else
         {
            print "Failed deleting: $filepath\n";
         }
      }
         else
         {
         print "Directory is not empty\n";
      }
   }
   else
   {
      print "File not found\n";
   }
}
}
