#!/usr/bin/perl
use strict;
no strict 'refs';

# expanding list version of main WebKNotes script table version

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying, modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

print "Content-type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'wkn_define.pl';
require 'wkn_lib.pl';
require 'wkn_attr.pl';

#my $INDENT = " ";
#my $LSTART = "<dl>";
#my $LITEM = "<dt>";
#my $LITEM_END = "";
#my $LEND = "</dl>";
#my $INDENT = "&nbsp&nbsp";
#my $LSTART = "";
#my $LITEM = "";
#my $LITEM_END = "<br>";
#my $LEND = "";
#my $INDENT = " ";
#my $LSTART_TOP = "<table border=0 cellspacing=0 cellpadding=0>";
#my $LEND_TOP = "</table>";
#my $LITEM_START_COMPLEX = "<tr><td>";
#my $LITEM_MARK_COMPLEX = "</td><td>";
#my $LITEM_END_COMPLEX = "</td></tr>";
#my $LITEM_START_SIMPLE = "";
#my $LITEM_MARK_SIMPLE = "";
#y $LITEM_END_SIMPLE = "<br>";

my $INDENT = " ";
my $LSTART = "<table border=0 cellspacing=0 >";
my $LEND = "</table>";
my $LITEM_START = "<tr><td valign=\"top\">";
#my $LITEM_START = "<tr $wkn::attr::td_highlight><td valign=\"top\" $wkn::attr::td_highlight >";
#my $LITEM_START1 = "</td><td $wkn::attr::td_list nowrap=1 >";
my $LITEM_START1 = "</td><td nowrap=1 >";
my $LITEM_END0 = "<br>";
my $LITEM_END = "</td></tr>";

my $CLOSED_SYMBOL = "[+]"; 
my $OPENED_SYMBOL = "[-]";
my $FILE_SYMBOL = "[.]";

my(@cgi_args) = split(/\&/, $ENV{QUERY_STRING});

local $wkn::define::frames_mode = $wkn::define::mode
  unless defined ($wkn::define::frames_mode);
my $mode = $wkn::define::frames_mode;
my $this_script_prefix = "wkn_list2.cgi?";


my $notes_path_encoded = shift(@cgi_args);
my $target = "";
if($notes_path_encoded =~ m:^target=:)
{
   $this_script_prefix .= "target=$'&";
   $target = "target=\"$'\"";
   $notes_path_encoded = shift(@cgi_args);
}
my($notes_path) = &wkn::path_check(&wkn::url_unencode_path($notes_path_encoded));
exit(0) unless(defined($notes_path));

my $open_tree = unflatten_tree(unencode_paths(@cgi_args));

$notes_path =~ m:([^/]*)$:;
my $notes_name = $1;

my($user) = auth::get_user();
if( ! auth::check_file_auth( $user, 'r', $wkn::define::auth_subpath, $notes_path ) )
{
   print "You are not authorized to access this path.\n";
   exit(0);
}

print
"<HTML>
<head>
</head>" .
#defined($wkn::attr::body) ? "<body " . $wkn::attr::body . ">" :
"<BODY>";

#print "<table border=0 cellpadding=8>\n";
#print "<tr><td $wkn::attr::td_description>\n";
#if(&wkn::print_dir_file($notes_path))
#{
#   print "</td></tr>\n";
#   print "<tr><td $wkn::attr::td_list>\n";
#}
#wkn::print_icon_img($notes_path);
#print "<b>$notes_name</b> - ";
#wkn::print_modification($notes_path);
#print "</td></tr>\n";
#print "<tr><td $wkn::attr::td_list>\n";
#wkn::actions2($notes_path);
#print "</td></tr>\n";
#print "<tr><td $wkn::attr::td_list>\n";

my($toppath) = $wkn::define::notes_dir;
$toppath .= "/$notes_path" if( $notes_path ne "");

my($notes_base) = $notes_path eq "" ? "" : "$notes_path/";
if(-d $toppath)
{
   # old code that provided a link the higher directory
#   my($dirfile) = &wkn::dir_file($notes_path);
#   if(1 || defined( $dirfile ))
   #   {
#      my $topname;
#      print "$LSTART$LITEM_START";
#      if($notes_path =~ m:(/|^)([^/]+)$:)
#      {
#          my($parent_epath) = wkn::url_encode_path($`);
#          print "<a target=\"_top\" href=\"wkn_frames_list.cgi?$parent_epath\">[<-]</a>";
#          $topname = $2;
#      }
#      else
#      {
#        print "[/]";
#        $topname = "Main";
#      }
#      print "$LITEM_START1";
#      print "<a href=\"wkn_$mode.cgi?$notes_path\" $target>$topname</a><br>";
#      print "$LITEM_END$LEND";
#   }
   
   my @dirs = ( );
   my @dir_entries;
   push(@dir_entries, read_dir_entries($toppath));
   print "$LSTART\n";
   my($indent) = "";
   
   my $filename;
   READDIR: while( 1 )
   {
      $filename = shift(@{$dir_entries[$#dir_entries]});
         
      unless(defined($filename))
      {
         pop(@dir_entries);
         $indent = s:^$INDENT:: if($INDENT);
         print "$indent$LEND\n";
         last READDIR unless(@dirs);
         pop(@dirs);
         next;
      }

       next if ( $filename =~ m:^(\.|README|index.html): );
       next if ($filename =~ m:(\.bak|~)$:);
       next if ($filename =~ m:^\.:);

       my($name) = $filename;
       $name = wkn::define::filename_filter($filename) if defined(&wkn::define::filename_filter);
       next unless ( defined($name));

       my $fullpath = join('/', @dirs, $filename);
       #untaint fullpath ( why is it tainted)
       $fullpath =~ m:^:;
       $fullpath = $';
       my $encoded_subnotes_path = wkn::url_encode_path("$notes_base$fullpath");

       next if ( defined($wkn::define::skip_files) and $filename =~ m/$wkn::define::skip_files/);

       print "$indent$LITEM_START";
       
       # Dir, traverse down it
       if (-d "$toppath/$fullpath" )
       {
          my $dir_ref = get_tree_itemref($open_tree, @dirs);
          if(defined($dir_ref->{$filename}))
          {
             my $save_ref = $dir_ref->{$filename};
             undef($dir_ref->{$filename});
             print "<a href=\"$this_script_prefix$notes_path_encoded&". 
                join ('&' , encode_paths(flatten_tree($open_tree))) .
                "\">". &wkn::text_icon($wkn::define::opened_icon_text, 
                   $wkn::define::opened_icon) .
                "</a>$LITEM_START1\n";
             $dir_ref->{$filename} = $save_ref;
          }
          elsif(@dirs >= $wkn::define::max_depth - 1)
          {

             print "<table cellspacing=0 cellpadding=0 ><tr><td>" .
#"<a href=\"wkn_$mode.cgi?$encoded_subnotes_path\" $target>" .
             &wkn::text_icon($wkn::define::dir_icon_text,
                $wkn::define::dir_icon) .
#"</a>" .
                "</td></tr></table>" .
                "$LITEM_START1\n";
          }
          else
          {
             %{$dir_ref->{$filename}} = ();
             print "<table cellspacing=0 cellpadding=0 ><tr><td>";
             print "<a href=\"$this_script_prefix$notes_path_encoded&" . 
                join ('&' , encode_paths(flatten_tree($open_tree))) .
                "\">" .
                &wkn::text_icon($wkn::define::closed_icon_text, 
                   $wkn::define::closed_icon) .
                "</a>";
             print "</td></tr></table>";
             print "$LITEM_START1\n";
             undef($dir_ref->{$filename});
          }
          my($dirfile) = &wkn::dir_file($notes_base . $fullpath);
          if(1 || defined( $dirfile ))
          {
             print "<a href=\"wkn_$mode.cgi?$encoded_subnotes_path\" $target>$name</a>";
          }
          else
          {
             print "$name (<a href=\"" . &wkn::default_scriptprefix() . $encoded_subnotes_path . "\" $target>*</a>)";
          }

          if(defined($dir_ref->{$filename}))
          {
             push(@dirs, $filename);
             push(@dir_entries, read_dir_entries("$toppath/$fullpath"));
             print "$LITEM_END0\n";
             print "$indent$LSTART\n";
             $indent .= $INDENT;
          }
          else
          {
             print "$LITEM_END\n";
          }
          
       }
       elsif($name =~ m:\.(html|txt)$:)
       {
          $name = $`;
          print &wkn::text_icon($wkn::define::file_icon_text, 
                   $wkn::define::file_icon) .
              "$LITEM_START1<a $target href=\"wkn_$mode.cgi?$encoded_subnotes_path\">$name</a>";
          print "$LITEM_END\n";
       }
       else
       {
          print &wkn::text_icon($wkn::define::file_icon_text, 
                   $wkn::define::file_icon) . "$LITEM_START1<a $target href=\"$wkn::define::notes_wpath/$encoded_subnotes_path\">$name</a>";
          print "$LITEM_END\n";
       }
   }
}
#print "</table>\n";
#print "</td></tr>\n";
#print "<td><tr>\n";
#print "<table border=0 cellpadding=8>\n";
#print "<tr><td $wkn::attr::td_list>\n";
#wkn::actions3($notes_path);
#print "</td></tr>\n";

#print "</table>\n";
print "</BODY>\n";
print "</HTML>\n";


sub read_dir_entries
{
   my($dir) = @_;
   my @entries;
   my @dentries;
   opendir(MYDIR, $dir);
   my $file;
   while(defined($file = readdir(MYDIR)))
   {
      next if($file eq "." or $file eq "..");
      if( -d $dir . "/" . $file)
      {
         push(@dentries, $file);
      }
      else
      {
         push(@entries, $file);
      }
   }
   close(MYDIR);
   push(@entries, @dentries);
   return \@entries;
}

# creates an a oneway travered tree from an encoded string
# format: "complex/" - sub items follow, "" - end of sub items, or "item"
sub unflatten_tree
{
   my(@items) = @_;

   my(@branches) = ();
   my(%tree);

   my $current = \%tree;
   my $item;

   foreach $item(@items)
   {
      if($item =~ m:/$: )
      {
         $item = $`;
         %{$current->{$item}} = ();
         push(@branches, $current);
         $current = \%{$current->{$item}};
      }
      elsif($item eq "")
      {
         unless($current = pop(@branches))
         {
            print "tried to go below tree root\n";
            last;
         }
      }
      else
      {
         $current->{$item} = 1;
      }
   }
   return \%tree;
}

sub flatten_tree
{
   my($tree_ref) = @_;

   my(@items) = ();
   my $item;
   foreach $item (keys %$tree_ref)
   {
      if(defined($tree_ref->{$item}))
      {
         if(defined(%{$tree_ref->{$item}}))
         {
            push(@items, $item . '/');
            push(@items, flatten_tree($tree_ref->{$item}));
            push(@items, '');
         }
         else
         {
            push(@items, $item);
         }
      }
   }
   return @items;
}

sub print_tree
{
   my($tree_ref, $indent) = @_;

   my $item;
   foreach $item (keys %$tree_ref)
   {
      if(defined($tree_ref->{$item}))
      {
         if(defined(%{$tree_ref->{$item}}))
         {
            print $indent . $item . '/' . "\n";
            print_tree($tree_ref->{$item}, $indent . " ");
         }
         else
         {
            print $indent . $item . "\n";
         }
      }
   }
}

sub get_tree_itemref
{
  my($tree_ref, @path) = @_;

  foreach(@path)
  {
     unless(defined($tree_ref->{$_}))
     {
        $tree_ref = ();
        last;
     }
     $tree_ref = \%{$tree_ref->{$_}};
  }
  return $tree_ref;
}

sub new_tree_itemref
{
  my($tree_ref, @path) = @_;
  
  foreach(@path)
  {
     $tree_ref = \%{$tree_ref->{$_}};
  }
  %$tree_ref = ();
  return $tree_ref;
}

sub encode_paths
{
   my(@out) = ();
   foreach(@_)
   {
      push(@out,wkn::url_encode_path($_));
   }
   return @out;
}

sub unencode_paths
{
   my(@out) = ();
   foreach(@_)
   {
      push(@out,wkn::url_unencode_path($_));
   }
   return @out;
}
