#!/usr/bin/perl
require 'auth_define.pl';
require 'auth_lib.pl';

use strict;

use CGI qw(:cgi-lib);


my($my_main) = auth::localize_sub(\&main);
&$my_main;

sub main
{
print "Content-type: text/html\n\n";
my %input;

&ReadParse(\%input);
my $path = $input{"path"};
my $dir;
unless(defined($path) && defined($dir = &filedb::path_dir($path)))
{
   print "Directory does not exist: $dir\n";
   exit(0);
}

my $user = auth::get_user();
unless(defined($user) and auth::check_current_user_file_auth( 's', $dir ) )
{
   print "You are not authorized(s) to subscribe to: $dir\n";
   exit 0;
}

my $subscribe = $input{"subscribe"};
if(! defined($subscribe))
{
   $subscribe = "no";
   for my $subscriber (split(',', filedb::get_hidden_data($dir, "subscribed")))
   {
      if($subscriber eq $user)
      {
         $subscribe = "yes";
      }
   }
   
   print "<h1>Subscibe to path: $dir</h1>\n"; 
   print "<form action=\"subscribe.cgi\">\n";

   print "<input type=\"hidden\" name=\"path\" value=\"$dir\">\n";
   
# later the choices will be all, this, none
print "<input type=\"radio\" name=\"subscribe\" value=\"yes\" " .
   ( $subscribe eq "yes" ? "checked" : "" ) .
   ">yes\n";
print "<input type=\"radio\" name=\"subscribe\" value=\"no\" " .
   ( $subscribe eq "no" ? "checked" : "" ) .
   ">no\n";

print "<input type=\"submit\" value=\"change\">\n";
print "</form>\n";
}
else
{
   my $old_subscribed = filedb::get_hidden_data($dir, "subscribed");
   my $new_subscribed;
   my @subscribers;
   for my $subscriber (split(',', $old_subscribed))
   {
      if($subscriber eq $user)
      {
         next unless($subscribe eq "yes");
         undef($subscribe); # so we don't append it.
      }
      push(@subscribers, $subscriber);
   }
   push(@subscribers, $user) if($subscribe eq "yes");
   $new_subscribed = join(',', @subscribers);
   filedb::set_hidden_data($dir, "subscribed", $new_subscribed)
      if($new_subscribed ne $old_subscribed);
   print "Subscription changed\n";
}

}# main
