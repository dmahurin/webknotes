#!/usr/bin/perl -T
use strict;

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'view_define.pl';
require 'view_lib.pl';
require 'auth_lib.pl';
require 'filedb_lib.pl';

my($my_main) = auth::localize_sub(\&main);
&$my_main;

sub main
{

use CGI qw/:standard/;

#my $query = new CGI;

print header,
    start_html('File Upload'),
h1('file upload');

my $upload_path = param("path");
my($user) = auth::get_user();
$upload_path =~ s:/$::;
print "Upload path: $upload_path\n";
if( ! auth::check_current_user_file_auth( 'u', $upload_path ))
{
   print "You are not authorized to access this path.\n";
   exit(0);
}
$upload_path = auth::path_check($upload_path);

unless(defined(param('upload')))
{
   print_form($upload_path);
}
else
{
   wkn_save_file($upload_path,param('upload'));
}
print end_html;


sub print_form {
   my($upload_path) = @_;
   print start_multipart_form(),
       filefield(-name=>'upload',-size=>60),br,
       hidden(-name=>'path',-value=>$upload_path),br,
       submit(-label=>'Upload File'),
       end_form;
}

sub wkn_save_file
{
   my($upload_path, $file) = @_;
   
   my $filename;
   if($file =~ m:([^/\\]+)$:) { $filename = $1; }
   else { return 0 }
   if (!$file) 
   {
      print "No file uploaded.";
      return;
   }
   print h2('File name'),$file;
   print h2('File MIME type'),uploadInfo($file)->{'Content-Type'};
   {
      local $/ = undef;
# TODO:: below should not be used with large files
      filedb::put_file($upload_path, $file, <$file>);
   }
}

}
