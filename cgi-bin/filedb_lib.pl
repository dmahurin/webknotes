#!/usr/bin/perl
use strict;

# note/file/directory access

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

# initially this lib is just collecting the file/directory functions.
# later a database could be plugged in

require 'filedb_define.pl';

package filedb;

# return dir that file is in
sub path_dir
{
   my($path) = @_;
   return $path if( -d "$filedb::define::doc_dir/$path");

   if($path =~ m:/[^/]+$:)
   {
      return ( -d $` ) ? $` : ();
   }
   return "";
}

# return default file in directory
sub path_file
{
	my($path) = @_;

	my($dir) = "$filedb::define::doc_dir/$path";
	return $path if( -f $dir);
	return () unless ( -d $dir);

	return "$path/index.html" if ( -f "$dir/index.html" );
	return "$path/index.htm" if ( -f "$dir/index.htm" );
	return "$path/FrontPage" if ( -f "$dir/FrontPage" );
	return "$path/FrontPage.wiki" if ( -f "$dir/FrontPage.wiki" );
	return "$path/HomePage" if ( -f "$dir/HomePage" );
	return "$path/README.html" if ( -f "$dir/README.html" );
	return "$path/README" if ( -f "$dir/README" );
	return "$path/README.txt" if ( -f "$dir/README.txt" );
        return ();
}

sub get_full_path
{
   my($path) = @_;
   my($full) = $filedb::define::doc_dir;
   $full .= "/$path" if ($path ne "");

   return $full;
}

sub get_file
{
   my($file) = @_;

   open(MYFILE, "$filedb::define::doc_dir/$file") || return ();
   local $/ = undef;
   my($text) = <MYFILE>;
   close(MYFILE);
   return($text);
}

