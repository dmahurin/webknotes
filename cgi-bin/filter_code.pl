use strict;
package filter;

sub print_file
{
   my($notes_file) = @_;
   my($text) = filedb::get_file($notes_file);
   $notes_file =~ m:\.([^\.]+)$:;

   if(defined(&wkn::define::code_filter))
   {
      $text = "<pre>" . &wkn::define::code_filter($1, $text) . '</pre>';
   }
   else
   {
      $text= "<pre>${text}</pre>\n";

   }
   print $text;
}
1;
