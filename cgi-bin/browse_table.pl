#!/usr/bin/perl
use strict;
package browse;
# single table version of main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require "css_tables.pl";


sub show_page
{
   my($path) = @_;

my $head_tags = wkn::get_style_head_tags();

print <<"END";
<HTML>
<head>
$head_tags
</head>
<BODY class="topics-back">
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
&wkn::list_files_html($notes_path);
print "&nbsp;" unless &wkn::list_dirs_html($notes_path);
print css_tables::trtd_end() . "\n";

print css_tables::table_end() . "\n";

print css_tables::table_begin("topic-table") . "\n";
print css_tables::trtd_begin("topic-actions") . "\n";
wkn::actions3($notes_path);
print css_tables::trtd_end() . "\n";
print css_tables::table_end() . "\n";

#wkn::log($notes_path);
return 1;
}

1;
