#!/usr/bin/perl
use strict;
# main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'COPYING'
# dmahurin@users.sourceforge.net

require 'css_tables.pl';

package browse;

sub show_page
{
my($path) = @_;
my $head_tags = wkn::get_style_head_tags();

print <<"END";
<HTML>
<head>
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
   exit(0);
}
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
return 1;
}


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
1;
