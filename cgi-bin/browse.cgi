#!/usr/bin/perl -T
use strict;
# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'view_lib.pl';

my($my_main) = view::localize_sub(\&main);
&$my_main;

sub main
{

view::content_header();
my(@paths) = view::get_args();

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

my $save = view::get_view_mode("save");
view::unset_view_mode("save");
view::persist_view_mode() if($save);

view::browse_show_page(@paths);
}
