#!/usr/bin/perl
use strict;

# plain version of the main WebKNotest script

# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

require 'view_lib.pl';

package browse_plain;

sub show_page
{
   my($path) = @_;
my $head_tags = view::get_style_head_tags();

print <<"END";
<HTML>
<head>
<title>${path}</title>
$head_tags
</head>
<BODY class="topics-back">
END
   show($path);
print "</BODY>\n";
print "</HTML>\n";
}

sub show
{
my($notes_path) = @_;
unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   return(0);
}

$notes_path =~ m:([^/]*)$:;
my($notes_name) = $1;

		
        print '<div class="topic-text">';
	my $dir_file = &view::print_dir_file( $notes_path );
        print "</div>\n";        
        
        print "<hr>\n";
        print '<div class="topic-title">';
	print "<b>$notes_name</b><br>\n";
        print "</div>\n";        
        
        print '<div class="topic-info">';
        view::print_modification($notes_path);
        print "</div>\n";        
        print "<hr>\n";
        
        &view::log($notes_path);
        if($dir_file ne "index.html" and $dir_file ne "index.htm")
        {
           print '<div class="topic-listing">';
           &view::list_files_html($notes_path);
           &view::list_dirs_html($notes_path);
           print "</div>\n";
           print "<hr>";
        }
        
        print '<div class="topic-actions">';
        &view::actions2($notes_path);
        
        print "</div>\n";        
	print "<hr>\n";
        print '<div class="topic-actions">';
	&view::actions3($notes_path);
        print "</div>\n";        
return 1;
}
