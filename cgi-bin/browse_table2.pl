#!/usr/bin/perl
use strict;
package browse_table2;
# single table version of main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2002 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require "css_tables.pl";
require 'view_lib.pl';

sub show_page
{
   my($path) = @_;

   my $head_tags = view::get_style_head_tags();

   print <<"END";
<HTML>
<head>
$head_tags
</head>
<BODY class="topics-back">
END
   view::read_page_template();
   print $view::define::page_header if(defined($view::define::page_header));
   show($path);
   print $view::define::page_footer if(defined($view::define::page_footer));
   print "</BODY>\n";
   print "</HTML>\n";
}

sub show
{
   my($notes_path) = @_;
   my($css_tables) = css_tables->new();
   unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
   {
      print "You are not authorized to access this path.\n";
      return(0);
   }

   $notes_path =~ m:([^/]*)$:;
   my($notes_name) = $1;

   print $css_tables->table_begin("topic-table") . "\n";

   print $css_tables->trtd_begin("topic-title", 'colspan="2"') . "\n";
   view::print_icon_img($notes_path);
   print "<b>$notes_name</b>\n";
   print $css_tables->trtd_end() . "\n";

   print $css_tables->trtd_begin("topic-info", 'colspan="2"') . "\n";
   view::print_modification($notes_path);
   print $css_tables->trtd_end() . "\n";

   print $css_tables->trtd_begin("topic-actions", 'colspan="2"') . "\n";
   view::actions2($notes_path);
   print $css_tables->trtd_end() . "\n";

   print $css_tables->trtd_begin("topic-text") . "\n";
   print "&nbsp;" unless
      &view::print_dir_file($notes_path);

   print $css_tables->td_next("topic-listing") . "\n";
   print "&nbsp;" unless
   (
      &view::list_files_html($notes_path)
      ||
      &view::list_dirs_html($notes_path)
   );
   print $css_tables->trtd_end() . "\n";

   print $css_tables->table_end() . "\n";

   unless(view::get_view_mode("superlayout") eq "framed")
   {
      print $css_tables->table_begin("topic-table") . "\n";
      print $css_tables->trtd_begin("topic-actions") . "\n";
      view::actions3($notes_path);
      print $css_tables->trtd_end() . "\n";
      print $css_tables->table_end() . "\n";
   }

   #view::log($notes_path);
   return 1;
}

1;
