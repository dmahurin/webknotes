#!/usr/bin/perl
my $runpath;
if( $0 =~ m:/[^/]*$: ) { $runpath=$`; push @INC, $runpath }
require 'view_define.pl';
require 'view_lib.pl';
use CGI qw(:standard);

my($my_main) = view::localize_sub(\&main);
&$my_main;

sub main
{
my $go = param("go");
my $path = param("path");
# set local view
view::set_view_mode("layout", param("layout"));
view::set_view_mode("sublayout", param("sublayout"));
view::set_view_mode("theme", param("theme"));

# get view mode params ( falls back to users settings )
$theme = view::get_view_mode("theme");
$layout = view::get_view_mode("layout");
$sublayout = view::get_view_mode("sublayout");

view::persist_view_mode();

view::content_header();
if($go)
{
  view::browse_show_page($path);
  exit(0);
   }
print "<html><head>
<TITLE>Layout and Theme</TITLE>
<base target=\"_top\">
</HEAD><BODY>
<H1>Layout and Theme</H1>";

my(@themes);
if(opendir(CDIR, $view::define::themes_dir))
{
   while(defined($file = readdir(CDIR)))
   {
      if($file =~ m:\.css$:)
      {
         push(@themes, $`);
      }
   }
   closedir(CDIR);
}
my(@layouts);
if(opendir(CDIR, $runpath))
{
   while(defined($file = readdir(CDIR)))
   {
       if($file =~ m:^browse_([^\.]+)\.pl$:)
       {
           push(@layouts, $1);
       }
   }
   closedir(CDIR);
}
   
print "<FORM METHOD=GET ACTION=\"browse.cgi\">\n";
print "<INPUT TYPE=\"hidden\" NAME=\"path\" value=\"$path\">\n";
print "<INPUT TYPE=\"hidden\" NAME=\"save\" value=\"yes\">\n";
print "Theme: <select name=\"theme\">";
for $sel ('', @themes)
{
   my ($seltext) = ($sel eq '') ? "default":$sel;
   my $selected = ($sel eq $theme) ? "selected" : "";
   print "<option value=\"$sel\" $selected>$seltext\n";
   print "</option>\n";
}                 
print "</select> ( Not used for edit layout )<br>\n";

print "Layout: <select name=\"layout\">\n";
my $sel;
for $sel ('', @layouts)
{
   my ($seltext) = ($sel eq '') ? "default":$sel;
   my ($selected) = $selected = ($sel eq $layout) ? "selected" : "";
   print "<option value=\"$sel\" $selected>$seltext\n";
   print "</option>\n";
}
print "</select><br>\n";
print "Sub Layout: <select name=\"sublayout\">";
for $sel ('', @layouts)
{
   my ($seltext) = ($sel eq '') ? "default":$sel;
   my ($selected) = $selected = ($sel eq $sublayout) ? "selected" : "";
   print "<option value=\"$sel\" $selected>$seltext\n";
   print "</option>\n";
}                 
print "</select> ( For frame and list layout modes )<br>\n";

print "<INPUT TYPE=\"SUBMIT\" VALUE=\"Change\">\n";

#my $return_link = view::get_cgi_prefix();
#$return_link .=  &view::url_encode_path($path);

#print "<p><a href=\"$return_link\">Return to browsing</a>";
print "</body></html>\n";

}
