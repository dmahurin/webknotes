#!/usr/bin/perl
use strict;
# single file version of main WebKNotes script table version
# no subnotes are listed, only the file and bottom toolbar

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

print "Content-type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'wkn_define.pl';
require 'wkn_lib.pl';

$wkn::view_mode{"layout"} = "file";


my($notes_path) = wkn::get_args();

$notes_path = auth::path_check($notes_path);
exit(0) unless(defined($notes_path));

unless( auth::check_current_user_file_auth( $notes_path,'r' ) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}
#unless(auth::check_path_exists($notes_path )
#{
#   print "Note not found: $auth::define::doc_dir/$notes_path<br>\n";
#   print "If you want, you can <a href=\"add_topic.cgi?notes_path=$notes_path_encoded\"> Add </a> the note yourself<br>\n";
#   exit(0);
#}

$notes_path =~ m:([^/]*)$:;
my($notes_name) = $1;

print <<"END";
<HTML>
<head>
</head>
<BODY>
END

&wkn::print_dir_file($notes_path);
print "<hr>\n";
#wkn::print_icon_img($notes_path);
print "<b>$notes_name</b> - ";
wkn::print_modification($notes_path);
print "<hr>\n";
wkn::actions2($notes_path);
#wkn::log($notes_path);
print "</BODY>\n";
print "</HTML>\n";
