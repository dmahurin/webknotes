#!/usr/bin/perl
my $runpath;
if( $0 =~ m:/[^/]*$: ) { $runpath=$`; push @INC, $runpath }
require 'wkn_define.pl';
require 'wkn_lib.pl';
use CGI qw(:standard);

my $layout = param("layout"); 
my $theme = param("theme");
my $path = param("path");

my $saved = 0;

#auto persistent save layout and theme settings for user
my $username = auth::get_user();
if( defined($username) )
{
   my($user_info) = auth::get_current_user_info();
   if(defined($theme) && defined($layout) &&
      ($user_info->{"Theme"} ne $theme ||
      $user_info->{"Layout"} ne $layout)
   )
   {
      $user_info->{"Layout"} = $layout;
      $user_info->{"Theme"} = $theme;
      if(&auth::write_user_info(auth::check_user_name($username), $user_info))
      {
         $saved = 1;
      }
      else
      {
         print "Could not modify user information?\n";
      }
   }
   else
   {
   	$layout = $user_info->{"Layout"};
        $theme = $user_info->{"Theme"};
        $saved = 1;
   }
}   
$theme = "" unless(defined($theme));
$layout = "" unless(defined($theme));

print "Content-Type: text/html\n\n";
print "<html><head>
<TITLE>Layout and Theme</TITLE>
<base target=\"_top\">
</HEAD><BODY>
<H1>Layout and Theme</H1>
<body>";

my(@themes);
if(opendir(CDIR, $wkn::define::themes_dir))
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
       if($file =~ m:^browse_([^\.]+)\.cgi$:)
       {
           push(@layouts, $1);
       }
   }
   closedir(CDIR);
}
   
print "<FORM METHOD=POST ACTION=\"layout_theme.cgi\">\n";
print "<INPUT TYPE=\"hidden\" NAME=\"path\" value=\"$path\">\n";
print "Layout: <select name=\"layout\">\n";
my $sel;
for $sel ('', @layouts)
{
   my ($seltext) = ($sel eq '') ? "default":$sel;
   my ($selected) = $selected = ($sel eq $layout) ? "selected" : "";
   print "<option value=\"$sel\" $selected>$seltext\n";
   print "</option>\n";
}
print "</select><br>Theme: <select name=\"theme\">";
for $sel ('', @themes)
{
   my ($seltext) = ($sel eq '') ? "default":$sel;
   my $selected = ($sel eq $theme) ? "selected" : "";
   print "<option value=\"$sel\" $selected>$seltext\n";
   print "</option>\n";
}                 
print "</select><br>";

print "<INPUT TYPE=\"SUBMIT\" VALUE=\"Change\">\n";

$layout = $wkn::define::default_layout unless($layout);
my $return_link = "browse_$layout.cgi?";
$return_link .= "theme=$theme&" 
if((!$saved) && $theme &&
($theme ne $wkn::define::default_theme));
$return_link .= $path;

print "<p><a href=\"$return_link\">Return to browsing</a>";
print "</body></html>\n";
