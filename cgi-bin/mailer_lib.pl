#!/usr/bin/perl
use strict;

require "auth_lib.pl";
require "view_lib.pl"; # need to get rid of this dependency
require "filedb_lib.pl";
require "mailer_define.pl";

package mailer;

sub mail_subscribers
{
   my($parent_path, $file) = @_;
   my($dfile) = filedb::default_file($parent_path);
   my($notes_path) = filedb::join_paths ($parent_path, $file);
   
   # notes path without default file
   my($notes_path_short) = ($file eq $dfile)? $parent_path : $notes_path;

   return 0 unless(defined($mailer::define::admin_email));
   my @splitpath = split( /\// , $parent_path );

   my $subscribed;
   my $done = 0;
   do
   {
      my $temp_path = join('/', @splitpath);
      $subscribed = 
         filedb::get_hidden_data( $temp_path, "subscribed");
      if(defined($subscribed))
      {
my $boundary = "------------" . auth::create_vword(24);
my $extra = "Content-Type: multipart/mixed; boundary=\"$boundary\"";
my $http_base = get_http_location();
          my $message = "\n\nThis is a MIME-encapsulated message\n";

	$message .= "--$boundary\n";
	$message .= "Content-type: text/html\n";
#	$message .= "Content-Base: \"$http_base\"\n";
$message .= "\n";
          
my $browse_link = $http_base . 'login.cgi?next=browse.cgi&path=' . view::url_encode_path("$notes_path_short");
$message .= "<a href=\"$browse_link\">$browse_link</a>\n<br><br>\n";

$message .= "<hr>\n\n";

$message .= "--${boundary}\n";
$message .= "Content-type: text/html\n";
$message .= "Content-Base: \"$http_base\"\n";
#$message .= "Content-Location: \"$http_base\"\n";
$message .= "\n";

$message .= view::get_dir_file_html($notes_path);
$message .= "\n\n";

$message .= "--${boundary}\n";
$message .= "Content-type: text/html\n";
$message .= "Content-Base: \"$http_base\"\n";
$message .= "\n";

$message .= "<hr>\n";
$message .= view::create_modification_string(filedb::get_mtime($temp_path), filedb::get_hidden_data($temp_path, "owner"), filedb::get_hidden_data($temp_path, "group"));

my $message_end = "--${boundary}--\n";

	my @subscribers = split(/\s+/, $subscribed);
	for my $user (@subscribers)
	{
           my $user_info = auth::get_user_info($user);
           next unless(auth::check_file_auth( $user, $user_info, 'S', $temp_path));
           if(defined($user_info) and defined($user_info->{Email}))
           {
# user specific part of message
my $message_user .= "<br><a href=\"login.cgi?next=subscribe.cgi&user=$user&path=" . view::url_encode_path($temp_path) . "\">Subscribed</a> to WKN path: $temp_path<br>\n\n";
		&mailer::send_email( "WKN: ${notes_path_short}", $mailer::define::admin_email, $user_info->{Email},
			$message . $message_user . $message_end, $extra);
           }
	} 
        
      }
      unless(@splitpath) { $done = 1 }
      pop(@splitpath);
   } while (!$done);
}

sub get_http_location
{
   my $url = "http://";
   $url .= defined($ENV{HTTP_HOST})? $ENV{HTTP_HOST} : (defined($ENV{SERVER_NAME})? $ENV{SERVER_NAME}:$ENV{SERVER_ADDR});
   $url .= ":$ENV{SERVER_PORT}" unless ($ENV{SERVER_PORT} eq 80);
   $ENV{SCRIPT_NAME} =~ m:[^/]+$:;
   $url .= $` if(defined($`));
   return $url;
}

# function to send email using sendmail
sub send_email
{
        my ($subject, $from, $to, $msg_body, $extra) = @_;
	return 0 unless(defined($to));
	return 0 unless(defined($mailer::define::sendmailer));
        undef($ENV{PATH}); # possibly tainted
	open (EMAIL, "| $mailer::define::sendmailer");

#        print EMAIL "Return-Path: <$from>\n";
#        print EMAIL "Sender: $from\n";
#        print EMAIL "Reply-To: $from\n";
#        print EMAIL "Errors-To: $errors_to\n" if (defined($errors_to));
        print EMAIL "$extra\n" if(defined($extra));
        print EMAIL "From: $from\n" if(defined($from));
        print EMAIL "To: $to\n";
        print EMAIL "Subject: $subject\n\n";
        print EMAIL "$msg_body\n";

        close EMAIL;
}
1;
