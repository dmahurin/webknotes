#!/usr/bin/perl
use strict;

# plain version of the main WebKNotest script

# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

print "Content-type: text/html

<HTML>
";


$|=1;

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'wkn_define.pl';
require 'wkn_lib.pl';

local($wkn::define::mode) = "plain";

my($notes_path) = wkn::get_args();
$notes_path = auth::path_check($notes_path);
exit(0) unless(defined($notes_path));

unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}

$notes_path =~ m:([^/]*)$:;
my($notes_name) = $1;


my($user) = auth::get_user();
unless (auth::check_file_auth( $user, auth::get_user_info($user),
   'r', $notes_path) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}

my $head_tags = wkn::get_style_head_tags();

print <<"END";
<HTML>
<head>
<title>${notes_path}</title>
$head_tags
</head>
<BODY class="topics-back">
END

my($real_path) = "$auth::define::doc_dir/${notes_path}";
#print "<h1>";
#if ( &wkn::print_file("${notes_path}/.type") )
#{
#	print " : ";
#}

#print "${notes_path}</h1>\n<hr size=4\n";

#if ( -f $real_path )
#{
#	&wkn::print_dir_file($notes_path);
#
#	print "<br>";
#}
#elsif ( -d "${real_path}" )
{
		
        print '<div class="topic-text">';
	my $dir_file = &wkn::print_dir_file( $notes_path );
        print "</div>\n";        
        
        print "<hr>\n";
        print '<div class="topic-title">';
	print "<b>$notes_name</b><br>\n";
        print "</div>\n";        
        
        print '<div class="topic-info">';
        wkn::print_modification($notes_path);
        print "</div>\n";        
        print "<hr>\n";
        
        &wkn::log($notes_path);
        if($dir_file ne "index.html" and $dir_file ne "index.htm")
        {
           print '<div class="topic-listing">';
           &wkn::list_files_html($notes_path);
           &wkn::list_dirs_html($notes_path);
           print "</div>\n";
           print "<hr>";
        }
        
        print '<div class="topic-actions">';
        &wkn::actions2($notes_path);
        
        print "</div>\n";        
	print "<hr>\n";
        print '<div class="topic-actions">';
	&wkn::actions3($notes_path);
        print "</div>\n";        
}
#else # not dir or file
#{
#	print "Notes path '${notes_path}' is not accessible<br>";
#}

print "</BODY>\n";
print "</HTML>\n";
