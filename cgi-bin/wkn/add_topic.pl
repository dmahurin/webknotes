#!/usr/bin/perl
use strict;
# provides functions to add a topic to the WebKNotes system

# The WebKNotes system is Copyright 1996-2000 Don Mahurin
# For information regarding the Copying policy read 'LICENSE'
# dmahurin@users.sourceforge.net

#require 'send_email.pl';
if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'wkn_define.pl';

push(@INC, $wkn::define::auth_inc);
require $wkn::define::auth_lib;

package wkn;
#test add_topic("", "new", "topic", "text", "other", "message");

sub make_dir
{
	my($notes_path) = @_;

	if(!mkdir("$wkn::define::notes_dir/$notes_path", 0755 ))
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

	open(NFILE, "> $wkn::define::notes_dir/${notes_filepath}" );

	print NFILE $contents;

	close(NFILE);
	chmod 0644,"$wkn::define::notes_dir/$notes_filepath";

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
my @auth_parent_path = ( $wkn::define::auth_subpath, $parent_path );
my @auth_path = ( $wkn::define::auth_subpath, $notes_path );
if( ! auth::check_file_auth( $user, 'n', @auth_path ) )
{
   print "User does not have permission to add note\n";
   return 0;
}

if( ! &wkn::make_dir($notes_path))
{
#if ( -e "$wkn::define::notes_dir${notes_path}/README" )
#	print("Notes path already exist. \nTopic not created\n");
print "Failed to create dir: $notes_path\n";
	return 0;
}
if(auth::check_file_auth( $user, 'i', @auth_parent_path ))
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

#        print "message: $message\n";
if( $text_type eq "text" )
{
   &wkn::mkfile("$notes_path/README", $message);
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
#shift(@path_array);

my $temp_path="";
my ($dir, $full_path, $line);
foreach $dir (@path_array)
{
	$temp_path="$temp_path/$dir";
	$full_path="$wkn::define::notes_dir${temp_path}";
	if( -r "${full_path}/.subscribed" )
	{

#$footer = "\n\nThis message was generated from subscription to WebKNotes: ${temp_path}
#To respond to this messages go to:\n" .
#"$wkn::define::cgi_wpath_full/" .
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

1;
