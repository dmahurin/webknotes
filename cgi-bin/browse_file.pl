#!/usr/bin/perl
use strict;
package browse_file;
# single file version of main WebKNotes script table version
# no subnotes are listed, only the file and bottom toolbar

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

sub show_page
{
   my($path) = @_;
print <<"END";
<HTML>
<head>
</head>
<BODY>
END
   show($path);
print "</BODY>\n";
print "</HTML>\n";
}

sub show
{
   my($notes_path) = @_;
   unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
   {
      print "You are not authorized to access this path.\n";
      return(0);
   }

$notes_path =~ m:([^/]*)$:;
my($notes_name) = $1;

&view::print_dir_file($notes_path);
print "<hr>\n";
#view::print_icon_img($notes_path);
print "<b>$notes_name</b> - ";
view::print_modification($notes_path);
print "<hr>\n";
view::actions2($notes_path);
#view::log($notes_path);
return 1;
}

1;
