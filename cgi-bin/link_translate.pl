#!/usr/bin/perl

# The WebKNotes system is Copyright 1996-2002 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

package link_translate;

# translate a href's to work as if just the html file was loaded
sub smart_ref
{
   my( $path, $ref_enc ) = @_;

   if($ref_enc =~ m:^#: )
   {
      return $ref_enc;
   }
   
   return $ref_enc if ( $ref_enc =~ m/^\w+:/ );
   return $ref_enc if ( $ref_enc =~ m:^/: );
   my $ref = view::url_unencode_path($ref_enc);

   if( $ref =~ m:\.cgi(\?|$): ) # cgi script
   {
       my $cgifile = $'.".cgi";
       $path =~ s:^/::;
       $path =~ s:(/|^)[^/]*$::; # strip off file
       if( filedb::is_file($path,$cgifile))
       {
           return filedb::join_paths($filedb::define::doc_wpath, view::url_encode_path($path), $ref_enc);
       }
       else # if not found, assume it is relative to wkn cgi
       {
          return($ref_enc);
       }
   }
   elsif(filedb::is_file($path)) # strip off filename
   {
      $path =~ m:(/|^)[^/]+$:;
      $ref = filedb::join_paths($filedb::define::doc_wpath,$`,$ref);
   }
   else
   {
      $ref = filedb::join_paths($filedb::define::doc_wpath,$path, $ref);
   }
   
   #collapse dir/.. to nothing
   while($ref =~ s~(^|/+)(?!\.\./)[^/]+/+\.\.($|/)~$1~g){}

   if($view::define::no_browse_links or $ref =~ m:\.([^\.]*)$: and ! ($1 =~ m:^(txt|html|htm|htxt|wiki)$:))  
   {
      return view::url_encode_path($ref);
   }
   
   $ref =~ s:/+$::;
   if($ref =~ m-^$filedb::define::doc_wpath/*- )
   {
      return &view::get_cgi_prefix() . view::url_encode_path($');
   }
   elsif(defined(%view::define::wpath_prefix_translation))
   {
      for my $key ( keys %view::define::wpath_prefix_translation )
      {
         if($ref =~ m/^$key/ )
         {
            return $view::define::wpath_prefix_translation{$key} .
            view::url_encode_path($');
         }
      }
   }
   
   return  view::url_encode_path($ref);
}

sub translate_html
{
   my($text, $notes_file) = @_;
   # translate a hrefs 
   $text =~ s/<a href\s*=\s*\"?([^\">]+)\"?([^>]*)>/sprintf("<a href=\"%s\"$2>",&smart_ref($notes_file,$1))/gie;
   
   # translate relative image paths to full http paths
   my $this_path = ($notes_file =~ m:/[^/]*$:) ? "$`/" : "";
   my $this_hpath = view::url_encode_path("$filedb::define::doc_wpath/$this_path");
   $text =~ s!(<img\s[^>]*src=\")([^:\/>\"]+)!$1$this_hpath$2!gi;
   
   return $text;
}
1;
