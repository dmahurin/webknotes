#!/usr/bin/perl
use strict;
# single table version of main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

print "Content-type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'wkn_define.pl';
require 'wkn_lib.pl';

$wkn::define::mode = "table";

my $notes_path_encoded = $ENV{QUERY_STRING};
my($notes_path) = &wkn::path_check(&wkn::url_unencode_path($notes_path_encoded));
exit(0) unless(defined($notes_path));

$notes_path =~ m:([^/]*)$:;
my($notes_name) = $1;


print <<"END";
<HTML>
<head>
</head>
<BODY $wkn::attr::body>
END

print "<table border=0 cellpadding=8>\n";
print "<tr><td $wkn::attr::td_description>\n";
if(&wkn::print_dir_file($notes_path))
{
   print "</td></tr>\n";
   print "<tr><td $wkn::attr::td_list>\n";
}
wkn::print_icon_img($notes_path);
print "<b>$notes_name</b> - ";
wkn::print_modification($notes_path);
#print "<table><tr><td rowspan=2>";
#wkn::print_icon_img($notes_path);
#print "</td><td><b>$notes_name</b><br><td></tr><tr><td>\n";
#wkn::print_modification($notes_path);
#print "</td></tr></table>\n";
print "</td></tr>\n";
print "<tr><td $wkn::attr::td_list>\n";
if(&wkn::list_files_html($notes_path))
{
   print "</td></tr>\n";
   print "<tr><td $wkn::attr::td_list>\n";
}
wkn::actions2($notes_path);
print "</td></tr>\n";
print "<tr><td $wkn::attr::td_list>\n";
&wkn::list_dirs_html($notes_path);
print "</td></tr>\n";
print "</table><br>\n";
print "<table border=0 cellpadding=8>\n";
print "<tr><td $wkn::attr::td_list>\n";
wkn::actions3($notes_path);
print "</td></tr>\n";
print "</table><br>\n";
wkn::log($notes_path);
print "</BODY>\n";
print "</HTML>\n";
