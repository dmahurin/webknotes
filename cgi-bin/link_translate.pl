#!/usr/bin/perl

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

package link_translate;

# translate a href's to work as if just the html file was loaded
sub smart_ref
{
   my( $path_enc, $ref_enc ) = @_;
   if($ref_enc =~ m:^#: )
   {
      return $ref_enc;
   }
   
   return $ref_enc if ( $ref_enc =~ m/^\w+:/ );
   return $ref_enc if ( $ref_enc =~ m:^/: );
   my $ref = wkn::url_unencode_path($ref_enc);

   # ??
   if($ref =~ m:#: )
   {
      $ref = "$auth::define::doc_wpath/$path_enc$ref";
   }
   elsif( $ref =~ m:\.cgi(\?|$): ) # cgi script
   #elsif( $ref =~ m:^[^/]+\.cgi: ) # local cgi script
   {
       if( -f "$auth::define::doc_dir/$path_enc/$ref")
       {
          $path_enc =~ s:^/::;
          $path_enc =~ s:(/|^)[^/]*$:$1:; # strip off file
          return $auth::define::doc_wpath . '/' . $path_enc . $ref_enc;
       }
   }
   elsif($path_enc =~ m:/[^/]*$:) # strip off README.html or xxx.html
   {
      $ref = "$auth::define::doc_wpath/$`/$ref";
   }
   else
   {
      $ref = "$auth::define::doc_wpath/$ref";
   }
   
   #collapse dir/.. to nothing
   while($ref =~ s~(^|/+)(?!\.\./)[^/]+/+\.\.($|/)~$1~g){}

   if($wkn::define::no_browse_links or $ref =~ m:\.([^\.]*)$: and ! ($1 =~ m:^(txt|html|htm)$:))  
   {
      return wkn::url_encode_path($ref);
   }
   
   $ref =~ s:/+$::;
   if($ref =~ m-^$auth::define::doc_wpath/*- )
   {
      return &wkn::get_cgi_prefix() . wkn::url_encode_path($');
   }
   elsif(defined(%wkn::define::wpath_prefix_translation))
   {
      for my $key ( keys %wkn::define::wpath_prefix_translation )
      {
         if($ref =~ m/^$key/ )
         {
            return $wkn::define::wpath_prefix_translation{$key} .
            wkn::url_encode_path($');
         }
      }
   }
   
   return  wkn::url_encode_path($ref);
}

sub translate_html
{
   my($text, $notes_file) = @_;
   # translate a hrefs 
   $text =~ s/<a href\s*=\s*\"?([^\">]+)\"?([^>]*)>/sprintf("<a href=\"%s\"$2>",&smart_ref($notes_file,$1))/gie;
   
   # translate relative image paths to full http paths
   my $this_path = ($notes_file =~ m:/[^/]*$:) ? "$`/" : "";
   my $this_hpath = wkn::url_encode_path("$auth::define::doc_wpath/$this_path");
   $text =~ s!(<img\s[^>]*src=\")([^:\/>\"]+)!$1$this_hpath$2!gi;
   
   return $text;
}
1;
