#!/usr/bin/perl
use strict;
# CGI script to edit a file using auth-lib user verification

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'auth_define.pl';
require 'auth-lib.pl';
use CGI qw(:cgi-lib); 

my $this_cgi = "delete.cgi";
print "Content-type: text/html\n\n\n";

my $illegal_dir = "cgi-bin";

my %in;
&ReadParse(\%in);

my $file = $in{'file'};
if(!defined( $file )) { $file=$ENV{'QUERY_STRING'}};
if(!defined( $file ) or $file eq "" ) { $file=$ARGV[0]};
if( !defined( $file ) or $file eq "" )
{
   print ("No file defined\n");
   exit(0);
}
# make sure no part of the path starts with '.', untaint $file in process
if( $file =~ m:^(/*[^\./][^/]*)*$: ) 
{
   $file = $&;
}
else
{
   print "hey buddy, whats up?\n";
   exit(0);
}

$file =~ s:^/+::;
my $full_file = "$auth::define::doc_dir/$file";

if( $file =~ m:$illegal_dir: )
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

if( ! auth::check_file_auth( $user, "/$file", 'd' ) )
{
   print "You are not authorized to delete this file: $file\n";
   exit 0;
}

my($full_file) = "$auth::define::doc_dir/$file";

if( ! defined($in{confirm}))
{
   my $dir;
   if( -d $full_file )
   {
      print <<"EOT";
<h1>Confirm delete</h1>
<form action="delete.cgi" method="post">
<input type=hidden name=file value="$file">
<input type=hidden name=confirm value="yes">
Delete Dir: "$file"<br>
<INPUT TYPE=submit VALUE="Delete Dir">
</form>
EOT
   }
   else
   {
      if( $file =~ m:/[^/]+/*$: ) #directory part
      {
         print <<"EOT";
<form action="delete.cgi" method="post">
<input type=hidden name=file value="$`">
<input type=hidden name=confirm value="yes">
Delete Entire Directory: "$`"<br>
<INPUT TYPE=submit VALUE="Delete Directory">
</form>
EOT
      print <<"EOT";
<h1>Confirm delete</h1>
<form action="delete.cgi" method="post">
<input type=hidden name=file value="$file">
<input type=hidden name=confirm value="yes">
Delete File: "$file"<br>
<INPUT TYPE=submit VALUE="Delete File Only">
</form>
EOT
      }
   }
}
else
{
   if( -d $full_file )
   {
      my @delete_files = ();
      my $found_files = 0;
      opendir(DIR, $full_file) or print "could not open dir\n";
      while(defined($file = readdir(DIR)))
      {
         #untaint file
         if( $file =~ m:^([^/]*)$: ) # untaint dir entry
         {
            $file = $1;
         }

         next if( $file eq "." or $file eq ".." );
         if( -d "$full_file/$file")
         {
            print "Sub directory exists: $file\n";
            $found_files=1;
            last;
         }
         elsif($file =~ m:^(README|\.):)
         {
            push(@delete_files, $file);
         }
         else
         {
            print "File exist: $file\n";
            $found_files=1;
            last;
         }
      }
      closedir(DIR);
      if((! $found_files ) and @delete_files)
      {
          foreach $file (@delete_files)
          {
              unless (unlink("$full_file/$file") )
              {
                 print "Could not delete file: $file\n";
                 $found_files=1;
                 last;
              }
          }
      }
      unless($found_files)
      {
         if(rmdir($full_file))
         {
            print "Directory deleted\n";
         }
         else
         {
            print "could not rmdir: $full_file\n" unless rmdir($full_file);
         }
      }
   }
   elsif(-f $full_file)
   {
      print "<h1>Delete File</h1>\n";
      if(unlink($full_file))
      {
          print "Sucessfull deleting: $file\n";
      }
      else
      {
         print "Failed deleting: $file\n";
      }
   }
}
