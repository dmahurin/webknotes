#!/usr/bin/perl
use strict;
# single table version of main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

package browse;

sub show_page
{
   my($notes_path) = @_;
unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   return(0);
}

my($notes_path_encoded) = wkn::url_encode_path($notes_path);

my $frame = $wkn::view_mode{frame};
undef $wkn::view_mode{frame};


if(defined($frame))
{
   if($frame eq "menu")
   {
      $wkn::view_mode{"layout"} = "frames";
      print "<html><head><BASE TARGET=\"_parent\"></head>";
      &wkn::list_files_html($notes_path);
      &wkn::list_dirs_html($notes_path);
      print "</html>\n";
   }
   elsif($frame eq "header")
   {
      print "<html><head><BASE TARGET=\"_parent\"></head>";
      print $wkn::define::index_header
        if(defined($wkn::define::index_header));
      print "</html>\n";
   }
   elsif($frame eq "footer")
   {
      print "<html><head><BASE TARGET=\"body\"></head>\n";
      if(defined($wkn::define::index_footer))
      {
         print $wkn::define::index_footer;
      }
      else
      {
         &wkn::actions3($notes_path);
      }
      print "</html>\n";
   }
   exit(0);
}

&wkn::set_view_mode("layout", "frames");
my $this_script_prefix = wkn::get_cgi_prefix();
&wkn::set_view_mode("layout", &wkn::get_view_mode("sublayout"));
&wkn::unset_view_mode("sublayout");
my $script_prefix = wkn::get_cgi_prefix();

print "<html> <head>\n";
print "<title>$wkn::define::index_title</title>\n" 
  if(defined($wkn::define::index_title));
print <<EOT
<BASE TARGET="body">
<title>$wkn::define::index_title</title>
  </head>
  <frameset rows = "60,*">
    <frame src="${this_script_prefix}frame=header&$notes_path_encoded" name="header" noresize marginwidth="0"
      marginheight="0" scrolling="no">
    <frameset cols = "25%,*">
        <frameset rows = "*, 50">
          <frame src="${this_script_prefix}frame=menu&$notes_path_encoded" name="menu" marginwidth="0" marginheight="0">
          <frame src="${this_script_prefix}frame=footer&$notes_path_encoded" name="footer" marginwidth="0"
                 marginheight="0" scrolling="no">
        </frameset>
   <frame src="${script_prefix}$notes_path_encoded" name="body" marginwidth="0" marginheight=
"0">
    </frameset>
  </frameset>
</html>
EOT

}
1;
