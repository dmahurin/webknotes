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

$wkn::define::mode = "file";

my $notes_path_encoded = $ENV{QUERY_STRING};

my($user) = auth::get_user();
my($user_info) = auth::get_user_info($user);
my($notes_path) = &wkn::path_check(&wkn::url_unencode_path($notes_path_encoded), $user, $user_info);
exit(0) unless(defined($notes_path));

$notes_path =~ m:([^/]*)$:;
my($notes_name) = $1;

if( ! -e "$auth::define::doc_dir/$notes_path" )
{
   print "Note not found: $auth::define::doc_dir/$notes_path<br>\n";
   print "If you want, you can <a href=\"add_topic.cgi?notes_path=$notes_path_encoded\"> Add </a> the note yourself<br>\n";
   exit(0);
}

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
wkn::actions2($notes_path, $user, $user_info);
#wkn::log($notes_path);
print "</BODY>\n";
print "</HTML>\n";
