#!/usr/bin/perl
use strict;
# WebKNotes index generator

# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

print "Content-type: text/html\n\n";

$|=1;
if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'wkn_define.pl';
require 'wkn_lib.pl';
require 'css_tables.pl';


my $files_base;
if(defined($wkn::define::files_ftp))
{ $files_base = $wkn::define::files_ftp }
elsif(defined($wkn::define::files_wpath))
{ $files_base = $wkn::define::files_wpath } 

   

my @cgi_args;
my $theme;
my $layout;
if(defined($ENV{QUERY_STRING}))
{
   my($arg);
   foreach $arg (split(/\&/, $ENV{QUERY_STRING}))
   {
      if($arg =~ m:^theme=:)
      {
         $wkn::view_mode{"theme"} = $';
         next;
      }
      elsif($arg =~ m:^layout=:)
      {
         $wkn::view_mode{"layout"} = $';
         next;
      }
      $arg = &wkn::path_check(wkn::url_unencode_path($arg));
      push(@cgi_args, $arg) if ($arg);
   }

}
elsif(@ARGV)
{
  @cgi_args = @ARGV;
}

my $style = wkn::get_style_header_string();

print <<"END";
<HTML>
<head>
<title>$wkn::define::index_title</title>
$style
</head>
<BODY class="topics-back">
END


if (defined($wkn::define::index_header))
{
   print "<table border=0 cellpadding=8><tr><td class=\"topics_header\">\n",
   $wkn::define::index_header ,
   "</td></tr></table>\n";
   
}

print "<p><table cellspacing=0 border=0 cellpadding=8 >";
my ($topic_row, $topic, $colspan);
my $max_count = 0;
my $count = 0;
my $span = "";
print "<tr>\n";
my $arg;
my $columns;
foreach $arg (@cgi_args ? @cgi_args : "/")
{
   if($arg =~ m:^columns=:)
   {
      $columns=$';
      next;
   }
   if($arg =~ m:^(rowspan|colspan):)
   {
      $span = $span . " " . $arg;
      next;
   }
   if($arg eq "" and $count != 0)
   {
      print "</tr><tr>";
      $count = 0;
      next;
   }
   if(defined($columns) and $count >= $columns)
   {
      print "</tr><tr>";
      $count = 0;
   }
   $topic = $arg;
   print "<td${span}>\n";
   print css_tables::table_begin("topic-table") . "\n";
   
   print css_tables::trtd_begin("topic-text") . "\n";
   
   print "<table><tr>";
   my $icon = wkn::get_icon($topic);
      if( defined($icon) )
      {
         print "<td>";
          my $etopic = wkn::url_encode_path($topic);
          print "<a href=\"" ,
             &wkn::get_cgi_prefix() , 
             $etopic . "\">\n";
          print "<img src=\"$icon\" alt=\"$icon\"></a>\n";
          print "</td>";
      }
      print "<td>";
      &wkn::print_dir_file($topic);
      print "</td></tr></table>";
      print css_tables::trtd_end() . "\n";
      
      print css_tables::trtd_begin("topic-listing") . "\n";
      &wkn::list_html($topic);
      print css_tables::trtd_end() . "\n";
      
      print css_tables::table_end() . "\n";
      print "</td>\n";
      $count++;
   
   $span = "";
}
print "</tr>\n";

print "</table>\n";

if (defined ($wkn::define::index_footer))
{
print "<table border=0 cellpadding=8><tr><td class=\"topics-footer\">\n",
   "$wkn::define::index_footer\n",
   "</td></tr></table>\n";
}

#print "<a href=\"mailto:dmahurin\@users.sourceforge.net\" >dmahurin\@users.sourceforge.net</a>\n";
print "</BODY>\n";
print "</HTML>\n";

