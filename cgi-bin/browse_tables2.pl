#!/usr/bin/perl
use strict;
# main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2002 Don Mahurin
# For information regarding the Copying policy read 'COPYING'
# dmahurin@users.sourceforge.net

require 'css_tables.pl';
require 'view_lib.pl';

package browse_tables2;

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
   print_main_topic_table($notes_path, $css_tables);

   my $dfile = filedb::default_file($notes_path);
   for my $file (filedb::get_directory_list($notes_path))
   {
      next if($file eq $dfile);
      if( $file =~ m:^([^/]*)$: ) # untaint dir entry
      {
         $file = $1;
      }
      else
      {
         print "hey, /'s ? not ggod.\n";
         exit;
      }
      $file = "$notes_path/$file" if($notes_path);
      print "<p>\n";
      print_topic_table( $file, $css_tables);
   }
   closedir(DIR);

   unless(view::get_view_mode("superlayout") eq "framed")
   {
      print $css_tables->table_begin("topic-table") . "\n";
      print "<tr>" . $css_tables->trtd_begin("topic-actions") . "\n";
      view::actions3($notes_path);
      print $css_tables->trtd_end() . "</tr>\n";
      print $css_tables->table_end() . "\n";
   }
   return 1;
}


sub print_main_topic_table
{
	my($notes_path, $css_tables) = @_;
	$notes_path =~ m:([^/]*)$:;
	my $notes_name = $1;

        print $css_tables->table_begin("topic-table") . "\n";
        
        print $css_tables->trtd_begin("topic-title") . "\n";
	print "<b>$notes_name</b>\n";
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-info") . "\n";
	&view::print_modification($notes_path);
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-text") . "\n";
	print "&nbsp;" unless(&view::print_dir_file($notes_path));
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-actions") . "\n";
	view::actions2($notes_path);
        print $css_tables->trtd_end() . "\n";
        print $css_tables->table_end() . "\n";
}

sub print_topic_table
{
	my($notes_path, $css_tables) = @_;
	$notes_path =~ m:([^/]*)$:;
	my $notes_name = $1;

        print $css_tables->table_begin("topic-table") . "\n";
        print $css_tables->trtd_begin("sub-topic-title") . "\n";
#	print "<b>$notes_name</b><br>\n";
        print_icon_link($notes_path);
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-info") . "\n";
	&view::print_modification($notes_path);
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-text") . "\n";
	&view::print_dir_file($notes_path);
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-actions") . "\n";
	view::actions2($notes_path);
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-listing") . "\n";
        print "&nbsp;" unless(&view::list_html($notes_path));
        print $css_tables->trtd_end() . "\n";
        print $css_tables->table_end() . "\n";
}

sub print_icon_link
{
        my($path) = @_;
        $path =~ m:([^/]*)$:;
        my $name = $1;
        my($wpath) = &view::url_encode_path($path);
        
	my($bprefix, $bsuffix) = &view::get_cgi_prefix();
        print "<A HREF=\"" . $bprefix . $wpath . $bsuffix . "\">";
        view::print_icon_img($path);
	print "</a>";
        print "<A HREF=\"" . $bprefix . $wpath . $bsuffix . "\">";
        print "<b>$name</b></a>";
}
1;
