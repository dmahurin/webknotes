#!/usr/bin/perl
use strict;

# The WebKNotes system is Copyright 1996-2002 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

# this filter translates "Htxt" files. These are text files with implied
# paragraphing and simple Hyperlinks.

# The HTXT "specification is:
#   - If a paragraph has no leading spaces then it is assumed to be <P> text.
#   - If a paragraph has leading spaces, then it is assumed to be <pre> text.
#   - Attachments/links and references are [[link]] or <<link>> and [[http://...]]
#   - There is no other markup. This is not a new wiki.

require "link_translate.pl";
require 'filedb_lib.pl';
require 'view_define.pl';

package filter_htxt;

# function to create a link to either browse existing htxt/note or add
# non-existent htxt.
sub my_link_translate
{
   my ($path, $ref) = @_;
   my $link;

   if( $ref =~ m:^[a-z]+\://[^/]+:)
   {
      $link = sprintf("<a href=\"%s\">%s<\/a>", link_translate::smart_ref($path,$ref), $ref);
   }
   elsif( -d "$filedb::define::doc_dir/$path/$ref")
   {
      $ref =~ m:([^/]+)$:;
      $link = sprintf("<a href=\"%s\">%s<\/a>", link_translate::smart_ref($path,$ref), $1);
   }
   elsif( -f "$filedb::define::doc_dir/$path/$ref")
   {
      $ref =~ m:([^/]+)$:;
      my $text = $1;
      if($text =~ m:\.(htm?|txt|wiki|htxt)$:)
      {
         $text = $`;
      }

      if($text =~ m:\.(url)$:)
      {
         $text = $`;
         my $url = filedb::get_file($path,$ref);
         $url =~ s:\n::g;
         $link = "<a href=\"$url\">$text</a>";
      }
      else
      {
         $link = sprintf("<a href=\"%s\">%s<\/a>", link_translate::smart_ref($path,$ref), $text);
      }
   }
   elsif(-f "$filedb::define::doc_dir/$path/${ref}.htxt")
   {
      $ref =~ m:([^/]+)$:;
       $link = sprintf("<a href=\"%s\">%s<\/a>", link_translate::smart_ref($path,"$ref.htxt"), $1);
   }
   else
   {
      if($ref =~ m:/([^/]+)$:)
      {
         $ref = $1;
	 $path .= "/$`";
         # collapse ../dir
         while($path =~ s~(^|/+)(?!\.\./)[^/]+/+\.\.($|/)~$1~g){}
      }

      my($path_encoded) = view::url_encode_path($path);
      my($topic) = view::url_encode_path($ref); 
      my($add_url) =  "add_topic.cgi?notes_path=${path_encoded}&text_type=htxt&topic_tag=";

      $link = "<a href=\"${add_url}$topic\">$ref (?)<\/a>";
   }
   return $link;
}

sub filter_file 
{
   my($notes_file) = @_;
   $notes_file =~ m:/([^\/]+)$:;
   my $notes_path = $`;

   my($textin) = filedb::get_file($notes_file);

   return () if(! defined($textin));

   # change "htxt" << >> markup to [[ ]]
   $textin =~ s/<<([^>]+)>>/[[$1]]/g;
   
   $textin =~ s:<:&lt;:g;
   $textin =~ s:>:&gt;:g;
   
   # "htxt" process  [[ ]] markup
   $textin =~ s/\[\[([^\]]+)\]\]/&my_link_translate($notes_path,$1)/gie;
   
   # handle raw URL
   $textin =~ s/((http|ftp|mailto):.*)($)/<a href=\"$1\">$1<\/a>$2/g;

   # mark each paragraph as either <p> or <pre>
   my($textout) = "";
   my($thistext, $type);
   while($textin ne "")
   {
	if($textin =~ m/(^|\n)(\s*)(\n|$)/)
	{
	   $thistext = $`;
	   $textin = $';
           next if($thistext eq ""); # leading blank
	}
	else
	{
	   $thistext = $textin;
	   $textin = "";
	}
	next unless($thistext ne "");
	$type= ($thistext =~ m:^\s:m)? "pre" : "p";
	
	$textout .= "<$type>\n$thistext\n</$type>\n";
	   
   }

   return $textout;
}

sub print_file
{
   print filter_file(@_);
}

1;
