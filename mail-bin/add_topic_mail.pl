#!/usr/bin/perl
# script to parse an incoming mail, and add a topic based on
# Subject, and From:
# Not tested, not used, probably not working yet

# The KNOTES system is Copyright 1996,1997 Don Mahurin
# For information regarding the Copying policy read 'COPYING'
# dmahurin@users.sourceforge.net

require 'add_topic.pl';

$mail_header = "";
$notes_body = "";
while($line = <STDIN>)
{
   $mail_header .= $line;

   chomp($line);
   if (! $line ) # end of header
   {
      last;
   }

   if ( $line =~ m/^From:.*/ )
   {
      # avoid a KNOTES loop
      if( $line =~ m/.*KNOTES.*/ )
      {
         exit;
      }
      $notes_body = "$line\n\n";
      $notes_body =~ s/^From:/Sender:/;
   }

   if ( $line =~ m/^Subject: KN.add:.*/ )
   {
      $notes_path = $line;
      $notes_path =~ s/^Subject: KN.add:\ *//;
   }
}

while($line = <STDIN>)
{
   $notes_body .= $line;
}

if( $mail_header && $notes_path )
{
   &kn_add_topic($notes_path, "note", $mail_header, $notes_body);
}
