#!/usr/bin/perl
use strict;

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require "link_translate.pl";

package filter_txt;

sub filter_file 
{
   my($notes_file) = @_;
   my($text) = filedb::get_file($notes_file);

   return () if(! defined($text));

   $text =~ s/<<([^>]+)>>/[[$1]]/g;
   $text =~ s:<:&lt;:g;
   $text =~ s:>:&gt;:g;
   $text =~ s/\[\[([^>]+)\]\]/sprintf("<a href=\"%s\">${1}<\/a>",&link_translate::smart_ref($notes_file,$1))/gie;
#   $text = &link_translate::translate_html($text, $notes_file);
   $text =~ s/((http|ftp|mailto):.*)($)/<a href=\"$1\">$1<\/a>$2/g;

   while($text =~ s:(^ *) :$1&nbsp\;:gm) {}
   $text =~ s:$:<br>:gm;
   return $text;
}

sub print_file
{
   print filter_file(@_);
}

1;
