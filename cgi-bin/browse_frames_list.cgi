#!/usr/bin/perl
use strict;
# single table version of main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

print "Content-type: text/html\n\n";

my $this_script;
if( $0 =~ m:/([^/]*)$: ) 
{  push @INC, $`; $this_script = $1; }
else
{ $this_script = $0; }

require 'wkn_define.pl';
require 'wkn_lib.pl';

my($notes_path) = wkn::get_args();
$notes_path = auth::path_check($notes_path);
exit(0) unless(defined($notes_path));

unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}


my $cgi_arg = wkn::get_query_string();
my $notes_path_encoded = wkn::url_encode_path($notes_path);

my $frame = $wkn::view_mode{"frame"};
undef($wkn::view_mode{"frame"});

if(defined($frame))
{
   if($frame eq "header")
   {
      print "<html><head><BASE TARGET=\"_parent\"></head>";
      print ($wkn::define::index_header)
        if(defined($wkn::define::index_header));
      print "</html>\n";
   }
   elsif($frame eq "footer")
   {
      print "<html><head><BASE TARGET=\"body\"></head>\n";
      if(defined($wkn::define::index_footer))
      {
         print ($wkn::define::index_footer, "");
      }
      else
      {
         &wkn::actions3($notes_path);
      }
      print "</html>\n";
   }
   exit(0);
}
my $cgi_script_prefix = wkn::get_cgi_prefix();
my $list_cgi_script_prefix = wkn::get_cgi_prefix("browse_list2.cgi");
my $this_cgi_script_prefix = wkn::get_cgi_prefix($this_script);

#print "$cgi_script_prefix, $list_cgi_script_prefix, $this_cgi_script_prefix\n";
print "<html> <head>\n";
print "<title>$wkn::define::index_title</title>\n" 
  if(defined($wkn::define::index_title));
print <<EOT
<BASE TARGET="body">
<title>$wkn::define::index_title</title>
  </head>
  <frameset rows = "60,*">
   <frame src="${this_cgi_script_prefix}frame=header&$notes_path_encoded" name="header" noresize marginwidth="0"
      marginheight="0" scrolling="no">
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
