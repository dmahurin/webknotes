#!/usr/bin/perl
require 'css_tables.pl';
use strict;
no strict 'refs';

package browse_list;

# The WebKNotes system is Copyright 1996-2002 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

sub show_page
{
   my($path) = @_;
   my $head_tags = view::get_style_head_tags();

   print
"<HTML>
<head>
<title>${path}</title>
$head_tags
</head>" .
"<BODY class=\"topics-back\">";
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

$notes_path =~ m:([^/]*)$:;
my $notes_name = $1;

print $css_tables->table_begin("topic-table") . "\n";

print $css_tables->trtd_begin("topic-text") . "\n";
&view::print_dir_file($notes_path);
print $css_tables->trtd_end() . "\n";

print $css_tables->trtd_begin("topic-title") . "\n";
view::print_icon_img($notes_path);
print "<b>$notes_name</b>";
print $css_tables->trtd_end() . "\n";

print $css_tables->trtd_begin("topic-info") . "\n";
view::print_modification($notes_path);
print $css_tables->trtd_end() . "\n";

print $css_tables->trtd_begin("topic-actions") . "\n";
view::actions2($notes_path);
print $css_tables->trtd_end() . "\n";

print $css_tables->trtd_begin("topic-listing") . "\n";

my($toppath) = "$filedb::define::doc_dir";
$toppath .= "/$notes_path" if( $notes_path ne "");

my($notes_base) = $notes_path eq "" ? "" : "$notes_path/";
my($depth) = 1;
if(-d $toppath)
{
   
   my @dirs = ( "" );
   opendir("DIR0", $toppath) or print "Error opening top notes dir\n";
   print "<ul>\n";
   my($indent) = " ";

   while( @dirs )
   {
       #done with a directory
       my $filename = readdir("DIR$#dirs");
       unless(defined($filename))
       {
          closedir("DIR$#dirs");
          pop(@dirs);
          $indent = substr($indent, 1);
          $depth--;
          print "$indent</ul>\n";
          next;
       }

      next if ($filename =~ m:^\.:);
      next if ($filename eq 'README' or 
         $filename =~ m:^(README|index)\.(txt|html|htm)$: );
       next if ($filename =~ m:(\.bak|~)$:);

       my($name) = $filename;
       my($bprefix, $bsuffix) = &view::get_cgi_prefix();
       $name = view::define::filename_filter($filename) if defined(&view::define::filename_filter);
       next unless ( defined($name));

       my $fullpath = $dirs[$#dirs] ne "" ? "$dirs[$#dirs]/$filename" : $filename;
       my $encoded_notes_path = view::url_encode_path("$notes_base$fullpath");

       # Dir, traverse down it
       if ( defined($view::define::skip_files) and $filename =~ m/$view::define::skip_files/)
       {
       }
       elsif (-d "$toppath/$fullpath" )
       {
          print "$indent<li><a href=\"" ,
          $bprefix.
             $encoded_notes_path . $bsuffix, "\">";
          if(defined($view::define::max_depth) and $depth >= $view::define::max_depth)
          {
             my ($count, $dir ) = ( 0 );
             if( opendir(DIRMAX, "$toppath/$fullpath") )
             {
                while($dir = readdir(DIRMAX))
                { $count++ if($dir =~ m:^[^\.]:); }
                close(DIRMAX);
                $name .= " ($count)";
             }
             print "$name</a>\n";
          }
          else
          {
             print "$name</a>\n";
             $depth++;
             push(@dirs, $fullpath);
             opendir("DIR$#dirs", "$toppath/$fullpath") or
                print "Cannot open dir: $fullpath\n";
             print "$indent<ul>\n";
             $indent .= " ";
          }

       }
       elsif($name =~ m:\.(html|txt)$:)
       {
          $name = $`;
          print "$indent<li><a href=\"" .
          $bprefix .
          $encoded_notes_path. $bsuffix ."\">$name</a>\n";
       }
       else
       {
          print "$indent<li><a href=\"$filedb::define::doc_wpath/$encoded_notes_path\">$name</a>\n";
       }
   }
}
print $css_tables->trtd_end() . "\n";
print $css_tables->table_end() . "\n";

unless(view::get_view_mode("superlayout") eq "framed")
{
	print $css_tables->table_begin("topic-table") . "\n";
	print $css_tables->trtd_begin("topic-actions") . "\n";
	view::actions3($notes_path);
	print $css_tables->trtd_end() . "\n";
	print $css_tables->table_end() . "\n";
}
return 1;
}
1;


