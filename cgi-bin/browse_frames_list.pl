#!/usr/bin/perl
use strict;
# single table version of main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

package browse_frames_list;

sub show_page
{
  my($notes_path)=@_;
unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   return(0);
}


my $cgi_arg = view::get_query_string();
my $notes_path_encoded = view::url_encode_path($notes_path);

my $frame = $view::view_mode{"frame"};
undef($view::view_mode{"frame"});

if(defined($frame))
{
   my $head_tags = view::get_style_head_tags();
   if($frame eq "header")
   {
      print "<html><head><BASE TARGET=\"_parent\">$head_tags</head>";
      print ($view::define::index_header)
        if(defined($view::define::index_header));
      print "</html>\n";
   }
   elsif($frame eq "footer")
   {
      print "<html><head><BASE TARGET=\"body\">$head_tags</head><body class=\"topic-actions\">\n";
      if(defined($view::define::index_footer))
      {
         print ($view::define::index_footer, "");
      }
      else
      {
         &view::actions3($notes_path);
      }
      print "</body></html>\n";
   }
   return(0);
}  
my $this_cgi_script_prefix = view::get_cgi_prefix();
&view::set_view_mode("layout", "list2");
my $list_cgi_script_prefix = view::get_cgi_prefix();
&view::set_view_mode("layout", &view::get_view_mode("sublayout"));
&view::unset_view_mode("sublayout");                          
my $cgi_script_prefix = view::get_cgi_prefix();

#print "$cgi_script_prefix, $list_cgi_script_prefix, $this_cgi_script_prefix\n";
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
   <frame src="${this_cgi_script_prefix}frame=header&$notes_path_encoded" name="header" noresize marginwidth="0"
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
   <frame src="${list_cgi_script_prefix}target=body&$notes_path_encoded" name="menu" marginwidth="0" marginheight="0">
   <frame src="${this_cgi_script_prefix}frame=footer&$notes_path_encoded" name="footer" marginwidth="0"
                 marginheight="0" scrolling="no">
        </frameset>
   <frame src="${cgi_script_prefix}$notes_path_encoded" name="body" marginwidth="0" marginheight=
"0">
    </frameset>
  </frameset>
</html>
EOT
}
1;
