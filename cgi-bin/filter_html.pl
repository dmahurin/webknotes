#!/usr/bin/perl
use strict;

# The WebKNotes system is Copyright 1996-2002 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require "link_translate.pl";

package filter_html;



sub filter_file
{
   my($notes_file) = @_;
   my($text) = filedb::get_file($notes_file);

   return () if(! defined($text));
   
   my($line);
   
   $text =~ s:^(.*<HTML>)?(.*<HEAD>)?(.*</HEAD>)?(.*<BODY[^>]*>)?::si;
   $text =~ s:(</BODY>.*)?(</HTML>.*)?$::si;

# detail append comments - now in view_lib.pl
#   $text =~ s#<hr\s+title="Modified\s([\d\s\:-]+)(\sby\s+([^\"]+))?"\s*>#&enclose_topic_info(view::create_modification_string($1,$3))#ge;

   if(defined(&view::define::code_filter))
   {
      $text =~ s=<code\s*([^\s>]*)>(((?!</code>).)*)=&view::define::code_filter($1,$2);=gsie;
   }
   
   return &link_translate::translate_html($text, $notes_file);
}

sub print_file
{
   print filter_file(@_);
}
1;
