#!/usr/bin/perl
use strict;

# note/file/directory access

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

# initially this lib is just collecting the file/directory functions.
# later a database could be plugged in

require 'filedb_define.pl';
use Fcntl ':flock'; # import LOCK_* constants
no strict 'subs'; # for lock constants

package filedb;

use Cwd;
# return dir that file is in
sub path_dir
{
   my($path) = @_;
   return $path if( $path eq "" or -d "$filedb::define::doc_dir/$path");

   if($path =~ m:/[^/]+$:)
   {
      $path = $`;
      return ( $path eq "" or -d "$filedb::define::doc_dir/$path") ? $path : ();
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
   return "$path/README.htxt" if ( -f "$dir/README.htxt" );
   return "$path/index.htxt" if ( -f "$dir/index.htxt" );
   return "$path/README" if ( -f "$dir/README" );
   return "$path/README.txt" if ( -f "$dir/README.txt" );
   return ();
}
sub get_mtime
{
   my($path) = @_;
   my $dir_file = path_file($path);
   unless($dir_file) { $dir_file = $path }
   my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
      $atime,$mtime,$ctime,$blksize,$blocks)
      = stat(get_full_path($dir_file));
   return $mtime;
}

sub default_file
{  
   my($path) = @_;
   my($dir) = get_full_path($path);
   if( -f $dir)
   {
       $dir =~ s:.*/::;
       return $dir;
   }
   return () unless ( -d $dir);

   for my $index ( "index.html", "index.htm", "FrontPage", "FrontPage.wiki", "HomePage", "README.html", "README", "README.txt", "README.htxt", "index.htxt" )
   {
      return $index if (-f "$dir/$index");
   }
   return ();
}

sub default_type
{  
   my($path) = @_;
   my($dir) = get_full_path($path);

   return "html" if ( -f "$dir/index.html" );
   return "html" if ( -f "$dir/index.htm" );
   return "wiki" if ( -f "$dir/FrontPage" );
   return "wiki" if ( -f "$dir/FrontPage.wiki" );
   return "wiki" if ( -f "$dir/HomePage" );
   return "html" if ( -f "$dir/README.html" );
   return "htxtdir" if ( -f "$dir/README.htxt" );
   return "htxt" if ( -f "$dir/index.htxt" );
   return "txt" if ( -f "$dir/README" );
   return "txt" if ( -f "$dir/README.txt" );
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
   my($path, $name) = @_;
   my($full) = get_full_path($path, $name);

   open(MYFILE, $full) || return ();
   local $/ = undef;
   my($text) = <MYFILE>;
   close(MYFILE);
   return($text);
}

sub append_file
{
   my($path, $name, $contents) = @_;

   my($full) = get_full_path($path, $name);
   if(open(NFILE, ">>$full" ))
   {
      flock(NFILE,LOCK_EX);
      seek(NFILE, 0, 2); # if someone appended during lock
      print NFILE $contents;
      flock(NFILE,LOCK_UN);
      close(NFILE);
      cvs_command(get_full_path($path), "commit", $name) if($filedb::define::use_cvs);
      return 1;
   }
}

sub put_file
{
   my($path, $name, $contents) = @_;

   my($full) = get_full_path($path, $name);
   my($exists) = ( -f $full);
   if(open(NFILE, ">$full" ))
   {
      flock(NFILE,LOCK_EX);
      print NFILE $contents;
      flock(NFILE,LOCK_UN);
      close(NFILE);
      chmod 0644, $full;
      if($filedb::define::use_cvs and -d get_full_path($path, "CVS"))
      { 
         cvs_command(get_full_path($path), $exists ? "commit" : "add", $name);
      }
      return 1;
   }
   return 0;
}

sub make_dir
{
   my($path, $name) = @_;
   my($full) = get_full_path($path, $name);

   if(!mkdir($full, 0755 ))
   {
      return 0;
   }
   cvs_command(get_full_path($path), "add", $name) if($filedb::define::use_cvs and -d get_full_path($path, "CVS"));
   return 1;
}

sub remove_dir
{
   my($path, $name) = @_;
   my $full = get_full_path($path, $name);
   my $rtn;
   unless(defined($name))
   {
      $path =~ m:/?([^/]+)$:;
      $path = $`;
      $name = $1;
   }
   if($filedb::define::use_cvs and -d get_full_path($path, "CVS"))
   {
     my $cdir = get_full_path($path);
     $rtn = cvs_command($cdir, "remove", $name);
     cvs_command($cdir, "update",$name);
   }
   else
   {
     $rtn = rmdir($full);
   }
   return $rtn;
}  

sub remove_file
{
   my($path, $name) = @_;
   my $full = get_full_path($path, $name);
   my $rtn = unlink($full);
   if($filedb::define::use_cvs)
   {
     unless(defined($name))
     {
        $path =~ m:/?([^/]+)$:;
        $path = $`;
        $name = $1;
     }
     cvs_command(get_full_path($path), "remove", $name)
     if( -d get_full_path($path, "CVS"));
   }
   return $rtn;
}

sub is_dir
{
   return( -d get_full_path(@_));
}

sub is_file
{
   return( -f get_full_path(@_));
}

sub get_hidden_data
{
   my($path, $name) = @_;
   my($file) = get_full_path($path, ".$name");
  
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
   my($file) = get_full_path($path, ".$name");
   unless(defined($value))
   {
      return 1 unless( -f $file);
      return unlink($file); 
   }
  
   if ( open (FILE, ">$file"))
   {
      flock(FILE, LOCK_EX);
      print FILE $value;
      flock(FILE, LOCK_UN);
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
   my($file) = get_full_path($path, ".$name");
   return 1 unless(defined($value));
  
   if ( open (FILE, ">>$file"))
   {
      flock(FILE, LOCK_EX);
      seek(FILE, 0, 2); # if someone appended during lock
      print FILE $value;
      flock(FILE, LOCK_UN);
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
         next if($file eq "CVS" and $filedb::define::use_cvs);
         if( $file =~ m:^([^/]*)$: ) # untaint dir entry
         { $file = $1; } else { print "bogus entry\n"; next }

         push(@files, $file);
      }
      closedir(DIR);
      return @files;
   }
   return ();
}

sub mysystem
{
   my(@args) = @_;
   print  STDERR join(':', "MYSYS", @args) . "\n";
   system(@args);
}

sub cvs_command
{
   my($dir, $command, $file, $comment) = @_;
   print STDERR "cvs: $dir, $command, $file, $comment\n";
   my($dirsav) = getcwd();
   return 0 unless ( -d "$dir/CVS");
   my ($rtn);
   chdir($dir);
   open (OUTSAV, ">&STDOUT");
   open (STDOUT, ">&STDERR");
   if($command eq "update")
   {
      print STDERR `pwd`;
      system("cvs", "update", "-P", $file);
      $rtn =  ! ($? >> 8);
   }
   else
   {
      system("cvs", $command, $file) unless($command eq "commit");
      $rtn =  ! ($? >> 8);
      system("cvs", "commit", "-m", "$comment", $file);
   }
   open (STDOUT, ">&OUTSAV");
   chdir($dirsav);
   return $rtn;
}

# join paths with '/' ignoring '/' and empty paths
sub join_paths
{
   my (@paths) = @_;
   my(@out);
   while(@paths)
   {
      next unless(defined(my $path=shift(@paths)));
      push(@out, $path) if(defined($path) and $path ne "" and $path ne "/");
   }
   return join('/', @out);
}

sub get_private_data
{
   my($path) = @_;
   my($filepath) = join_paths($filedb::define::private_dir,$path);
   open(PFILE, $filepath) || return ();
   local $/ = undef;
   my($data) = <PFILE>;
   close(PFILE);
   return $data;
}

sub private_data_exists
{
   my($path) = @_;
   return( -f join_paths($filedb::define::private_dir,$path));
}

sub set_private_data
{
   my($path, $value) = @_;
   my($filepath) = join_paths($filedb::define::private_dir,$path);

   return 0 unless open( PFILE, ">$filepath");
   flock(PFILE,LOCK_EX);
   print PFILE $value;
   flock(PFILE,LOCK_UN);
   close(PFILE);
   return 1;
}

sub make_private_dir
{
   my($path) = @_;
   my($filepath) = join_paths($filedb::define::private_dir,$path);
   return mkdir($filepath, 0700);
}
