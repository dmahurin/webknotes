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
local($main_dir) = "/misc/pdweb2/fnd/dev/oi";

#leaving off http://pdweb, as this will be implied
local($main_wpath) = "/fnd/dev/oi";


#file location public dir where icons, notes, and files reside
local($public_dir) = "$main_dir";

#web address of public dir
local($public_wpath) = "$main_wpath";

# web address of cgi-bin dir where auth and wkn reside
local($base_cgi_wpath) = "$main_wpath/wkn/cgi-bin";

#where the icon images go
$icons_wpath = "$main_wpath/icons";

#default icon image (optional)
$default_icon = "folder.gif";

$notes_dir = "$main_dir/docs";
$notes_wpath = "$main_wpath/docs";
$cgi_wpath = "$base_cgi_wpath/wkn";

$mode = "plain";

$max_depth = 3;
$skip_files = '((^(cgi-bin|pictures)$)|\.(ps|pdf|PDF|bck|bak|cgi)$|~$)';
sub filename_filter
{
   my($name) = @_;
   # Underscores to spaces                            
   $name =~ s:_: :g;
   # Expand mixed case names
   $name =~ s:([a-z])([A-Z]):$1 $2:g;
   # Everything starts with Caps
   $name = uc(substr($name,0,1)) . substr($name,1);

   # abbreviation fixes
   $name =~ s:\b(cxx|cpp)\b:C++:i;
   $name =~ s:\boi\b:OI:i;
   $name =~ s:\bms(\d+)\b:MS $1:i;
   $name =~ s:\boa\b:OA:i;
   $name =~ s:\b(doc)\b:$1umenation:i;
   $name =~ s:\b(Simu)\b:$1lation:i;
   $name =~ s:\b(Dyn)\b:$1amic Library:i;
   $name =~ s:\b(Func)\b:$1tion:i;
   $name =~ s:\b(St)d\b:$1andard:i;
   $name =~ s:\b(Pr)j\b:$1oject:i;
   $name =~ s:\b(env)\b:$1ironment:i;
   $name =~ s:\bidl\b:IDL:i;
   $name =~ s:\bapi\b:API:i;
   return $name;
}

#external package : auth

# auth defines
$auth_inc = "$main_dir/wkn/cgi-bin/auth";
$auth_lib = "auth-lib.pl";
$auth_subpath = "";
$auth_cgi_wpath = "$base_cgi_wpath/auth";
$edit = "$auth_cgi_wpath/edit.cgi?file=";

$opened_icon = "fminus.gif";
$opened_icon_text = '[-]';
$closed_icon = "fplus.gif";
$closed_icon_text = '[+]';
$dir_icon = "dotgreen.gif";
$dir_icon_text = '[+]';
$file_icon = "dotgreen.gif";
$file_icon_text = '[.]';

#sub code_filter
#{
#   my($type, $code) = @_;
#   
#   use FileHandle;
#   use IPC::Open2;
#   return $code unless(defined($type) and $type ne "");
#   my($args) = "-H -l $type";
#   
#   undef $ENV{PATH};
#   my $pid = open2( \*Reader, \*Writer, "$wkn::define::code2html $args");
#   Writer->autoflush();
#   print Writer $code;
#   close(Writer);
#   
#   my $savesep = $/;
#   undef $/;
#   my $out = <Reader>;
#   close(Reader);
#   $/ = $savesep;
#   
#   # if code2html hade problems, just return the code
#   waitpid($pid, 0);
#   return ($? >> 8) ? $code : $out;
#}

sub code_filter
{
   
   my($lang_type,$code) = @_;
   
   return $code unless(defined($lang_type) and $lang_type ne "");
   require 'code2html.pl';
   
   my $params = { "input" => $code, 
   "noheader" => 1,
   "dont_print_output" => 1, 
   "outfile" => "-",
   "outputformat" => "html-nobg",
   "linenumbers" => "none",
   "langmode" => $lang_type
   };
   
   return &code2html::main( $params );
}

$index_title = "Open I-DEAS";
$index_header = 
'<table border=0 width="100%">
 <tr>
    <td align=left valign=top>
             <IMG SRC="../pictures/oi.gif" WIDTH=222 HEIGHT=42 alt="OpenIdeas">
          </td>
          <td align=right valign=top>
             <A href="mailto:Alan.Heuker@sdrc.com">
             <IMG SRC="../pictures/fearlessLeader.gif" WIDTH=201 HEIGHT=35 border="0" alt="Alan Heuker"></A>
          </td>
        </tr>
      </table>';

$index_footer = '
[<a href="../wkn/cgi-bin/wkn/search.cgi">Search</a>]   
[<a href="../wkn/cgi-bin/auth/user_access.cgi">User Accounts</a>]   
[<a href="mailto:Don.Mahurin@sdrc.com" >Webmaster</a>]
[<a href="../disclaimer.html" >disclaimer</a>]';
