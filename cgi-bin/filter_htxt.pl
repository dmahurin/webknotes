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
   my $text;

   if($ref =~ m:\|:)
   {
      $ref = $`;
      $text = $';
   }

   if( $ref =~ m:^(mailto\:|[a-z]+\://)[^/]+:)
   {
      unless(defined($text))
      {
         $text = $ref;
      }
      $link = sprintf("<a href=\"%s\">%s<\/a>", link_translate::smart_ref($path,$ref), $text);
   }
   elsif( filedb::is_dir($path, $ref))
   {
      unless(defined($text))
      {
         $ref =~ m:([^/]+)$:;
         $text = $1;
      }
      $link = sprintf("<a href=\"%s\">%s<\/a>", link_translate::smart_ref($path,$ref), $text);
   }
   elsif( filedb::is_file($path, $ref))
   {
      $ref =~ m:([^/]+)$:;
      my $file = $1;
      unless(defined($text))
      { 
         $text = $file;
         if($text =~ m:\.(htm?|txt|wiki|htxt|url)$:)
         {
            $text = $`;
         }
      }	      

      if($file =~ m:\.(url)$:)
      {
         my $url = filedb::get_file($path,$ref);
         $url =~ s:\n::g;
         $link = "<a href=\"$url\">$text</a>";
      }
      else
      {
         $link = sprintf("<a href=\"%s\">%s<\/a>", link_translate::smart_ref($path,$ref), $text);
      }
   }
   elsif( filedb::is_file($path, "${ref}.htxt"))
   {
      unless(defined($text))
      {
         $ref =~ m:([^/]+)$:;
         $text = $1;
      }
      $link = sprintf("<a href=\"%s\">%s<\/a>", link_translate::smart_ref($path,"$ref.htxt"), $text);
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
      unless(defined($text))
      {
         $text = $ref;
      }	      

      my($path_encoded) = view::url_encode_path($path);
      my($topic) = view::url_encode_path($ref); 
      my($bprefix, $bsuffix) = &view::get_cgi_prefix("");

      my($add_url) =  "add_topic.cgi?path=${path_encoded}&text_type=htxt&topic_tag=";

      $link = "<a href=\"$bprefix${add_url}$topic$bsuffix\">$text (?)<\/a>";
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
   #$textin =~ s/<<([^>]+)>>/[[$1]]/g;
   
   $textin =~ s:<:&lt;:g;
   $textin =~ s:>:&gt;:g;
   
   # convert raw URL to [[ ]]
   $textin =~ s/(^|[^\[])((http|ftp|mailto):.*)(?=$)/$1[[$2]]/;
   # process  htxt [[ ]] markup
   $textin =~ s/\[\[([^\]]+)\]\]/&my_link_translate($notes_path,$1)/gie;
   
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
