#!/usr/bin/perl
use strict;
# WebKNotes index generator

# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

require 'wkn_lib.pl';
require 'css_tables.pl';

package browse;

sub show_page
{
my(@paths) = @_;
my $head_tags = wkn::get_style_head_tags();

print <<"END";
<HTML>
<head>
<title>$wkn::define::index_title</title>
$head_tags
</head>
<BODY class="topics-back">
END
show(@paths);
print "</BODY>\n";
print "</HTML>\n";

}


sub show
{
 my(@notes_paths) = @_;
   for (@notes_paths)
   {
      unless( $_ =~ m:=: or auth::check_current_user_file_auth( 'r', $_ ) )
      {
         print "You are not authorized to access this path.\n";
         return(0);
      }
   }
   &wkn::set_view_mode("layout", &wkn::get_view_mode("sublayout"));


   @notes_paths=("/") unless(@notes_paths);

if (defined($wkn::define::index_header))
{
   print "<table border=0 cellpadding=8><tr><td class=\"topics_header\">\n",
   $wkn::define::index_header ,
   "</td></tr></table>\n";
   
}

print "<p><table cellspacing=0 border=0 cellpadding=8 >";
my ($topic_row, $topic, $colspan);
my $max_count = 0;
my $count = 0;
my $span = "";
print "<tr>\n";
my $arg;
my $columns;
foreach $arg (@notes_paths)
{
   if($arg =~ m:^columns=:)
   {
      $columns=$';
      next;
   }
   if($arg =~ m:^(rowspan|colspan):)
   {
      $span = $span . " " . $arg;
      next;
   }
   if($arg eq "" and $count != 0)
   {
      print "</tr><tr>";
      $count = 0;
      next;
   }
   if(defined($columns) and $count >= $columns)
   {
      print "</tr><tr>";
      $count = 0;
   }
   $topic = $arg;
   print "<td${span}>\n";
   print css_tables::table_begin("topic-table") . "\n";
   
   print css_tables::trtd_begin("topic-text") . "\n";
   
   print "<table><tr>";
   my $icon = wkn::get_icon($topic);
      if( defined($icon) )
      {
         print "<td>";
          my $etopic = wkn::url_encode_path($topic);
          print "<a href=\"" ,
             &wkn::get_cgi_prefix() , 
             $etopic . "\">\n";
          print "<img src=\"$icon\" alt=\"$icon\"></a>\n";
          print "</td>";
      }
      print "<td>";
      &wkn::print_dir_file($topic);
      print "</td></tr></table>";
      print css_tables::trtd_end() . "\n";
      
      print css_tables::trtd_begin("topic-listing") . "\n";
      &wkn::list_html($topic);
      print css_tables::trtd_end() . "\n";
      
      print css_tables::table_end() . "\n";
      print "</td>\n";
      $count++;
   
   $span = "";
}
print "</tr>\n";

print "</table>\n";

if (defined ($wkn::define::index_footer))
{
print "<table border=0 cellpadding=8><tr><td class=\"topics-footer\">\n",
   "$wkn::define::index_footer\n",
   "</td></tr></table>\n";
}

#print "<a href=\"mailto:dmahurin\@users.sourceforge.net\" >dmahurin\@users.sourceforge.net</a>\n";

return 1;
}