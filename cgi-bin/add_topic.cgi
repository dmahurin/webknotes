#!/usr/bin/perl
use strict;
# script called by the add topic form. Adds topic, displays success.

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# - dmahurin@users.sourceforge.net

print "Content-Type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'view_define.pl';
require 'view_lib.pl';
require 'auth_lib.pl';
require 'filedb_lib.pl';
use CGI qw(:cgi-lib);

my($my_main) = wkn::localize_sub(\&main);
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
   if(defined($in{'copy'}) and $in{copy} ne ""  && ! defined($in{'description'}))
   {
      my $copyfile = &auth::path_check("$notes_path/$in{'copy'}");
      $description = "";
      if(open(COPYFILE, "$filedb::define::doc_dir/$copyfile/README.html"))
      {
         while(<COPYFILE>){$description .= $_;}
         close(COPYFILE);
      }
   }
   else
   {
      $description = $in{description};
   }
   print_form($in{'topic_tag'}, $in{'text_type'}, $description);
   exit 0;
}

my $notes_path_encoded = &wkn::url_encode_path($notes_path);
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
   if( &wkn::add_topic($notes_path, $topic_tag, $in{'text_type'}, $in{description}, $source_details, $in{'topic_type'}))
   {

      #wkn::browse_show_page($notes_path);
      print "<html><head><meta HTTP-EQUIV=\"Refresh\" CONTENT=\"1; url=browse.cgi?$notes_path_encoded\"></head><html><body>\n";
print("<br>Successfully created topic ${notes_path}/${topic_tag}. <br>\n");
print "</body></html>\n";
   }
   else
   {
	print("<br>Topic creation was unsuccessful<br>\n");
   }
}
print "<br><A HREF=\""
. &wkn::default_scriptprefix() .
$notes_path . '">' . "BACK TO NOTES:$notes_path</A>
</BODY></HTML>\n";

}

sub print_form
{
  my($topic_tag, $text_type, $body) = @_;
  my(%sel_text_type);
  my($user) = auth::get_user();
  $sel_text_type{$text_type} = "selected";
if( ! -e "$filedb::define::doc_dir/$notes_path" )
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
<FORM METHOD=POST ACTION=\"add_topic.cgi\">
<P> Sub-Topic tag <INPUT TYPE=\"text\" NAME=\"topic_tag\" value=\"$topic_tag\">
Text type<SELECT  WIDTH=33 NAME=\"text_type\">
<OPTION VALUE=\"pre\" $sel_text_type{pre}>Preformatted Text(&lt;pre&gt;)
<OPTION VALUE=\"html\"  $sel_text_type{html} >HTML
<OPTION VALUE=\"wiki\"  $sel_text_type{wiki} >Wiki
<OPTION VALUE=\"wikidir\"  $sel_text_type{wikidir} >SubWiki(dir)
<OPTION VALUE=\"text\" $sel_text_type{txt}>Text(.txt)
</SELECT>

<br>
Sub-Topic description(body)<br>
<INPUT TYPE=\"hidden\" NAME=\"notes_path\" value=\"$notes_path\">
<textarea NAME=\"description\" rows=24 cols=75>$body</textarea><P>
EOT

#Note type: <SELECT  WIDTH=33 NAME=\"topic_type\">
#<OPTION VALUE=\"note\" SELECTED>General Note
#<OPTION VALUE=\"question\">Question
#<OPTION VALUE=\"answer\">Answer
#<OPTION VALUE=\"topic\">Topic
#</SELECT>
#- (mailto:, http:, and &ltA HREF recognized )<br>

print "WARNING: You are not logged in. You will NOT be able to edit this later.\n" unless(defined($user));

print <<"EOT";
<P><INPUT TYPE=\"SUBMIT\" VALUE=\"Submit now!\">
<HR>
</BODY></HTML>
EOT
}

#require 'send_email.pl';

package wkn;

sub make_dir
{
	my($notes_path) = @_;

	if(!mkdir("$filedb::define::doc_dir/$notes_path", 0755 ))
	{
		return 0;
	}
#	print "${notes_bin}/faccess -d notes  $notes_path";
#	system ("${notes_bin}/faccess -d notes  $notes_path 1>&2 > /dev/null");

	return 1;
}


sub mkfile
{
	my($notes_filepath, $contents) = @_;

	if(open(NFILE, "> $filedb::define::doc_dir/${notes_filepath}" ))
        {
	print NFILE $contents;
	close(NFILE);
	chmod 0644,"$filedb::define::doc_dir/$notes_filepath";
        }

	return 1;
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
$should_make_dir = 0 if ($text_type eq "wiki");
$text_type= "wiki" if($text_type eq "wikidir");

if($should_make_dir)
{
if( ! &wkn::make_dir($notes_path))
{
#if ( -e "$filedb::define::doc_dir${notes_path}/README" )
#	print("Notes path already exist. \nTopic not created\n");
print "Failed to create dir: $notes_path\n";
	return 0;
}
if(auth::check_current_user_file_auth( 'i', $parent_path ))
{
   my($permissions, $group);
   if(defined($permissions = auth::get_path_permissions($parent_path)))
   {
      auth::set_path_permissions($permissions, $notes_path);
   }
   if(defined($group = auth::get_path_group($parent_path)))
   {
      auth::set_path_group($group, $notes_path);
   }
}
}
else
{
   $notes_path = $parent_path;
}

if( $text_type eq "text" )
{
   &wkn::mkfile(
      $should_make_dir ? "$notes_path/README" : "$parent_path/${topic}.txt",
      $message);
}
elsif( $text_type eq "pre" )
{
   &wkn::mkfile(
      $should_make_dir ? "$notes_path/README.html" :
         "$parent_path/${topic}.html",
    "<pre>\n" . $message . "</pre>\n");
}
elsif( $text_type eq "wiki" )
{
   &wkn::mkfile(
      $should_make_dir ? "$notes_path/FrontPage.wiki" :
        "$parent_path/${topic}.wiki",
      $message);
}
else
{
   &wkn::mkfile("$notes_path/README.html",
      $should_make_dir ? "$notes_path/README.html" :
        "$parent_path/${topic}.html",
      $message);
}

#&wkn::mail_subscribers($notes_path);
my $log = localtime;
$log .= "\n$source_details\n";
&wkn::mkfile("$notes_path/.create-log", $log );
#&wkn::mkfile("$notes_path/.type", $topic_type);

my($user) = auth::get_user();
if( defined($user))
{
   &wkn::mkfile("$notes_path/.owner", $user);
}

return 1;
}

sub mail_subscribers
{
   my($notes_path) = @_;
my @path_array = split( /\// , $notes_path );

my $temp_path="";
my ($dir, $full_path, $line);
foreach $dir (@path_array)
{
	$temp_path="$temp_path/$dir";
	$full_path="$filedb::define::doc_dir${temp_path}";
	if( -r "${full_path}/.subscribed" )
	{

#$footer = "\n\nThis message was generated from subscription to WebKNotes: ${temp_path}
#To respond to this messages go to:\n" .
#&wkn::mode_to_scriptprefix($wkn::define::mode). $notes_path . "\n" .
#"for help, mailto: $wkn::define::admin_email\n";
		open(INPUT, "${full_path}/.subscribed" );
		while($line = <INPUT>)
		{
			chomp($line);
			if(! $line)
			{
				last;
			}
			my @subs_args = split(' ', $line);
			my($to) = $subs_args[0];

#			&send_email( "KN: /${notes_path}", $to,
#			$message . $footer,
#			'WebKNotes <noreplies@rightnow.noncom>',
#			"WebKNotes Admin <$wkn::define::admin_email>"
#		);
		}
		close(INPUT);
	} 
}
	return 1;
}
