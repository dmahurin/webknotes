#!/usr/bin/perl
use strict;
# script called by the add topic form. Adds topic, displays success.

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# - dmahurin@users.sourceforge.net

print "Content-Type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'wkn_define.pl';
require 'auth_lib.pl';
use CGI qw(:cgi-lib);

umask(022);
my %in;
&ReadParse(\%in);
$in{'notes_path'} =~ m:^(.*)$:;
my($notes_path) = $1;
$notes_path=~ s:/$::;
my($topic_tag) = $in{topic_tag} if(defined($in{topic_tag}));

my($user) = auth::get_user();
if( ! auth::check_file_auth( $user, auth::get_user_info($user),
'n', $notes_path ) )
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
print "<br><A HREF=\""
. &wkn::default_scriptprefix() .
$notes_path . '">' . "BACK TO NOTES:$notes_path</A>
</BODY></HTML>\n";

sub print_form
{
if( ! -e "$auth::define::doc_dir/$notes_path" )
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
<B>Note type:</B> <SELECT  WIDTH=33 NAME=\"topic_type\">
<OPTION VALUE=\"note\" SELECTED>General Note
<OPTION VALUE=\"question\">Question
<OPTION VALUE=\"answer\">Answer
<OPTION VALUE=\"topic\">Topic
</SELECT>
Text type<SELECT  WIDTH=33 NAME=\"text_type\">
<OPTION VALUE=\"pre\" SELECTED>Preformatted Text(&lt;pre&gt;)
<OPTION VALUE=\"html\">HTML
<OPTION VALUE=\"text\">Text(.txt)
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

#require 'send_email.pl';

package wkn;

sub make_dir
{
	my($notes_path) = @_;

	if(!mkdir("$auth::define::doc_dir/$notes_path", 0755 ))
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

	open(NFILE, "> $auth::define::doc_dir/${notes_filepath}" );

	print NFILE $contents;

	close(NFILE);
	chmod 0644,"$auth::define::doc_dir/$notes_filepath";

	return 1;
}

sub add_topic
{
	my ( $parent_path, $topic, $topic_type, $text_type, $source_details, $message ) = @_;

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

my $user = auth::get_user();
my $user_info = auth::get_user_info($user);
my @auth_parent_path = ( $parent_path );
my @auth_path = ( $notes_path );
if( ! auth::check_file_auth( $user, $user_info, 'n', @auth_path ) )
{
   print "User does not have permission to add note\n";
   return 0;
}

if( ! &wkn::make_dir($notes_path))
{
#if ( -e "$auth::define::doc_dir${notes_path}/README" )
#	print("Notes path already exist. \nTopic not created\n");
print "Failed to create dir: $notes_path\n";
	return 0;
}
if(auth::check_file_auth( $user, $user_info, 'i', @auth_parent_path ))
{
   my($permissions, $group);
   if(defined($permissions = auth::get_path_permissions(@auth_parent_path)))
   {
      auth::set_path_permissions($permissions, @auth_path);
   }
   if(defined($group = auth::get_path_group(@auth_parent_path)))
   {
      auth::set_path_group($group, @auth_path);
   }
}

if( $text_type eq "text" )
{
   &wkn::mkfile("$notes_path/README", $message);
}
elsif( $text_type eq "pre" )
{
   &wkn::mkfile("$notes_path/README.html", "<pre>\n" . $message . "</pre>\n");
}
else
{
   &wkn::mkfile("$notes_path/README.html", $message);
}

#&wkn::mail_subscribers($notes_path);
my $log = localtime;
$log .= "\n$source_details\n";
&wkn::mkfile("$notes_path/.create-log", $log );
&wkn::mkfile("$notes_path/.type", $topic_type);

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
	$full_path="$auth::define::doc_dir${temp_path}";
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
