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

local $wkn::define::mode = "list";
my $notes_path_encoded = $ENV{QUERY_STRING};
my($notes_path) = &wkn::path_check(&wkn::url_unencode_path($notes_path_encoded));
exit(0) unless(defined($notes_path));

$notes_path =~ m:([^/]*)$:;
my $notes_name = $1;

my($user) = auth::get_user();
if( ! auth::check_file_auth( $user, auth::get_user_info($user),
    'r', $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}

print <<"END";
<HTML>
<head>
</head>
<BODY $wkn::attr::body>
END

print "<table border=0 cellpadding=8>\n";
print "<tr><td $wkn::attr::td_description>\n";
if(&wkn::print_dir_file($notes_path))
{
   print "</td></tr>\n";
   print "<tr><td $wkn::attr::td_list>\n";
}
wkn::print_icon_img($notes_path);
print "<b>$notes_name</b> - ";
wkn::print_modification($notes_path);
#print "<table><tr><td rowspan=2>";
#wkn::print_icon_img($notes_path);
#print "</td><td><b>$notes_name</b><br><td></tr><tr><td>\n";
#wkn::print_modification($notes_path);
#print "</td></tr></table>\n";
print "</td></tr>\n";
print "<tr><td $wkn::attr::td_list>\n";
#if(&wkn::list_files_html($notes_path))
#{
#   print "</td></tr>\n";
#   print "<tr><td $wkn::attr::td_list>\n";
#}
wkn::actions2($notes_path);
print "</td></tr>\n";
print "<tr><td $wkn::attr::td_list>\n";

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

       next if ( $filename =~ m:^(\.|README|index.html): );
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
          &wkn::mode_to_scriptprefix($wkn::define::mode),
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
          &wkn::mode_to_scriptprefix($wkn::define::mode),
          $encoded_notes_path. "\">$name</a>\n";
       }
       else
       {
          print "$indent<li><a href=\"$auth::define::doc_wpath/$encoded_notes_path\">$name</a>\n";
       }
   }
}
print "</table>\n";
print "</td></tr>\n";
print "<td><tr>\n";
print "<table border=0 cellpadding=8>\n";
print "<tr><td $wkn::attr::td_list>\n";
wkn::actions3($notes_path);
print "</td></tr>\n";

print "</table>\n";
print "</BODY>\n";
print "</HTML>\n";
