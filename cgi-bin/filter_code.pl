use strict;
package filter_code;

sub print_file
{
   my($notes_file) = @_;
   my($text) = filedb::get_file($notes_file);
   $notes_file =~ m:\.([^\.]+)$:;

   if(defined(&view::define::code_filter))
   {
      $text = "<pre>" . &view::define::code_filter($1, $text) . '</pre>';
   }
   else
   {
      $text= "<pre>${text}</pre>\n";

   }
   print $text;
}
1;
