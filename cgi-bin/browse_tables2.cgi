#!/usr/bin/perl
use strict;
# main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'COPYING'
# dmahurin@users.sourceforge.net

print "Content-type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'wkn_define.pl';
require 'wkn_lib.pl';
require 'css_tables.pl';

$wkn::view_mode{"layout"} = "tables2";

my $notes_path_encoded = &wkn::parse_view_mode($ENV{QUERY_STRING});

my($notes_path) = &wkn::path_check(&wkn::url_unencode_path($notes_path_encoded));
exit(0) unless(defined($notes_path));

my $style = wkn::get_style_header_string();

print <<"END";
<HTML>
<head>
$style
</head>
<BODY class="topics-back">
$style
END

print_main_topic_table($notes_path);

exit unless
opendir(DIR, "$auth::define::doc_dir/$notes_path");
my $file;
while($file = readdir(DIR))
{
	next if( $file =~ m:^\.: );
	next if( $file =~ m:^README(\.html)?:);
	next if( $file eq "index.html");

	if( $file =~ m:^([^/]*)$: ) # untaint dir entry
        {
		$file = $1;
	}
	else
	{
		print "hey, /'s ? not ggod.\n";
                exit;
	}
        $file = "$notes_path/$file" if($notes_path);
	print_topic_table( "$file");	
}
closedir(DIR);

print css_tables::table_begin("topic-table") . "\n";
print "<tr>" . css_tables::trtd_begin("topic-actions") . "\n";
wkn::actions3($notes_path);
print css_tables::trtd_end() . "</tr>\n";
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
	print "&nbsp;" unless(&wkn::print_dir_file($notes_path));
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
	&wkn::print_dir_file($notes_path);
        print css_tables::trtd_end() . "\n";
        
        print css_tables::trtd_begin("topic-actions") . "\n";
	wkn::actions2($notes_path);
        print css_tables::trtd_end() . "\n";
        
        print css_tables::trtd_begin("topic-listing") . "\n";
        print "&nbsp;" unless(&wkn::list_html($notes_path));
        print css_tables::trtd_end() . "\n";
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
