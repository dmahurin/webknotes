#!/usr/bin/perl
# script to unsubsribe someone base on the From: and Subject in an incoming
# mail

# The KNOTES system is Copyright 1996,1997 Don Mahurin
# For information regarding the Copying policy read 'COPYING'
# dmahurin@users.sourceforge.net

require 'knotes_define.pl';
require 'kn_subs.pl';

undef($email);
undef($notes_path);
while($line = <STDIN>)
{
	chomp($line);
	if (! $line ) # end of header
	{
		last;
	}

	if ( $line =~ m/^From:.*/ )
	{
		$email = $line;
		$email =~ s/^From: *//;
	}

	if ( $line =~ m/^Subject:.*/ )
	{
		$notes_path = $line;
		$notes_path =~ s/^Subject:.*subs //;
	}

	if( $email && $notes_path )
	{
		&kn_unsubs($notes_path, $email);
		last;
	}
}
