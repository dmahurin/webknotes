#!/usr/bin/perl
use strict;
# script called by the add topic form. Adds topic, displays success.

# The WebKNotes system is Copyright 1996-2002 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# - dmahurin@users.sourceforge.net

print "Content-Type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'view_define.pl';
require 'view_lib.pl';
require 'auth_lib.pl';
require 'filedb_lib.pl';
require 'mailer_lib.pl';
use CGI qw(:cgi-lib);

my($my_main) = view::localize_sub(\&main);
&$my_main;

sub main
{
   umask(022);
   my %in;
   &ReadParse(\%in);
   $in{'notes_path'} =~ m:^(.*)$:;
   use vars qw($notes_path);
   local($notes_path) = $1;
   $notes_path=~ s:/$::;

   if( ! auth::check_current_user_file_auth(
      'n', $notes_path ) )
   {
      print "You are not authorized to access this path.\n";
      exit(0);
   }

   if(!defined($in{'description'}) || !defined($in{'topic_tag'}) || $in{topic_tag} eq "")
   {
      my $description;
      $description = $in{description};
      print_form($in{'topic_tag'}, $in{'text_type'}, $description);
      exit 0;
   }

   my $notes_path_encoded = &view::url_encode_path($notes_path);
   $in{'topic_tag'} =~ m:^([^/]*)$:;
   my($topic_tag) = $1;

   #$topic_tag=~s/([^\w\/])/sprintf("%%%02lx", unpack('C',$1))/ge;
   #$topic_tag =~ s/ /_/g;

   print "<HTML><HEAD>\n";
   print "<TITLE>Adding Topic</TITLE></HEAD><BODY>\n";

   my($source_details) = " $ENV{'REMOTE_ADDR'}, $ENV{'REMOTE_HOST'}\n";

   if( $in{description} eq "" )
   {
      print("<br>Required description missing <br>\n");
   }
   elsif( $topic_tag eq "")
   {
      print("<br>Required topic tag missing <br>\n");
   }
   else
   {
      $in{'description'} =~ s:\r\n:\n:g; # rid ourselves of the two char newlines
      if( &add_topic($notes_path, $topic_tag, $in{'text_type'}, $in{description}, $source_details, $in{'topic_type'}))
      {

         #view::browse_show_page($notes_path);
         print "<html><head><meta HTTP-EQUIV=\"Refresh\" CONTENT=\"1; url=browse.cgi?$notes_path_encoded\"></head><html><body>\n";
         print("<br>Successfully created topic ${notes_path}/${topic_tag}. <br>\n");
         print "</body></html>\n";
      }
      else
      {
         print("<br>Topic creation was unsuccessful<br>\n");
      }
   }
}

sub print_form
{
   my($topic_tag, $text_type, $body) = @_;
   my(%sel_text_type);
   my($user) = auth::get_user();
   if(filedb::is_file($notes_path))
   {
      print "File exists\n";
      exit(0);
   }
   elsif(! filedb::is_dir($notes_path))
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
   elsif(! defined($text_type))
   {
   	$text_type = filedb::default_type($notes_path);
	$text_type = "pre" if ($text_type eq "html");
   }
   $sel_text_type{$text_type} = "selected"
     if(defined($text_type));

print <<"EOT";
<HTML><HEAD>
<TITLE>New Notes Topic</TITLE></HEAD><BODY>
</HEAD><BODY>
<H2>Parent Topic: $notes_path</H2>
<FORM METHOD=POST ACTION=\"add_topic.cgi\">
<P> Topic tag <INPUT TYPE=\"text\" NAME=\"topic_tag\" value=\"$topic_tag\">
Text type<SELECT  WIDTH=33 NAME=\"text_type\">
<OPTION VALUE=\"pre\" $sel_text_type{pre}>Preformatted HTML
<OPTION VALUE=\"html\"  $sel_text_type{html} >HTML
<OPTION VALUE=\"htxtdir\" $sel_text_type{htxtdir}>HText
EOT

print "<OPTION VALUE=\"htxt\" $sel_text_type{htxt}>HText File\n"
	if( $text_type eq "htxt");

print "<OPTION VALUE=\"wikidir\"  $sel_text_type{wikidir} >Wiki\n";
print "<OPTION VALUE=\"wiki\"  $sel_text_type{wiki} >Wiki File\n"
	if( $text_type eq "wiki");

print <<"EOT";
<OPTION VALUE=\"text\" $sel_text_type{txt}>Text
</SELECT> See <a href=\"#text-types\">Text type descriptions</a>

<br>
Topic description(body)<br>
<INPUT TYPE=\"hidden\" NAME=\"notes_path\" value=\"$notes_path\">
<textarea NAME=\"description\" rows=24 cols=75>$body</textarea><P>
EOT

#Note type: <SELECT  WIDTH=33 NAME=\"topic_type\">
#<OPTION VALUE=\"note\" SELECTED>General Note
#<OPTION VALUE=\"question\">Question
#<OPTION VALUE=\"answer\">Answer
#<OPTION VALUE=\"topic\">Topic
#</SELECT>

print "WARNING: You are not logged in. You will NOT be able to edit this later.\n" unless(defined($user));

print <<"EOT";
<P><INPUT TYPE=\"SUBMIT\" VALUE=\"Submit now!\">
<HR>
<a name=\"text-types\"> <h2>Text types</h2></a>
<dl>
<dt>HTML</dt>
<dd>HTML - Only the BODY section will be used</dd>
<dt>Preformated HTML</dt>
<dd>The topic body will be added as a PRE html section</dd>
<dt>HText</dt>
<dd>Minimal paragraphing is preserved along with link references contained in [[ ]] or &lt;&lt &gt;&gt; pairs</dd>
<dt>HText File</dt>
<dd>Same as Htext except it is stored as a file in an existing Htext dir</dd>
<dt>Wiki</dt>
<dd>Minimal Wiki markup</dd>
<dt>Wiki File</dt>
<dd>Same as Wiki except it is stored as a file in an existing Wiki dir</dd>
<dt>Text</dt>
<dd>Plain text. No markup or links of any kind.</dd>
</dl>

</BODY></HTML>
EOT
}


sub add_topic
{
	my ( $parent_path, $topic, $text_type, $message, $source_details, $topic_type ) = @_;

	if(! $message )	
	{
		$message = "";
                my $line;
		while($line = <STDIN>)
		{
			$message .= $line;
		}
	}

#	$notes_path =~ s/ /_/g;

if( $topic =~ m:^README(\.html)?$: )
{
	print "README is reserved, sorry.)\n";
	return 0;
}

if ( $parent_path =~ m/\.\./ or $topic =~ m:/: )
{
       print "illegal chars\n";
       return 0;
}
my $notes_path = "$parent_path/$topic";
$notes_path =~ s#^/*##g;

# Allow these tags only:
#<B> <I> <P> <A> <LI> <OL> <UL> <EM> <BR> <STRONG> <BLOCKQUOTE> <HR> <DIV> <TT>

# Don - commented below out because I really do want HTML file(head,title,body)
# left together. Maybe I'll go the other way and define illegal tags
# but I need to define that in the define file, as edit needs it too.
#$message=~s:<(?!\s*/?(a|b|i|p|li|ul|em|br|strong|blockquote|hr|div|tt)( |>))[^>]*>::gi;

# checking auth of nonexistant file will not work anymore
#my $user = auth::get_user();
#if( ! auth::check_current_user_file_auth( 'n', $notes_path ) )
#{
#   print "User does not have permission to add note\n";
#   return 0;
#}

my $should_make_dir = 1;
$should_make_dir = 0 if ($text_type eq "wiki" or $text_type eq "htxt");
$text_type= "wiki" if($text_type eq "wikidir");
$text_type= "htxt" if($text_type eq "htxtdir");

if($should_make_dir)
{
if( ! &filedb::make_dir($parent_path, $topic))
{
print "Failed to create dir: $topic in $parent_path\n";
	return 0;
}
if(auth::check_current_user_file_auth( 'i', $parent_path ))
{
   my($permissions, $group);
   if(defined($permissions = filedb::get_hidden_data($parent_path, "permissions")))
   {
      filedb::set_hidden_data($notes_path, "permissions", $permissions);
   }
   if(defined($group = filedb::get_hidden_data($parent_path, "group")))
   {
      filedb::set_hidden_data($notes_path, "group", $group);
   }
}
}
else
{
   $notes_path = $parent_path;
}

my($file_ext);
my($default_file);
if( $text_type eq "text" )
{
   $file_ext = ".txt";
   $default_file = "README";
}
elsif( $text_type eq "pre" )
{
   $message = "<pre>\n" . $message . "</pre>\n";
   $file_ext = ".html";
   $default_file = "README.html";
}
elsif( $text_type eq "wiki" )
{
   $file_ext = ".wiki";
   $default_file = "FrontPage.wiki";
}
elsif( $text_type eq "htxt" )
{
   $file_ext = ".htxt";
   $default_file = "index.htxt";
}
else
{
   $file_ext = ".html";
   $default_file = "README.html";
}

if($should_make_dir)
{
   $file_ext = "";
   &filedb::put_file("$parent_path/$topic", $default_file, $message);
   &filedb::touch_path("$parent_path/$topic");
}
else
{
   &filedb::put_file($parent_path, $topic . $file_ext, $message);
}

my $log = localtime;
$log .= "\n$source_details\n";
&filedb::set_hidden_data($notes_path, "create-log", $log );
#&filedb::set_hidden_data($notes_path, "type", $topic_type);

my($user) = auth::get_user();
if( defined($user))
{
   filedb::set_hidden_data($notes_path, "owner", $user);
}

if(auth::check_current_user_file_auth( 'M', $parent_path ))
{
&mailer::mail_subscribers($parent_path, $topic . $file_ext);
}

return 1;
}
