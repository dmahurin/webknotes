#!/usr/bin/perl
use strict;
# CGI script to edit a file using auth-lib user verification

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'auth_define.pl';
require 'auth-lib.pl';
use CGI qw(:cgi-lib); 

#$this_cgi = $ENV{'SCRIPT_NAME'};
my $this_cgi = "edit.cgi";
print "Content-type: text/html\n\n";

my $illegal_dir = "cgi-bin";

my %in;
&ReadParse(\%in);

my $file = $in{'file'};
if(!defined( $file )) { $file=$ENV{'QUERY_STRING'}};
if(!defined( $file ) or $file eq "" ) { $file=$ARGV[0]};
if( !defined( $file ) or $file eq "" )
{
   print ("No file defined\n");
   exit(0);
}
# make sure no part of the path starts with '.', untaint $file in process
if( $file =~ m:^(/*[^\./][^/]+)+$: ) 
{
   $file = $&;
}
else
{
   print "hey buddy, whats up?\n";
   exit(0);
}

$file =~ s:^/+::;
my $full_file = "$auth::define::doc_dir/$file";

if( $file =~ m:$illegal_dir: )
{
   print "Illegal dir\n";
   exit(0);
}

my $user = auth::get_user();
#if( ! defined ($user) )
#{
#   print "You are not logged in\n";
#   exit(0);
#}

my $dir = ($file =~ m:/[^/]+$:) ? $` : "";

my $text = $in{'text'};

my $acc_flag;
if( ! defined ( $text ) ) # user has to have read access
{
   $acc_flag = 'r'; #read
}
elsif( -f $full_file ) # user has have modify access
{
   $acc_flag = 'm'; #modify
}
else # user has to have create access
{
   $acc_flag = 'c'; #create
}
if( ! auth::check_file_auth( $user, $acc_flag, "/$file" ) )
{
   print "You are not authorized(${acc_flag}) to access this file: $file\n";
   exit 0;
}

if( ! defined($text) )
{
   print( "FILE: $file <br>\n");
   print <<"EOT";
<form action="$this_cgi" method="post">
<pre>
<TEXTAREA NAME="text" wrap=true rows=24 cols=65 >
EOT
   if(open(TFILE, $full_file ))
   {
      my $line;
      while(defined($line = <TFILE>))
      {
         $line =~ s:<\/TEXTAREA>:<%2FTEXTAREA>:;
         print $line;
      }
      close(TFILE);
   }
   print "<\/TEXTAREA>\n";
   print <<"EOT";
<input type=hidden name=file value="$file">
<br><INPUT TYPE=submit VALUE="Save">
</form>
EOT
print "<hr>\n";
   if( auth::check_file_auth( $user, "/$file", 'p' ) )
   {
   print <<"EOT";
<form action="permissions.cgi" method="post">
<input type=hidden name=dir value="$dir">
<INPUT TYPE=submit VALUE="Change Dir Permissions">
</form>
EOT
   }
   if( auth::check_file_auth( $user, "/$file", 'd' ) )
   {
   print <<"EOT";
<form action="delete.cgi" method="post">
<input type=hidden name=file value="$file">
<INPUT TYPE=submit VALUE="Delete this File/Dir">
</form>
EOT
   }
}
else
{
   if(!open( FOUT, ">$full_file" ) )
   {
      print "failed to write $file\n";
      exit(1);
   }
    $text =~ s:\r\n:\n:g; # rid ourselves of the two char newline
   print FOUT $text;
   close(FOUT);
   print "wrote $file\n";
}
