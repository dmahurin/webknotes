#!/usr/bin/perl

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require "link_translate.pl";

package filter;

sub print_file 
{
   my($notes_file) = @_;
   my($text) = wkn::get_file($notes_file);
   return () if(! defined($text));

   open(MYFILE, "$auth::define::doc_dir/$notes_file") || return 0;
   while(defined($line = <MYFILE>))
   {
      if( $line =~ /^http:/ ||
         $line =~ /^ftp:/ ||
         $line =~ s/^mailto:// )
      {
         $line = "<A HREF=\"$line\">$line</A>\n";
      }

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
