#!/usr/bin/perl
use strict;

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require "link_translate.pl";

package filter_html;

sub enclose_topic_info
{
   my($text) = @_;
   if(wkn::get_view_mode("save") eq "plain")
   {
      return "<hr><div class=\"topic-info\">$text</div><hr>";
   }
   else
   {
require "css_tables.pl";
my $css_tables = new css_tables;
        return "<br><br>" . $css_tables->box_begin("topic-info") . "\n" .
      $text .
$css_tables->box_end()  ;
   }
}

sub print_file
{
   my($notes_file) = @_;
   my($text) = filedb::get_file($notes_file);
   return () if(! defined($text));
   
   my($line);
   
   $text =~ s:^(.*<HTML>)?(.*<HEAD>)?(.*</HEAD>)?(.*<BODY[^>]*>)?::si;
   $text =~ s:(</BODY>.*)?(</HTML>.*)?$::si;

# detail append comments
   $text =~ s#<hr\s+title="Modified\s([\d\s\:-]+)(\sby\s+([^\"]+))?"\s*>#&enclose_topic_info(wkn::create_modification_string($1,$3))#ge;

   
   if(defined(&wkn::define::code_filter))
   {
      $text =~ s=<code\s*([^\s>]*)>(((?!</code>).)*)=&wkn::define::code_filter($1,$2);=gsie;
   }
   
   print &link_translate::translate_html($text, $notes_file);
}
1;
