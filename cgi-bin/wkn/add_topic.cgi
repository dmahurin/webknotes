#!/usr/bin/perl
use strict;
# script called by the add topic form. Adds topic, displays success.

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# - dmahurin@users.sourceforge.net

print "Content-Type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'wkn_define.pl';
use CGI qw(:cgi-lib);
require 'add_topic.pl';

umask(022);
my %in;
&ReadParse(\%in);
$in{'notes_path'} =~ m:^(.*)$:;
my($notes_path) = $1;
$notes_path=~ s:/$::;
my($topic_tag) = $in{topic_tag} if(defined($in{topic_tag}));

my($user) = auth::get_user();
if( ! auth::check_file_auth( $user, 'n', $wkn::define::auth_subpath, $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}

if(!defined($in{'description'}))
{
   print_form();
   exit 0;
}

$in{'topic_tag'} =~ m:^([^/]*)$:;
my($topic_tag) = $1;

#$topic_tag=~s/([^\w\/])/sprintf("%%%02lx", unpack('C',$1))/ge;
#$topic_tag =~ s/ /_/g;

print "<HTML><HEAD>\n";
print "<TITLE>Adding Topic</TITLE></HEAD><BODY>\n";

my($source_details) = " $ENV{'REMOTE_ADDR'}, $ENV{'REMOTE_HOST'}\n";

if( ! $in{description} || ! $topic_tag )
{
   print("<br>Required field missing <br>\n");
}
else
{
   $in{'description'} =~ s:\r\n:\n:g; # rid ourselves of the two char newlines
   if( &wkn::add_topic($notes_path, $topic_tag, $in{'topic_type'}, $in{'text_type'}, $source_details, $in{description}))
   {

      print("<br>Successfully created topic ${notes_path}/${topic_tag}. <br>\n");
   }
   else
   {
      print("<br>Topic creation was unsuccessful<br>\n");
   }
}
print "<br><A HREF=\"$wkn::define::cgi_wpath/"
. &wkn::default_scriptprefix() .
$notes_path . '">' . "BACK TO NOTES:$notes_path</A>
</BODY></HTML>\n";

sub print_form
{
   if( ! -e "$wkn::define::notes_dir/$notes_path" )
   {
      if( $notes_path =~ m:/([^/]+)$: )
      {
         $notes_path = $`;
         $topic_tag = $1;
      }
      else
      {
         $topic_tag = $notes_path;
         $notes_path = "";
      }
   }



print <<"EOT";
<HTML><HEAD>
<TITLE>Notes Topic</TITLE></HEAD><BODY>
</HEAD><BODY>
<H2>Topic: NOTES:$notes_path</H2>
<FORM METHOD=POST ACTION=\"$wkn::define::cgi_wpath/add_topic.cgi\">
<P> Sub-Topic tag <INPUT TYPE=\"text\" NAME=\"topic_tag\" value=\"$topic_tag\">
<B>Note type:</B> <SELECT  WIDTH=33 NAME=\"topic_type\">
<OPTION VALUE=\"note\" SELECTED>General Note
<OPTION VALUE=\"question\">Question
<OPTION VALUE=\"answer\">Answer
<OPTION VALUE=\"topic\">Topic
</SELECT>
Text type<SELECT  WIDTH=33 NAME=\"text_type\">
<OPTION VALUE=\"text\" SELECTED>Text
<OPTION VALUE=\"html\">HTML
</SELECT>
<br>
Sub-Topic description(body) - (mailto:, http:, and &ltA HREF recognized )<br>
<INPUT TYPE=\"hidden\" NAME=\"notes_path\" value=\"$notes_path\">
<textarea NAME=\"description\" rows=24 cols=75></textarea><P>
EOT
print "WARNING: You are not logged in. You will NOT be able to edit this later.\n" unless(defined($user));

print <<"EOT";
<P><INPUT TYPE=\"SUBMIT\" VALUE=\"Submit now!\">
<HR>
</BODY></HTML>
EOT
}
