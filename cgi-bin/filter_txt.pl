#!/usr/bin/perl
use strict;

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require "link_translate.pl";

package filter_txt;

sub print_file 
{
   my($notes_file) = @_;
   my($text) = filedb::get_file($notes_file);
   return () if(! defined($text));

   open(MYFILE, "$filedb::define::doc_dir/$notes_file") || return 0;
   my($line);
   while(defined($line = <MYFILE>))
   {
      if( $line =~ /^http:/ ||
         $line =~ /^ftp:/ ||
         $line =~ s/^mailto:// )
      {
         $line = "<A HREF=\"$line\">$line</A>\n";
      }
      while($line =~ s/<<([^>]+)>>/sprintf("<a href=\"%s\">${1}<\/a>",&link_translate::smart_ref($notes_file,$1))/gie) { }


      $line = &link_translate::translate_html($line, $notes_file);

      if($line =~ m:^( +):)
      {
         my $a = $1;
         my $b = $';
         $a =~ s:\s:&nbsp;:g;
         $line = $a . $b;
      }
      print("$line<br>");
   }
   close(MYFILE);
   return 1;
}

1;
