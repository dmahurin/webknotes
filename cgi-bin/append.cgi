#!/usr/bin/perl
use strict;
# CGI script to edit a file using auth-lib user verification

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'auth_lib.pl';
require 'filedb_lib.pl';
require 'mailer_lib.pl';
use CGI qw(:cgi-lib); 

my($my_main) = auth::localize_sub(\&main);
&$my_main;

sub main
{
#$this_cgi = $ENV{'SCRIPT_NAME'};
my $this_cgi = "edit.cgi";
print "Content-type: text/html\n\n";

my $illegal_dir = "cgi-bin";

my %in;
&ReadParse(\%in);

my $path = $in{'path'};
if(!defined( $path )) { $path=$ENV{'QUERY_STRING'}};
if(!defined( $path )) { $path=$ARGV[0]};
if( !defined( $path ) )
{
   print ("No path defined\n");
   exit(0);
}

if($path =~ m:(^|/+)\.+:)
{
   print "Illegal chars\n";
   exit(0);
}
#untaint path 
if( $path =~ m:^(.*)$:)
{
   $path = $1;
}
$path =~ s:^/+::;

$path = auth::url_unencode_path($path);
my $encoded_path = auth::url_encode_path($path);

if( $path =~ m:$illegal_dir: )
{
   print "Illegal dir\n";
   exit(0);
}

my $file = &filedb::default_file($path);
my $dir = &filedb::path_dir($path);
my $dirfile = &filedb::path_file($path);

unless(defined($file))
{
    if(! defined($dir) || $dir eq $path )
    { # directory with no key file or directory not exist
       print "File or Directory does not exist\n";
       exit(0);
    }
}

unless($file =~ m:^[^\.]+(\.(txt|html?|wiki))?$:)
{
   print "Not text file\n";
   exit(0);
}

my $user = auth::get_user();

my $text = $in{'text'};

my $acc_flag;
if( ! defined ( $text ) )
{
   $acc_flag = 'r'; #read
}
elsif( ! defined ($file) )
{
   $file = $path; # user specified file in path
   $acc_flag = 'c'; #create
}
else
{
   $acc_flag = 'a'; #append
}
if( ! auth::check_current_user_file_auth( $acc_flag, $dir ))
{
   print "You are not authorized(${acc_flag}) to access this file: $dirfile\n";
   exit 0;
}

if( ! defined($text) )
{
   print( "FILE: $file <br>\n");

   $text = filedb::get_file($dir, $file);

   $text =~ s#&#&amp;#g;
   $text =~ s#<#&lt;#g;
   $text =~ s#>#&gt;#g;
   print "<PRE>$text</PRE>\n";
print "<hr>\n";
print "<form><TEXTAREA NAME=\"text\" wrap=true rows=22 cols=65 >";
   print "<\/TEXTAREA>\n";
   print <<"EOT";
<input type=hidden name=path value="$path">
<br><INPUT TYPE=submit VALUE="Save">
</form>
EOT
}
else
{
   $text =~ s:\r\n:\n:g; # rid ourselves of the two char newline
my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
           localtime();
        $year +=1900;
        $mon++;
   my($userstr) = "by $user" if(defined($user));
   $user = "unknown" unless(defined($user));
my($date) = sprintf("%d-%02d-%02d %02d:%02d:%02d", $year, $mon, $mday, $hour, $min, $sec);
   my $header;
   $header = "\n<hr title=\"Modified $date $userstr\">\n" if ($file =~ m:\.html?$:);
   $header = "\n----!Modified $date by $user\n" if ($file =~ m:\.wiki?$: or $file =~ m:^([A-Z][a-z]+){2,}$:);
   $header .= "\n";
   
   filedb::append_file($dir, $file, $header . $text); 
   if(auth::check_current_user_file_auth( 'M', $dir ))
   {
     &mailer::mail_subscribers($dir, $file);
   }


   print "<html><head><meta HTTP-EQUIV=\"Refresh\" CONTENT=\"1; url=browse.cgi?$encoded_path\"></head><html>\n";
   print "wrote $dirfile\n";
   print "<html>";
}
}
