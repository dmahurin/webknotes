#!/usr/bin/perl
use strict;

# plain version of the main WebKNotest script
# formats a directory $ARGV[1] in a format like with dons_notes
# different file extensions determine how a file is treated

# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

print "Content-type: text/html

<HTML>
<BODY>
";

$|=1;

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'wkn_define.pl';
require 'wkn_lib.pl';

local($wkn::define::mode) = "plain";

my $notes_path_encoded = $ENV{QUERY_STRING};
my($notes_path) = &wkn::path_check(&wkn::url_unencode_path($notes_path_encoded));
exit(0) unless(defined($notes_path));

$notes_path =~ m:([^/]*)$:;
my($notes_name) = $1;

my($user) = auth::get_user();
unless (auth::check_file_auth( $user, 'r', $wkn::define::auth_subpath, $notes_path) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}
 

my($real_path) = "$wkn::define::notes_dir/${notes_path}";
#print "<h1>";
#if ( &wkn::print_file("${notes_path}/.type") )
#{
#	print " : ";
#}

#print "${notes_path}</h1>\n<hr size=4\n";
print <<"_EOT";
<title>${notes_path}</title>
_EOT

#if ( -f $real_path )
#{
#	&wkn::print_dir_file($notes_path);
#
#	print "<br>";
#}
#elsif ( -d "${real_path}" )
{
		
   my $dir_file = &wkn::print_dir_file( $notes_path );
   print "<hr>\n";
   print "<b>$notes_name</b><br>\n";
   wkn::print_modification($notes_path);
   print "<hr>\n";
   &wkn::log($notes_path);
   if(&wkn::list_files_html($notes_path))
   {
      print "<hr>\n";
   }
   if($dir_file ne "index.html")
   {
      if(&wkn::list_dirs_html($notes_path))
      {
         print "<hr>";
      }
   }
   &wkn::actions2($notes_path);
   print "<hr>\n";
   &wkn::actions3($notes_path);
}
#else # not dir or file
#{
#	print "Notes path '${notes_path}' is not accessible<br>";
#}

print "</BODY>\n";
print "</HTML>\n";
