#!/usr/bin/perl
use strict;
# expanded tables version of the main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

require 'css_tables.pl';

package browse_tables;

sub show_page
{
 my($path)=@_;
my $head_tags = view::get_style_head_tags();

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
   my($css_tables) = css_tables->new();
unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   return(0);
}
print_main_topic_table($notes_path, $css_tables);
print "<br>";

return(0) unless
opendir(DIR, "$filedb::define::doc_dir/$notes_path");
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
		print "hey, /'s ? not good.\n";
                return(0);
	}
	print_topic_table( "$notes_path/$file", $css_tables);	
}
closedir(DIR);

print $css_tables->table_begin("topic-table") . "\n";
print $css_tables->trtd_begin("topic-actions") . "\n";
view::actions3($notes_path);
print $css_tables->trtd_end();
print $css_tables->table_end() . "\n";
return 1;
}


sub print_main_topic_table
{
	my($notes_path, $css_tables) = @_;
	$notes_path =~ m:([^/]*)$:;
	my $notes_name = $1;

        print $css_tables->table_begin("topic-table") . "\n";
        print $css_tables->trtd_begin("topic-title") . "\n";
	print "<b>$notes_name</b>\n";
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-info") . "\n";
	&view::print_modification($notes_path);
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-text") . "\n";
	print "&nbsp;" unless (&view::print_dir_file($notes_path));
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-actions") . "\n";
	view::actions2($notes_path);
        print $css_tables->trtd_end() . "\n";
        print $css_tables->table_end() . "\n";
}

sub print_topic_table
{
	my($notes_path, $css_tables) = @_;
	$notes_path =~ m:([^/]*)$:;
	my $notes_name = $1;

        print $css_tables->table_begin("topic-table") . "\n";
        
        print $css_tables->trtd_begin("sub-topic-title") . "\n";
#	print "<b>$notes_name</b><br>\n";
        print_icon_link($notes_path);
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-info") . "\n";
	&view::print_modification($notes_path);
        print $css_tables->trtd_end() . "\n";
        
        print $css_tables->trtd_begin("topic-text") . "\n";
	print "&nbsp;" unless (&view::print_dir_file($notes_path));
        print $css_tables->trtd_end() . "\n";
        
        #	print "<tr><td class=\"listing\">\n";
#	view::actions2($notes_path);
#	print "</td></tr>\n";
#	print "<tr><td class=\"listing\">\n";
#	&view::list_html($notes_path);
#	print "</td></tr>\n";
        print $css_tables->table_end() . "\n";
}

sub print_icon_link
{
        my($path) = @_;
        $path =~ m:([^/]*)$:;
        my $name = $1;
        my($wpath) = &view::url_encode_path($path);
        
        print "<A HREF=\"" ,
           &view::get_cgi_prefix() ,
        "$wpath\">";
        view::print_icon_img($path);
	print "</a>";
        print "<A HREF=\"" ,
           &view::get_cgi_prefix() ,
        "$wpath\">";
        print "<b>$name</b></a>";
}
1;
