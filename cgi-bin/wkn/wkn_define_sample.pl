#!/usr/local/bin/perl
#defines paths that are used in the WebKNotes system

package wkn::define;

# This definition file is the simplest case. Drop the wkn distribution in
# a web dir, and just run it out of there.
#
# This will only work if your web server allows you to run cgi scripts
# anywhere.
#
# This also is letting the web user see more information than they need.
# (possibly the private dir, if the permissions are not correct.)

# where public and private dirs are:
local($main_dir) = "/home/someuser/wkn";
local($main_wpath) = "http://~someuser/wkn";

#file location public dir where icons, notes, and files reside
local($public_dir) = "$main_dir/public";

#web address of public dir
local($public_wpath) = "$main_wpath/public";

# web address of cgi-bin dir where auth and wkn reside
local($base_cgi_wpath) = "$main_wpath/cgi-bin";
# if cgi script go in a specific cgi-bin dir, then move wkn/cgi-bin/* there
#local($base_cgi_wpath) = "~someuser/cgi-bin";

#where the icon images go
$icons_wpath = "$public_wpath/icons";

#default icon image (optional)
#$default_icon = "folder.gif";

$notes_dir = "$public_dir/notes";
$notes_wpath = "$public_wpath/notes";
$cgi_wpath = "$base_cgi_wpath/wkn";

$mode = "table";

$max_depth = 3;

# the static index file that wkn_index.cgi should create
# put it in the public root
#$gen_index_file="$public_dir/index.html";
# if you have all of wkn web visible, go ahead and put the index at the top
$gen_index_file="$main_dir/index.html";
$index_title = "WebKNotes Sample";
#$index_header = ""; # replace the default header here
#$index_footer = "<a href=\"mailto:you\@somewhere.org\" >you\@somewhere.org</a>\n";

# What notes topics should be on the static page
@topic_rows = ( [ "", "sample/another test" ], ["sample"] ); 

sub filename_filter
{
   my($name) = @_;
   # Underscores to spaces                            
   $name =~ s:_: :g;
   # Expand mixed case names
   $name =~ s:([a-z])([A-Z]):$1 $2:g;
   # Everything starts with Caps
   $name = uc(substr($name,0,1)) . substr($name,1);
   return $name;
}

#external package : auth

# auth defines
$auth_inc = "$main_dir/cgi-bin/auth";
$auth_lib = "auth-lib.pl";
$auth_subpath = "";
$auth_cgi_wpath = "$base_cgi_wpath/auth";
$edit = "$auth_cgi_wpath/edit.cgi?file=";

$opened_icon_text = '[-]';
#$opened_icon = "fminus.gif";
$closed_icon_text = '[+]';
#$closed_icon = "fplus.gif";
$dir_icon_text = '[+]';
#$dir_icon = "folder.gif";
$file_icon_text = '[.]';
#$file_icon = "document.gif";
