#!/usr/bin/perl
use strict;
# single table version of main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2002 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

package browse_frames;

sub show_page
{
   my($notes_path) = @_;
   unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
   {
      print "You are not authorized to access this path.\n";
      return(0);
   }

   my($notes_path_encoded) = view::url_encode_path($notes_path);

   my $frame = $view::view_mode{frame};
   undef $view::view_mode{frame};


   if(defined($frame))
   {
      my $head_tags = view::get_style_head_tags();

      if($frame eq "menu")
      {
         print "<html><head><BASE TARGET=\"_parent\">$head_tags</head><body class=\"topic-listing\">";
         &view::list_files_html($notes_path);
         &view::list_dirs_html($notes_path);
         print "</body></html>\n";
      }
      elsif($frame eq "header")
      {
         print "<html><head><BASE TARGET=\"_parent\">$head_tags</head>";
         print $view::define::index_header
            if(defined($view::define::index_header));
         print "</html>\n";
      }
      elsif($frame eq "footer")
      {
         print "<html><head><BASE TARGET=\"body\">$head_tags</head><body class=\"topic-actions\">\n";
         if(defined($view::define::index_footer))
         {
            print $view::define::index_footer;
         }
         else
         {
            &view::actions3($notes_path);
         }
         print "</body></html>\n";
      }
      return(0);
   }

   &view::set_view_mode("frame", "header");
   my ($header_bprefix, $header_bsuffix) = view::get_cgi_prefix();
   &view::set_view_mode("frame", "menu");
   my ($menu_bprefix, $menu_bsuffix) = view::get_cgi_prefix();
   &view::set_view_mode("frame", "footer");
   my ($footer_bprefix, $footer_bsuffix) = view::get_cgi_prefix();
   &view::unset_view_mode("frame");

   &view::set_view_mode("superlayout", "framed");

   my ($sub_bprefix, $sub_bsuffix) = view::get_cgi_prefix();

   print "<html> <head>\n";
   print "<title>$view::define::index_title</title>\n"
      if(defined($view::define::index_title));
   print <<"EOT";
<BASE TARGET="body">
<title>$view::define::index_title</title>
  </head>
EOT
   if(defined($view::define::index_header))
   {
      print <<"EOT";
<frameset rows = "60,*">
    <frame src="${header_bprefix}$notes_path_encoded$header_bsuffix" name="header" noresize marginwidth="0"
      marginheight="0" scrolling="no">
EOT
   }
   else
   {
      print "<frameset>\n";

   }
   print <<"EOT";
    <frameset cols = "25%,*">
        <frameset rows = "*, 50">
          <frame src="${menu_bprefix}$notes_path_encoded$menu_bsuffix" name="menu" marginwidth="0" marginheight="0">
          <frame src="${footer_bprefix}$notes_path_encoded$footer_bsuffix" name="footer" marginwidth="0"
                 marginheight="0" scrolling="no">
        </frameset>
   <frame src="${sub_bprefix}$notes_path_encoded$sub_bsuffix" name="body" marginwidth="0" marginheight=
"0">
    </frameset>
  </frameset>
</html>
EOT
}
1;
