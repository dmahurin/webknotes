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

$wkn::define::mode = "tables";

my $notes_path_encoded = $ENV{QUERY_STRING};
my($notes_path) = &wkn::path_check(&wkn::url_unencode_path($notes_path_encoded));
exit(0) unless(defined($notes_path));

print <<"END";
<HTML>
<BODY $wkn::attr::body>
END

print_main_topic_table($notes_path);

exit unless
opendir(DIR, "$auth::define::doc_dir/$notes_path");
my $file;
while($file = readdir(DIR))
{
	next if( $file =~ m:^\.: );
        next if ($filename eq 'README' or
           $filename =~ m:^(README|index)\.(txt|html|htm)$: );

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

print "<table border=0 cellpadding=8>\n";
print "<tr><td $wkn::attr::td_highlight>\n";
wkn::actions3($notes_path);
print "</td></tr>\n";
print "</table><br>\n";

print "</BODY>\n";
print "</HTML>\n";

sub print_main_topic_table
{
	my($notes_path) = @_;
	$notes_path =~ m:([^/]*)$:;
	my $notes_name = $1;

	print "<table border=0 cellpadding=8>\n";
	print "<tr><td $wkn::attr::td_title>\n";
	print "<b><font $wkn::attr::font_table_title>$notes_name</font></b><br>\n";
	print "</td></tr>\n";
	print "<tr><td $wkn::attr::td_highlight>\n";
	&wkn::print_modification($notes_path);
	print "</td></tr>\n";
	print "<tr><td $wkn::attr::td_description>\n";
	&wkn::print_dir_file($notes_path);
	print "</td></tr>\n";
	print "<tr><td $wkn::attr::td_highlight>\n";
	wkn::actions2($notes_path);
	print "</td></tr>\n";
	print "</table><br>\n";
}

sub print_topic_table
{
	my($notes_path) = @_;
	$notes_path =~ m:([^/]*)$:;
	my $notes_name = $1;

	print "<table border=0 cellpadding=8>\n";
	print "<tr><td $wkn::attr::td_highlight>\n";
#	print "<b>$notes_name</b><br>\n";
	wkn::print_link_html($notes_path);
#        print_icon_link_info($notes_path);
	print "</td></tr>\n";
	print "<tr><td $wkn::attr::td_description>\n";
	&wkn::print_dir_file($notes_path);
	print "</td></tr>\n";
#	print "<tr><td $wkn::attr::td_list>\n";
#	wkn::actions2($notes_path);
#	print "</td></tr>\n";
#	print "<tr><td $wkn::attr::td_list>\n";
#	&wkn::list_html($notes_path);
#	print "</td></tr>\n";
	print "</table><br>\n";
}

sub print_icon_link_info
{
        my($path) = @_;
        $path =~ m:([^/]*)$:;
        my $name = $1;

        print "<table>\n";
        print "<tr><td rowspan=2>\n";
        print "<A HREF=\""
           &wkn::mode_to_scriptprefix($wkn::define::page_mode) ,
        "$path\">";
        wkn::print_icon_img($path);
	print "</a></td>\n<td>";
        print "<A HREF=\""
           &wkn::mode_to_scriptprefix($wkn::define::page_mode) ,
        "$path\">";
        print "$name</a></td></tr><tr><td>\n";
	&wkn::print_modification($notes_path);
        print "</td></tr></table>\n";
}
