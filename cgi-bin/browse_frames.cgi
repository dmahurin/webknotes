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

my $mode = defined ($wkn::define::frames_mode) ? $wkn::define::frames_mode :
$wkn::define::mode;

my(@args) = split('&', $ENV{QUERY_STRING});
my($frame, $notes_path_encoded);

my(@args) = split('&', $ENV{QUERY_STRING});
my($frame);
my $notes_path_encoded = shift(@args);
if( $notes_path_encoded =~ m:^frame=:) 
{
   $frame = $';
   $notes_path_encoded = shift(@args);
}
my($notes_path) = &wkn::path_check(&wkn::url_unencode_path($notes_path_encoded));
exit(0) unless(defined($notes_path));

if(defined($frame))
{
   if($frame eq "menu")
   {
      $wkn::define::mode = "frames";
      print "<html><head><BASE TARGET=\"_parent\"></head>";
      &wkn::list_files_html($notes_path);
      &wkn::list_dirs_html($notes_path);
      print "</html>\n";
   }
   elsif($frame eq "header")
   {
      print "<html><head><BASE TARGET=\"_parent\"></head>";
      print &wkn::translate_html($wkn::define::index_header)
        if(defined($wkn::define::index_header));
      print "</html>\n";
   }
   elsif($frame eq "footer")
   {
      print "<html><head><BASE TARGET=\"body\"></head>\n";
      if(defined($wkn::define::index_footer))
      {
         print &wkn::translate_html($wkn::define::index_footer, "");
      }
      else
      {
         &wkn::actions3($notes_path);
      }
      print "</html>\n";
   }
   exit(0);
}

print "<html> <head>\n";
print "<title>$wkn::define::index_title</title>\n" 
  if(defined($wkn::define::index_title));
print <<EOT
<BASE TARGET="body">
<title>$wkn::define::index_title</title>
  </head>
  <frameset rows = "60,*">
    <frame src="$this_script?frame=header&$notes_path" name="header" noresize marginwidth="0"
      marginheight="0" scrolling="no">
    <frameset cols = "25%,*">
        <frameset rows = "*, 50">
          <frame src="$this_script?frame=menu&$notes_path" name="menu" marginwidth="0" marginheight="0">
          <frame src="$this_script?frame=footer&$notes_path" name="footer" marginwidth="0"
                 marginheight="0" scrolling="no">
        </frameset>
      <frame src="browse_$mode.cgi?$notes_path" name="body" marginwidth="0" marginheight=
"0">
    </frameset>
  </frameset>
</html>
EOT
