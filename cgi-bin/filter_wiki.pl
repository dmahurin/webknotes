#!/usr/bin/perl
# I ripped this out of wiki to display wiki pages

package filter;

my $notes_path = ();
my $TranslationToken = "###TOKEN###";

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

sub file_exists
{
   my($file) = @_;
   return $file 
      if( -e "$auth::define::doc_dir/$notes_path/$file");
   return "${file}.wiki"
      if( -f "$auth::define::doc_dir/$notes_path/${file}.wiki");
   return ();
}

sub AsAnchor {
  local($title) = @_;
  my($temp);
  my($view_url) =  &wkn::get_cgi_prefix() . $notes_path . "/";
  my($add_url) =  "http://web/cgi-bin/wkn/add_topic.cgi?notes_path=$notes_path&text_type=wiki&topic_tag=";

  my($file) = file_exists($title);
  defined($file)
  ? "<a hRef=\"${view_url}$file\">$title<\/a>"
    : "$title<a href=\"${add_url}$title\">?<\/a>";
}
# --------------------------------------------------------  AsAnchor

sub AsLink {
  local($num) = (@_);
  local($ref) = "temp" ; #$old{"r$num"};
  defined $ref
    ? ($ref =~ /\.gif$/ 
       ? "<img src=\"$ref\">" 
       : "<a hreF=\"$ref\">[$num]<\/a>")
      : "[$num]";
}
# --------------------------------------------------------  AsLink

sub PrintBodyText {
  s/\\\n/ /g;
  foreach (split(/\n/, $_)){
    $InPlaceUrl=0;
    $code = "";
    s/^([\t\;]+)([^\*].+):/<dt>$2<dd>/   && &EmitCode(DL, length $1);
#    while (s/(\[{1,2}([a-z]{3,}:[\$-:=\?-Z_a-z~]+[\$-+\/-Z_a-z~-])\]/[<a href="$1">$1<\/a>/) {
#    }
    while (s/\[\[([a-z]{3,}:[\$-:=\?-Z_a-z~]+[\$-+\/-Z_a-z~-])\]/\[$TranslationToken$InPlaceUrl$TranslationToken\]/) {
      $InPlaceUrl[$InPlaceUrl++] = $1;
    }
    while (s/\b\b((ftp|http|mailto):[\$-:=\?-Z_a-z~]+[\$-+\/-Z_a-z~-])/$TranslationToken$InPlaceUrl$TranslationToken/) {
      $InPlaceUrl[$InPlaceUrl++] = $1;
    }




#    s/^\s*$/<p>/                  && ($code = '...');             
    s/^\s*$/<p>/          &&      &EmitCode("", 0);            
#    /^\s*$/ && $code ne "P" &&  &EmitCode("P", 0);
    s/^\;:(\s+)//              && &EmitCode(blockquote, length $1);
   
#below is a hack, put it in a function
    s/^([\*\#]*\*(?!\#))/<li>/              && &EmitCode(UL, length $1);
    s/^([\*\#]*\#)/<li>/              && &EmitCode(OL, length $1);

    s/^(\t+)\*/<li>/              && &EmitCode(UL, length $1);
    s/^(\t+)\#/<li>/              && &EmitCode(OL, length $1);
    s/^(\t+)\d+\.?/<li>/          && &EmitCode(OL, length $1);
    /^\s/                        && &EmitCode(PRE, 1);
    /^$/                  &&   &EmitCode("", 0);
#    $code                           || &EmitCode("", 0);
    s/_{2}(.*)_{2}/<strong>$1<\/strong>/g;
    # s/'{3}(.*)'{3}/<strong>$1<\/strong>/g;
    # s/'{2}(.*)'{2}/<em>$1<\/em>/g;
    s/'{3}(.*?)'{3}/<strong>$1<\/strong>/g;
    s/'{2}(.*?)'{2}/<em>$1<\/em>/g;
    s#^-----*(:+)(.*)#join('', "<hr><b><font size=\"\+", length $1, "\">$2</font></b><hr>")#ge &&  &EmitCode("", 0);
    s/^-----*(\!.*)?/<hr>/ &&  &EmitCode("", 0);
    s/^!(.*)//;
    s/\b($LinkPattern)\b/&AsAnchor($1)/geo;
    s/\[(\d+)\]/&AsLink($1)/geo;
    s/$TranslationToken(\d+)$TranslationToken/&InPlaceUrl($1)/geo;
#    s/\[Search\]/$SearchForm/;
    print "$_\n";
  }
  &EmitCode("", 0);
}

sub print_file
{
   my($notes_file) = @_;
   my($text) = wkn::get_file($notes_file);
   $notes_file =~ m:/([^\/]+)$:;
   $notes_path = $`;

   $_ = $text; 
   &EscapeMetaCharacters;
   &PrintBodyText;
}
