use strict;
package filter_code;

sub filter_file
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
      $text =~ s:<:&lt;:g;
      $text =~ s:>:&gt;:g;
      $text= "<pre>${text}</pre>\n";
   }
}

sub print_file
{
   print filter_file(@_);
}
1;
