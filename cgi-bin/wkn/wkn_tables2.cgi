#!/usr/bin/perl
use strict;
# main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'COPYING'
# dmahurin@users.sourceforge.net

print "Content-type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'wkn_define.pl';
require 'wkn_lib.pl';
require 'wkn_attr.pl';

local $wkn::define::mode = "tables2";

my $notes_path_encoded = $ENV{QUERY_STRING};
my($notes_path) = &wkn::path_check(&wkn::url_unencode_path($notes_path_encoded));
exit(0) unless(defined($notes_path));

print <<"_END";
<HTML>
<BODY $wkn::attr::body>
_END

print_main_topic_table($notes_path);

exit unless
opendir(DIR, "$wkn::define::notes_dir/$notes_path");
my $file;
while($file = readdir(DIR))
{
   next if( $file =~ m:^\.: );
   next if( $file =~ m:^README(\.html)?:);
   next if( $file eq "index.html");

   if( $file =~ m:^([^/]*)$: ) # untaint dir entry
   {
      $file = $1;
   }
   else
   {
      print "hey, /'s ? not ggod.\n";
      exit;
   }
   $file = "$notes_path/$file" if($notes_path);
   print_topic_table( "$file");	
}
closedir(DIR);

print "<table border=0 cellpadding=8>\n";
print "<tr><td $wkn::attr::td_highlight>\n";
wkn::actions3($notes_path);
print "</td></tr>\n";
print "</table><br>\n";

print "</BODY>\n";
print "</HTML>\n";

sub print_main_topic_table
{
   my($notes_path) = @_;
   $notes_path =~ m:([^/]*)$:;
   my $notes_name = $1;

   print "<table border=0 cellpadding=8>\n";
   print "<tr><td $wkn::attr::td_title>\n";
   print "<b><font $wkn::attr::font_table_title>$notes_name</font></b><br>\n";
   print "</td></tr>\n";
   print "<tr><td $wkn::attr::td_highlight>\n";
   &wkn::print_modification($notes_path);
   print "</td></tr>\n";
   print "<tr><td $wkn::attr::td_description>\n";
   &wkn::print_dir_file($notes_path);
   print "</td></tr>\n";
   print "<tr><td $wkn::attr::td_highlight>\n";
   wkn::actions2($notes_path);
   print "</td></tr>\n";
   print "</table><br>\n";
}

sub print_topic_table
{
   my($notes_path) = @_;
   $notes_path =~ m:([^/]*)$:;
   my $notes_name = $1;

   print "<table border=0 cellpadding=8>\n";
   print "<tr><td $wkn::attr::td_list>\n";
   #	print "<b>$notes_name</b><br>\n";
   print "<br>\n" if wkn::print_link_html($notes_path);
   &wkn::print_modification($notes_path);
   print "</td></tr>\n";
   print "<tr><td $wkn::attr::td_description>\n";
   &wkn::print_dir_file($notes_path);
   print "</td></tr>\n";
   print "<tr><td $wkn::attr::td_list>\n";
   wkn::actions2($notes_path);
   print "</td></tr>\n";
   print "<tr><td $wkn::attr::td_list>\n";
   &wkn::list_html($notes_path);
   print "</td></tr>\n";
   print "</table><br>\n";
}

