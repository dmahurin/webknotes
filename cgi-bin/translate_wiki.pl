#!/usr/bin/perl
# I ripped this out of wiki to display wiki pages

package wiki_translate;

#----- main -------------------------------------

$linkWord = "[A-Z][a-z]+";
$LinkPattern = "($linkWord){2,}";

sub EscapeMetaCharacters {
  s/&/&amp;/g;
  s/</&lt;/g;
  s/>/&gt;/g;
}
# --------------------------------------------------------  EscapeMetaCharacters

sub InPlaceUrl {
  local($num) = (@_);
  local($ref) = $InPlaceUrl[$num];
  "<a href=\"$ref\">$ref</a>";
}
# --------------------------------------------------------  InPlaceUrl

sub EmitCode {
  ($code, $depth) = @_;
  while (@code > $depth) 
    {local($_) = pop @code; 
     print "</$_>\n"}
  while (@code < $depth) 
    {push (@code, ($code)); 
     print "<$code>\n"}
  if ($code[$#code] ne $code)
    {print "</$code[$#code]><$code>\n";
     $code[$#code] = $code;}
}
# --------------------------------------------------------  EmitCode

sub AsAnchor {
  local($title) = pop(@_);
  my($temp);
  defined $temp # $db{$title}
  ? "<a href=\"$ScriptUrl\?$title\">$title<\/a>"
    : "$title<a href=\"$ScriptUrl\?edit=$title\">?<\/a>";
}
# --------------------------------------------------------  AsAnchor

sub AsLink {
  local($num) = (@_);
  local($ref) = "temp" ; #$old{"r$num"};
  defined $ref
    ? ($ref =~ /\.gif$/ 
       ? "<img src=\"$ref\">" 
       : "<a href=\"$ref\">[$num]<\/a>")
      : "[$num]";
}
# --------------------------------------------------------  AsLink

sub PrintBodyText {
  s/\\\n/ /g;
  foreach (split(/\n/, $_)){
    $InPlaceUrl=0;
    while (s/\b\b([a-z]{3,}:[\$-:=\?-Z_a-z~]+[\$-+\/-Z_a-z~-])/$TranslationToken$InPlaceUrl$TranslationToken/) {
      $InPlaceUrl[$InPlaceUrl++] = $1
    }
    $code = "";
    s/^\s*$/<p>/                  && ($code = '...');             
    s/^(\t+)(.+):\t/<dt>$2<dd>/   && &EmitCode(DL, length $1);
    s/^(\t+)\*/<li>/              && &EmitCode(UL, length $1);
    s/^(\t+)\d+\.?/<li>/          && &EmitCode(OL, length $1);
    /^\s/                        && &EmitCode(PRE, 1);
    $code                         || &EmitCode("", 0);
    # s/'{3}(.*)'{3}/<strong>$1<\/strong>/g;
    # s/'{2}(.*)'{2}/<em>$1<\/em>/g;
    s/'{3}(.*?)'{3}/<strong>$1<\/strong>/g;
    s/'{2}(.*?)'{2}/<em>$1<\/em>/g;
    s/^-----*/<hr>/;
    s/\b($LinkPattern)\b/&AsAnchor($1)/geo;
    s/\[(\d+)\]/&AsLink($1)/geo;
    s/$TranslationToken(\d+)$TranslationToken/&InPlaceUrl($1)/geo;
#    s/\[Search\]/$SearchForm/;
    print "$_\n";
  }
  &EmitCode("", 0);
}

sub translate_print
{
   my($text) = @_;

   $_ = $text; 
   print $text;
   &EscapeMetaCharacters;
   &PrintBodyText;
}
