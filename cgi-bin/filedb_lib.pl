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

sub get_default_file
{  
   my($path) = @_;
   my($dir) = get_full_path($path);
   return () if( -f $dir);
   return () unless ( -d $dir);

   for my $index ( "index.html", "index.htm", "FrontPage", "FrontPage.wiki", "HomePage", "README.html", "README", "README.txt" )
   {
      return $index if (-f "$dir/$index");
   }
   return ();
}

sub get_full_path
{
   my($path, $file) = @_;
   my($full) = $filedb::define::doc_dir;
   $full .= "/$path" if ($path ne "" and $path ne "/");
   $full .= "/$file" if (defined($file) and $file ne "");

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

sub make_file
{
   my($notes_filepath, $contents) = @_;

   if(open(NFILE, "> $filedb::define::doc_dir/${notes_filepath}" ))
   {
      print NFILE $contents;
      close(NFILE);
      chmod 0644,"$filedb::define::doc_dir/$notes_filepath";
      return 1;
   }
}

sub make_dir
{
   my($path, $name) = @_;
   my($full) = get_full_path($path, $name);

   if(!mkdir($full, 0755 ))
   {
      return 0;
   }
   return 1;
}

sub remove_dir
{
   my($path, $name) = @_;
   my $full = get_full_path($path, $name);
   return rmdir($full);
}  

sub remove_file
{
   my($path, $name) = @_;
   my $full = get_full_path($path, $name);
   return unlink($full);
}

sub is_dir
{
   my($path) = @_;
   return( -d "$filedb::define::doc_dir/$path");
}

sub is_file
{
   my($path) = @_;
   return( -f "$filedb::define::doc_dir/$path");
}

sub get_hidden_data
{
   my($path, $name) = @_;
   my($file) = get_full_path($path, $name);
  
   if ( -f $file and open (FILE, $file))
   {
      my($value) = <FILE>;
      chomp($value);
      close(FILE);
      return $value;
   }
   return ();
}

sub set_hidden_data
{
   my($path, $name, $value) = @_;
   my($file) = get_full_path($path, $name);
   unless(defined($value))
   {
      return 1 unless( -f $file);
      return unlink($file); 
   }
  
   if ( open (FILE, ">$file"))
   {
      print FILE $value;
      close(FILE);
      return 1;
   }
   return 0;
}

sub unset_all_hidden_data
{
   my($path) = @_;
   my($full) = get_full_path($path);

   if(opendir(DIR, $full))
   {
      my($success) = 1;
      my $file;
      while(defined($file = readdir(DIR)))
      {
          next if($file eq '.' or $file eq '..');
          next unless($file =~ m:^\.:);
          unless(unlink($full . '/' . $file))
          {
              $success = 0;
              last;
          }
      }
      closedir(DIR);
      return $success;
   } 
   return 0;
}

sub append_hidden_data
{
   my($path, $name, $value) = @_;
   my($file) = get_full_path($path, $name);
   return 1 unless(defined($value));
  
   if ( open (FILE, ">>$file"))
   {
      print FILE $value;
      close(FILE);
      return 1;
   }
   return 0;
}

# get a directory list, ignoring hidden files
sub get_directory_list
{
   my($path) = @_;
   my($full) = get_full_path($path);
   my(@files);
   if(opendir(DIR, $full))
   {
      while(my $file = readdir(DIR))
      {
         next if($file =~ m:^\.:);
         push(@files, $file);
      }
      closedir(DIR);
      return @files;
   }
   return ();
}
