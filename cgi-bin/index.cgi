#!/usr/bin/perl
use strict;
# The WebKNotes system is Copyright 1996-2002 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'view_lib.pl';

my($my_main) = view::localize_sub(\&main);
&$my_main;
#&main;

sub main
{
   view::content_header();
  my $path = $ENV{REQUEST_URI};
  if($path =~ m&^$filedb::define::doc_wpath/&)
  {
     $path = $';
  }
  else
  {
     print "No authorization\n";
     exit(0);
  }

  $path = auth::path_check( view::url_unencode_path($path));

   view::browse_show_page($path);
}
