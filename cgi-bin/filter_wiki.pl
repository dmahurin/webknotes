#!/usr/bin/perl
use strict;
# I ripped this out of wiki to display wiki pages

package filter_wiki;

require 'view_define.pl';

my $TranslationToken = "\@\@\@TOKEN\@\@\@";

my $linkWord = "[A-Z][a-z,0-9]+";
my $LinkPattern = "($linkWord){2,}";

sub EscapeMetaCharacters {
  s/&/&amp;/g;
  s/</&lt;/g;
  s/>/&gt;/g;
}
# --------------------------------------------------------  EscapeMetaCharacters

sub InPlaceUrl {
  my($InPlaceUrls, $num) = (@_);
  my($ref) = ${$InPlaceUrls}[$num];
  "<a href=\"$ref\">$ref</a>";
}

# --------------------------------------------------------  InPlaceUrl

sub EmitCode {
  my($codes, $code, $depth) = @_;
  while (@$codes > $depth) 
    {local($_) = pop @$codes; 
     print "</$_>\n"}
  while (@$codes < $depth) 
    {push (@$codes, ($code)); 
     print "<$code>\n"}
  if (${$codes}[$#$codes] ne $code)
    {print "</${$codes}[$#$codes]><$code>\n";
     ${$codes}[$#$codes] = $code;}
}
# --------------------------------------------------------  EmitCode

sub file_exists
{
   my($notes_path, $file) = @_;
   return $file 
      if( -e "$filedb::define::doc_dir/$notes_path/$file");
   return "${file}.wiki"
      if( -f "$filedb::define::doc_dir/$notes_path/${file}.wiki");
   return ();
}

sub AsAnchor {
  my($notes_path, $title) = @_;
  my($temp);
  my($notes_path_encoded) = view::url_encode_path($notes_path);
  my($view_url) =  &view::get_cgi_prefix() . $notes_path_encoded . "/";
  my($add_url) =  "add_topic.cgi?notes_path=${notes_path_encoded}&text_type=wiki&topic_tag=";

  my($file) = file_exists($notes_path, $title);
  defined($file)
  ? "<a hRef=\"${view_url}$file\">$title<\/a>"
    : "$title<a href=\"${add_url}$title\">?<\/a>";
}
# --------------------------------------------------------  AsAnchor

sub AsLink {
  my($num) = (@_);
  my($ref) = "temp" ; #$old{"r$num"};
  defined $ref
    ? ($ref =~ /\.gif$/ 
       ? "<img src=\"$ref\">" 
       : "<a hreF=\"$ref\">[$num]<\/a>")
      : "[$num]";
}
# --------------------------------------------------------  AsLink

sub PrintBodyText {
   my ($notes_path) = @_;
   my @InPlaceUrls = ();
   my @codes = ();

  s/\\\n/ /g;
  foreach (split(/\n/, $_)){
    my $InPlaceUrl=0;
    my $code = "";
    s/^([\t\;]+)([^\*].+):/<dt>$2<dd>/   && &EmitCode("DL", length $1);
#    while (s/(\[{1,2}([a-z]{3,}:[\$-:=\?-Z_a-z~]+[\$-+\/-Z_a-z~-])\]/[<a href="$1">$1<\/a>/) {
#    }
    while (s/\[\[([a-z]{3,}:[\$-:=\?-Z_a-z~]+[\$-+\/-Z_a-z~-])\]/\[$TranslationToken$InPlaceUrl$TranslationToken\]/) {
      $InPlaceUrls[$InPlaceUrl++] = $1;
    }
    while (s/\b\b((ftp|http|mailto):[\$-:=\?-Z_a-z~]+[\$-+\/-Z_a-z~-])/$TranslationToken$InPlaceUrl$TranslationToken/) {
      $InPlaceUrls[$InPlaceUrl++] = $1;
    }




    my $empty = s/^\s*$/<p>/;
#    s/^\s*$/<p>/                  && ($code = '...');             
    $empty          &&      &EmitCode(\@codes,"", 0);            
#    /^\s*$/ && $code ne "P" &&  &EmitCode(\@codes,"P", 0);
    s/^\;:(\s+)//              && &EmitCode(\@codes,"blockquote", length $1);
   
#below is a hack, put it in a function
    s/^([\*\#]*\*(?!\#))/<li>/              && &EmitCode(\@codes,"UL", length $1);
    s/^([\*\#]*\#)/<li>/              && &EmitCode(\@codes,"OL", length $1);

    s/^(\s+)\*/<li>/              && &EmitCode(\@codes,"UL", length $1);
    s/^(\s+)\#/<li>/              && &EmitCode(\@codes,"OL", length $1);
    s/^(\s+)\d+\.?/<li>/          && &EmitCode(\@codes,"OL", length $1);
    /^\s/                        && &EmitCode(\@codes,"PRE", 1);
    /^$/                  &&   &EmitCode(\@codes,"", 0);
#    $code                           || &EmitCode(\@codes,"", 0);
    s/_{2}(.*)_{2}/<strong>$1<\/strong>/g;
    # s/'{3}(.*)'{3}/<strong>$1<\/strong>/g;
    # s/'{2}(.*)'{2}/<em>$1<\/em>/g;
    s/'{3}(.*?)'{3}/<strong>$1<\/strong>/g;
    s/'{2}(.*?)'{2}/<em>$1<\/em>/g;
    s#^-----*(:+)(.*)#join('', "<hr><b><font size=\"\+", length $1, "\">$2</font></b><hr>")#ge &&  &EmitCode(\@codes,"", 0);
    s/^-----*(\!.*)?/<hr>/ &&  &EmitCode(\@codes, "", 0);
    s/^!(.*)//;
    s/\b($LinkPattern)\b/&AsAnchor($notes_path,$1)/geo;
    s/\[(\d+)\]/&AsLink($1)/geo;
    s/$TranslationToken(\d+)$TranslationToken/&InPlaceUrl(\@InPlaceUrls,$1)/geo;
#    s/\[Search\]/$SearchForm/;
    print $_;
    print "<br>" unless($empty || @codes);
    print "\n";
  }
  &EmitCode(\@codes, "", 0);
}

sub print_file
{
   my($notes_file) = @_;
   my($text) = filedb::get_file($notes_file);
   $notes_file =~ m:/([^\/]+)$:;
   my $notes_path = $`;

   $_ = $text; 
   &EscapeMetaCharacters;
   &PrintBodyText($notes_path);
}
1;
