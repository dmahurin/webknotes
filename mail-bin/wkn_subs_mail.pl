#!/usr/local/bin/perl5
# script to parse a mail message and subscibe/unsubscribe a person based on
# From: and Subject:

# The KNOTES system is Copyright 1996,1997 Don Mahurin
# For information regarding the Copying policy read 'COPYING'
# dmahurin@users.sourceforge.net

require 'knotes_define.pl';
require 'kn_subs.pl';

undef($email);
undef($notes_path);
$unsubscribe = 0;
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
		$line =~ s/^Subject: *//;
		if( $line =~ m/^KN.unsubs:.*/)
		{
			$unsubscribe = 1;
		}
		$notes_path = $line;
		$notes_path =~ s/.*subs: //;

		print("notes_path = $notes_path \n");
	}

	if( $email && $notes_path )
	{
		if($unsubscribe)
		{
			&kn_unsubs($notes_path, $email);
		}
		else
		{
			&kn_subs($notes_path, $email);
		}
		last;
	}
}

1;
