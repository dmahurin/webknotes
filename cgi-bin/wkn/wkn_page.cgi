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
require 'wkn_attr.pl';


print <<"_END";
<HTML>
<BODY >
<head>
<title>$wkn::define::index_title</title>
<head>
_END

my $files_base;
if(defined($wkn::define::files_ftp))
{ $files_base = $wkn::define::files_ftp }
elsif(defined($wkn::define::files_wpath))
{ $files_base = $wkn::define::files_wpath } 

print &wkn::translate_html($wkn::define::index_header)
   if (defined($wkn::define::index_header));

my @cgi_args;
if(defined($ENV{QUERY_STRING}))
{
   @cgi_args = unencode_paths(split(/\&/, $ENV{QUERY_STRING}));
}
elsif(@ARGV)
{
  @cgi_args = @ARGV;
}

print "<p><table cellspacing=0 border=0 cellpadding=8 $wkn::attr::body>";
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
   print "<table border=0 cellpadding=8><tr><td $wkn::attr::td_description>\n";
      my $icon = wkn::get_icon($topic);
      if( defined($icon) )
      {
          my $etopic = wkn::url_encode_path($topic);
          print "<a href=\"" ,
             &wkn::mode_to_scriptprefix($wkn::define::page_mode) , 
             $etopic . "\">\n";
          print "<img src=\"$icon\" alt=\"$icon\"></a>\n";
          print "</td><td $wkn::attr::td_description>";
          $colspan = "colspan=2"; 
      }
      else
      {
          $colspan = "";
      } 
      &wkn::print_dir_file($topic);
      print "</td></tr><tr><td $colspan $wkn::attr::td_list>\n";
      &wkn::list_html($topic);
      print "</td></tr></table>\n";
      print "</td>\n";
      $count++;
   
   $span = "";
}
print "</tr>\n";

print "</table>\n";
print &wkn::translate_html("$wkn::define::index_footer\n") if (defined ($wkn::define::index_footer));
#print "<a href=\"mailto:dmahurin\@users.sourceforge.net\" >dmahurin\@users.sourceforge.net</a>\n";
print "</BODY>\n";
print "</HTML>\n";

sub unencode_paths
{
   my(@out) = ();
   foreach (@_)
   {
      
      push(@out,&wkn::path_check(wkn::url_unencode_path($_)));
   }
   return @out;
}
