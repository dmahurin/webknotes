#!/usr/bin/perl
use strict;

# The WebKNotes system is Copyright 1996-2002 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require "link_translate.pl";

package filter_txt;

sub filter_file 
{
   my($notes_file) = @_;
   my($text) = filedb::get_file($notes_file);

   return () if(! defined($text));

   $text =~ s:<:&lt;:g;
   $text =~ s:>:&gt;:g;
   #$text =~ s/((http|ftp|mailto):.*)($)/<a href=\"$1\">$1<\/a>$2/g;

   if($text =~ m:\t:) { return "<pre>$text</pre>\n" };

   while($text =~ s:(^ *) :$1&nbsp\;:gm) {}
   $text =~ s:$:<br>:gm;
   return $text;
}

sub print_file
{
   print filter_file(@_);
}

1;
