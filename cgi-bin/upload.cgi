#!/usr/bin/perl

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'wkn_define.pl';
require 'wkn_lib.pl';
push(@INC, $wkn::define::auth_inc);
require 'auth_lib.pl';

use CGI qw/:standard/;

#my $query = new CGI;

print header,
    start_html('File Upload'),
h1('file upload');

my $notes_path = param("notes_path");
my($user) = auth::get_user();
$notes_path =~ s:/$::;
print "notes_path: $notes_path\n";
if( ! auth::check_file_auth( $user, auth::get_user_info($user),
  'u', $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}
$notes_path = wkn::path_check($notes_path);

unless(defined(param('upload')))
{
   print_form();
}
else
{
   wkn_save_file($notes_path);
}
print end_html;


sub print_form {
   print start_multipart_form(),
       filefield(-name=>'upload',-size=>60),br,
       hidden(-name=>'notes_path',-value=>$notes_path),br,
       submit(-label=>'Upload File'),
       end_form;
}

sub wkn_save_file
{
   my($notes_path) = @_;
   

   my $length;
   my $file = param('upload');
   if (!$file) 
   {
      print "No file uploaded.";
      return;
   }
   my $fullpath = array_to_path( $wkn::define::notes_dir, $notes_path, $file);
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
   for $path (@paths)
   {
      next unless(defined($path) and $path ne "");
      $path = '' if($path eq '/');
      push(@pathout, $path);
   }
   return join('/', @pathout);
}
