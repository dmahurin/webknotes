#!/usr/bin/perl
use strict;
# expanded tables version of the main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

print "Content-type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'wkn_define.pl';
require 'wkn_lib.pl';
require 'css_tables.pl';

$wkn::view_mode{"layout"} = "tables";

my($notes_path) = wkn::get_args();
$notes_path = auth::path_check($notes_path);
exit(0) unless(defined($notes_path));

unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}

my $head_tags = wkn::get_style_head_tags();

print <<"END";
<HTML>
<head>
$head_tags
</head>
<BODY class="topics-back">
END

print_main_topic_table($notes_path);
print "<br>";

exit unless
opendir(DIR, "$auth::define::doc_dir/$notes_path");
my $file;
while($file = readdir(DIR))
{
	next if( $file =~ m:^\.: );
        next if ($file eq 'README' or
           $file =~ m:^(README|index)\.(txt|html|htm)$: );

	if( $file =~ m:^([^/]*)$: ) # untaint dir entry
        {
		$file = $1;
	}
	else
	{
		print "hey, /'s ? not ggod.\n";
                exit;
	}
	print_topic_table( "$notes_path/$file");	
}
closedir(DIR);

print css_tables::table_begin("topic-table") . "\n";
print css_tables::trtd_begin("topic-actions") . "\n";
wkn::actions3($notes_path);
print css_tables::trtd_end();
print css_tables::table_end() . "\n";

print "</BODY>\n";
print "</HTML>\n";

sub print_main_topic_table
{
	my($notes_path) = @_;
	$notes_path =~ m:([^/]*)$:;
	my $notes_name = $1;

        print css_tables::table_begin("topic-table") . "\n";
        print css_tables::trtd_begin("topic-title") . "\n";
	print "<b>$notes_name</b>\n";
        print css_tables::trtd_end() . "\n";
        
        print css_tables::trtd_begin("topic-info") . "\n";
	&wkn::print_modification($notes_path);
        print css_tables::trtd_end() . "\n";
        
        print css_tables::trtd_begin("topic-text") . "\n";
	print "&nbsp;" unless (&wkn::print_dir_file($notes_path));
        print css_tables::trtd_end() . "\n";
        
        print css_tables::trtd_begin("topic-actions") . "\n";
	wkn::actions2($notes_path);
        print css_tables::trtd_end() . "\n";
        print css_tables::table_end() . "\n";
}

sub print_topic_table
{
	my($notes_path) = @_;
	$notes_path =~ m:([^/]*)$:;
	my $notes_name = $1;

        print css_tables::table_begin("topic-table") . "\n";
        
        print css_tables::trtd_begin("sub-topic-title") . "\n";
#	print "<b>$notes_name</b><br>\n";
        print_icon_link($notes_path);
        print css_tables::trtd_end() . "\n";
        
        print css_tables::trtd_begin("topic-info") . "\n";
	&wkn::print_modification($notes_path);
        print css_tables::trtd_end() . "\n";
        
        
        print css_tables::trtd_begin("topic-text") . "\n";
	print "&nbsp;" unless (&wkn::print_dir_file($notes_path));
        print css_tables::trtd_end() . "\n";
        
        #	print "<tr><td class=\"listing\">\n";
#	wkn::actions2($notes_path);
#	print "</td></tr>\n";
#	print "<tr><td class=\"listing\">\n";
#	&wkn::list_html($notes_path);
#	print "</td></tr>\n";
        print css_tables::table_end() . "\n";
}

sub print_icon_link
{
        my($path) = @_;
        $path =~ m:([^/]*)$:;
        my $name = $1;
        my($wpath) = &wkn::url_encode_path($path);
        
        print "<A HREF=\"" ,
           &wkn::get_cgi_prefix() ,
        "$wpath\">";
        wkn::print_icon_img($path);
	print "</a>";
        print "<A HREF=\"" ,
           &wkn::get_cgi_prefix() ,
        "$wpath\">";
        print "<b>$name</b></a>";
}
