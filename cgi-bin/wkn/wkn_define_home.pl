#!/usr/local/bin/perl
#defines paths that are used in the WebKNotes system

package wkn::define;

local($main_dir) = "/home/dmahurin/web";
local($public_dir) = "$main_dir/public";

local($public_wpath) = "/~dmahurin";
local($base_cgi_wpath) = "/~dmahurin/cgi-bin";

$icons_wpath = "$public_wpath/icons";

# the static index file that wkn_index.cgi should create
$gen_index_script="wkn_page.cgi";
$gen_index_file="$public_dir/index.html";

$notes_dir = "$public_dir/notes";
$notes_wpath = "$public_wpath/notes";
$cgi_wpath = "$base_cgi_wpath/wkn";

$mode = "table";
$page_mode = "table";
$frames_mode = "table";
#$sendmailer = "/usr/sbin/sendmail -t -oi";

$max_depth = 3;

$email = 'dmahurin@users.sourceforge.net';
$admin_email = 'dmahurin@users.sourceforge.net';
$subs_prefix = 'KN-subs: ';
$unsubs_prefix = 'KN-unsubs: ';

sub filename_filter
{
   my($name) = @_;
   $name =~ s:_: :g;
   return $name;
}
$skip_files = '(~$)';

# auth defines
$auth_inc = "$main_dir/cgi-bin/auth";
$auth_lib = "auth-lib.pl";
$auth_subpath = "notes";
$auth_cgi_wpath = "$base_cgi_wpath/auth";
$edit = "$auth_cgi_wpath/edit.cgi?file=";

$index_title = "Don's WebKNotes";
$index_header = "
[ <A HREF=\"$cgi_wpath/wkn_other.cgi\">Other Browsing Methods</a> ]
[ <a href=\"$public_wpath/files\">  File Area Index</a>]";
$index_footer = "[<a href=\"mailto:dmahurin\@users.sourceforge.net\" >dmahurin\@users.sourceforge.net</a>]
[<a href=\"$cgi_wpath/search.cgi\">Search</a>]   
[<a href=\"$auth_cgi_wpath/user_access.cgi\">User Accounts</a>]";

$opened_icon = "fminus.gif";
$opened_icon_text = '[-]';
$closed_icon = "fplus.gif";
$closed_icon_text = '[+]';
$dir_icon = "folder.gif";
$dir_icon_text = '[+]';
$file_icon = "document.gif";
$file_icon_text = '[.]';
