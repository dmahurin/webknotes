#!/usr/bin/perl
use strict;
no strict 'refs';

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

print "Content-type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'wkn_define.pl';
require 'wkn_lib.pl';
require 'css_tables.pl';

$wkn::view_mode{"layout"} = "list";

my($notes_path) = wkn::get_args();
$notes_path = auth::path_check($notes_path);
exit(0) unless(defined($notes_path));

unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}

$notes_path =~ m:([^/]*)$:;
my $notes_name = $1;


my($user) = auth::get_user();
if( ! auth::check_file_auth( $user, auth::get_user_info($user),
    'r', $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}

my $head_tags = wkn::get_style_head_tags();

print
"<HTML>
<head>
<title>${notes_path}</title>
$head_tags
</head>" .
"<BODY class=\"topics-back\">";

print css_tables::table_begin("topic-table") . "\n";

print css_tables::trtd_begin("topic-text") . "\n";
&wkn::print_dir_file($notes_path);
print css_tables::trtd_end() . "\n";

print css_tables::trtd_begin("topic-title") . "\n";
wkn::print_icon_img($notes_path);
print "<b>$notes_name</b>";
print css_tables::trtd_end() . "\n";

print css_tables::trtd_begin("topic-info") . "\n";
wkn::print_modification($notes_path);
print css_tables::trtd_end() . "\n";

print css_tables::trtd_begin("topic-actions") . "\n";
wkn::actions2($notes_path);
print css_tables::trtd_end() . "\n";

print css_tables::trtd_begin("topic-listing") . "\n";

my($toppath) = "$auth::define::doc_dir";
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
       $name = wkn::define::filename_filter($filename) if defined(&wkn::define::filename_filter);
       next unless ( defined($name));

       my $fullpath = $dirs[$#dirs] ne "" ? "$dirs[$#dirs]/$filename" : $filename;
       my $encoded_notes_path = wkn::url_encode_path("$notes_base$fullpath");

       # Dir, traverse down it
       if ( defined($wkn::define::skip_files) and $filename =~ m/$wkn::define::skip_files/)
       {
       }
       elsif (-d "$toppath/$fullpath" )
       {
          print "$indent<li><a href=\"" ,
          &wkn::get_cgi_prefix(),
             $encoded_notes_path , "\">";
          if(defined($wkn::define::max_depth) and $depth >= $wkn::define::max_depth)
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
          &wkn::get_cgi_prefix(),
          $encoded_notes_path. "\">$name</a>\n";
       }
       else
       {
          print "$indent<li><a href=\"$auth::define::doc_wpath/$encoded_notes_path\">$name</a>\n";
       }
   }
}
print css_tables::trtd_end() . "\n";
print css_tables::table_end() . "\n";

print css_tables::table_begin("topic-table") . "\n";
print css_tables::trtd_begin("topic-actions") . "\n";
wkn::actions3($notes_path);
print css_tables::trtd_end() . "\n";
print css_tables::table_end() . "\n";

print "</BODY>\n";
print "</HTML>\n";
