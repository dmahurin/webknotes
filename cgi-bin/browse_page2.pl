#!/usr/bin/perl
use strict;
# WebKNotes index generator

# The WebKNotes system is Copyright 1996-2002 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

require 'view_lib.pl';
require 'css_tables.pl';

package browse_page2;

sub show_page
{
   my(@paths) = @_;
   my $head_tags = view::get_style_head_tags();

   print <<"END";
<HTML>
<head>
<title>$view::define::index_title</title>
$head_tags
</head>
<BODY class="topics-back">
END
   view::read_page_template();
   print $view::define::page_header if(defined($view::define::page_header));
   show(@paths);
   print $view::define::page_footer if(defined($view::define::page_footer));
   print "</BODY>\n";
   print "</HTML>\n";

}

sub show
{
   my($css_tables) = css_tables->new();
   my(@notes_paths) = @_;
   for (@notes_paths)
   {
      unless( auth::check_current_user_file_auth( 'r', $_ ) )
      {
         print "You are not authorized to access this path.\n";
         return(0);
      }
   }
   &view::set_view_mode("superlayout", "");

   @notes_paths=("/") unless(@notes_paths);

   print $css_tables->table_begin("topic-table") . "\n";
   print $css_tables->trtd_begin("topic-text") . "\n";

   my $lastpath = "";
   foreach my $topic (@notes_paths)
   {
      my @changes = pathchange($lastpath, $topic);
      my $pathname = pop(@changes);
      if(@changes)
      {
         my($changepath) = join('/', @changes);
         print " <a href=\"" ,
            &view::get_cgi_prefix() ,
         $changepath . "\"><font color=\"#000000\">\n";

         print "<p><b>$changepath</b><p>\n";
         print "</font></a>\n";
      }
      $pathname =~ s:\.(txt|wiki|htxt|html?)$::g;
      print " <a href=\"" ,
         &view::get_cgi_prefix() ,
      $topic . "\"><font color=\"#000000\">\n";

      print "<p><b>$pathname</b><p>\n";
      print "</font></a>\n";


      &view::print_dir_file($topic);
      #print $css_tables->table_begin("topic-actions-table") . "\n";
      #print $css_tables->trtd_begin("topic-actions") . "\n";
      #view::actions2($topic);
      #print $css_tables->trtd_end() . "\n";
      #print $css_tables->table_end() . "\n";


      $lastpath = $topic;

   }

   print $css_tables->table_end() . "\n";

   print $css_tables->trtd_begin("topic-actions") . "\n";
   view::actions3('');
   print $css_tables->trtd_end() . "\n";
   print $css_tables->table_end() . "\n";

   return 1;
}

sub pathdiff
{
   my($path1, $path2) = @_;

   my @path1 = split(/\//, $path1);   
   my @path2 = split(/\//, $path2);
   while(@path1 and @path2 and $path1[0] eq $path2[0])
   {
       shift(@path1);
       shift(@path2);
   }
   my @backpath;
   while(@path1)
   {
       shift(@path1);
       push(@backpath, '..');
   }
   return join('/', @backpath, @path2);
}

sub pathchange
{
   my($path1, $path2) = @_;

   my @path1 = split(/\//, $path1);   
   my @path2 = split(/\//, $path2);
   my @path2_save = @path2;
   while(@path1 and @path2 and $path1[0] eq $path2[0])
   {
       shift(@path1);
       shift(@path2);
   }
   
   return (@path2 > 1? @path2_save: @path2); 
}
