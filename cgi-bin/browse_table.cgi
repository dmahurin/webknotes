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
require 'css_tables.pl';

$wkn::define::mode = "table";

my $notes_path_encoded = &wkn::parse_view_mode($ENV{QUERY_STRING});
   
my($notes_path) = &wkn::path_check(&wkn::url_unencode_path($notes_path_encoded));
exit(0) unless(defined($notes_path));

$notes_path =~ m:([^/]*)$:;
my($notes_name) = $1;


my $style = wkn::get_style_header_string();

print <<"END";
<HTML>
<head>
$style
</head>
<BODY class="topics-back">
END

print css_tables::table_begin("topic-table") . "\n";

print css_tables::trtd_begin("topic-title") . "\n";
wkn::print_icon_img($notes_path);
print "<b>$notes_name</b>\n";
print css_tables::trtd_end() . "\n";

print css_tables::trtd_begin("topic-info") . "\n";
wkn::print_modification($notes_path);
print css_tables::trtd_end() . "\n";

print css_tables::trtd_begin("topic-text") . "\n";
print "&nbsp;" unless (&wkn::print_dir_file($notes_path));
print css_tables::trtd_end() . "\n";

print css_tables::trtd_begin("topic-actions") . "\n";
wkn::actions2($notes_path);
print css_tables::trtd_end() . "\n";

print css_tables::trtd_begin("topic-listing") . "\n";
print "&nbsp;" unless (&wkn::list_dirs_html($notes_path));
print css_tables::trtd_end() . "\n";

print css_tables::table_end() . "\n";

print css_tables::table_begin("topic-table") . "\n";
print css_tables::trtd_begin("topic-actions") . "\n";
wkn::actions3($notes_path);
print css_tables::trtd_end() . "\n";
print css_tables::table_end() . "\n";

wkn::log($notes_path);
print "</BODY>\n";
print "</HTML>\n";
