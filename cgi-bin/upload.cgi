#!/usr/bin/perl
use strict;

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'wkn_define.pl';
require 'wkn_lib.pl';
push(@INC, $wkn::define::auth_inc);
require 'auth_lib.pl';
require 'filedb_lib.pl';

wkn::init();
auth::init();

use CGI qw/:standard/;

#my $query = new CGI;

print header,
    start_html('File Upload'),
h1('file upload');

my $upload_path = param("path");
my($user) = auth::get_user();
$upload_path =~ s:/$::;
print "Upload path: $upload_path\n";
if( ! auth::check_file_auth( $user, auth::get_user_info($user),
  'u', $upload_path ) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}
$upload_path = auth::path_check($upload_path);

unless(defined(param('upload')))
{
   print_form();
}
else
{
   wkn_save_file($upload_path);
}
print end_html;


sub print_form {
   print start_multipart_form(),
       filefield(-name=>'upload',-size=>60),br,
       hidden(-name=>'path',-value=>$upload_path),br,
       submit(-label=>'Upload File'),
       end_form;
}

sub wkn_save_file
{
   my($upload_path) = @_;
   

   my $length;
   my $file = param('upload');
   if (!$file) 
   {
      print "No file uploaded.";
      return;
   }
   my $fullpath = array_to_path( $filedb::define::doc_dir, $upload_path, $file);
   print "fullpath='$fullpath'\n";
   print h2('File name'),$file;
   print h2('File MIME type'),uploadInfo($file)->{'Content-Type'};
   {
      local $/ = undef;
      if(open(OUT, ">$fullpath"))
      {
         print OUT <$file>;
         close(OUT);
      }
   }
}

sub array_to_path
{
   my (@paths) = @_;
   my @pathout;
   my $path;
   for $path (@paths)
   {
      next unless(defined($path) and $path ne "");
      $path = '' if($path eq '/');
      push(@pathout, $path);
   }
   return join('/', @pathout);
}
