#!/usr/bin/perl
use strict;
# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'wkn_lib.pl';

wkn::init();

wkn::content_header();
my(@paths) = wkn::get_args();

my $path;
for $path (@paths)
{
   $path = auth::path_check($path);
   unless(defined($path))
{
       print "Bad path\n";
       exit(1);
}
}

my $save = wkn::get_view_mode("save");
wkn::unset_view_mode("save");
wkn::persist_view_mode() if($save);

wkn::browse_show_page(@paths);
