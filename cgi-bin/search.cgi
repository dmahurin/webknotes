#!/usr/bin/perl
use strict;
no strict 'refs';

# search.cgi - search directory tree of a 'WebKNotes' database
#
# cgi input
#    keywords: keywords to search for
#    exact_match = "on" if the search is exact rather than pattern
#                   match based
#    file_mask = file mask as a regular expression
#
# Ouputs either a search input page( no search definition given)
# or html formated results of matches
#
# - Don Mahurin
############################################################

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# - dmahurin@users.sourceforge.net

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'auth_define.pl';
require 'auth_lib.pl';
require 'wkn_lib.pl';

my($user) = auth::get_user(); # used for auth checking on find

my(@skip_files) = ( '^README(\.html)?$', '^\.' );

############################################

$| = 1; # Set output to flush directly (for troubleshooting)
use CGI qw(:cgi-lib);

# Get the form variables
my(%in);
&ReadParse(\%in);
print &PrintHeader;

my($keywords) = $in{'keywords'};
my($exact_match) = ( $in{'exact_match'} eq "on" );
my($file_mask) = $in{'file_mask'};
my($note_type) = $in{'note_type'};
my($debug) = defined($in{debug});

$wkn::view_mode{"layout"} = $in{notes_mode} if($in{notes_mode});

##
my($match_prefix_url) =  &wkn::get_cgi_prefix();

my($notes_subpath) =  "$in{'notes_subpath'}";


if ( $notes_subpath ne "" )
{
   $notes_subpath	= "/$notes_subpath";
   $notes_subpath =~ s!//!/!;
}
my($search_contents) = ( $in{'search_contents'} eq "on");
my($days_old);
$days_old = $in{'days_old'};
$days_old = $in{days_old2} if($days_old eq "" and defined($in{'days_old2'}));


my(@keyword_list) = split(/\s+/,$keywords);

if ( ! defined($keywords) || ! defined($days_old) 
   || $keywords eq "" && (  $days_old eq "" || $days_old > 100 ) )
{
   print "$keywords\n" unless(!defined($days_old));
   &print_input_form_html;
   exit;
} # End of if keywords

&print_header_html;

#
# We traverse the whole directory structure under $root_web_path
# and in doing so, we also parse the HTML files to see if they have
# the keywords and what their title is.
#
# The following sets up the initial variables
# @dirs is the array of directories as a placeholder for going back up
# the directory tree when we run out of files in a subdirectory.
# $cur_dir is the current directory number and is a reference to the @dirs
# array.
# 
# Directory Handles are straight ASCII and consist of "DIR" + $cur_dir

my($number_of_hits) = 0;

my($search_root) = "$auth::define::doc_dir$notes_subpath" ;
my(@dirs) = ( "$search_root" );
opendir("DIR$#dirs", "$dirs[0]");


my($line, $found, $dir_words, $subpath, $fullpath, $key_dir_depth);
my(@not_found_words, $this_note_type, $searchfile, $file);

my($debug) = 0;


DIR: while (@dirs)
{
   unless(defined($file = readdir("DIR$#dirs")))
   {
      print "closing dir\n" if $debug;
      closedir("DIR$#dirs");
      pop(@dirs);

      # rest of block is 'notes' specific
      if($key_dir_depth)
      {
         $key_dir_depth--;
      }

      next;
   }
   next if ( $file eq "." or $file eq ".." );
   next if ( $file =~ m:^\.:);
   next if (defined($file_mask) && $file =~ /$file_mask/i );

   $fullpath = join('/', @dirs, $file);
   $subpath = join('/', @dirs[1..$#dirs], $file);

   if (-d $fullpath)
   {
      next DIR if (defined($wkn::define::skip_files) and 
                  $file =~ m/$wkn::define::skip_files/);
      next unless (-r $fullpath && -x $fullpath);
      push(@dirs, $file);
      opendir("DIR$#dirs", $fullpath);

      # rest of block is 'notes' specific
      if($key_dir_depth)
      {
         $key_dir_depth++;
      }
      if( -e "$fullpath/README.html" )
      {
         $searchfile = "$fullpath/README.html";
      }
      elsif( -e "$fullpath/README" )
      {
         $searchfile = "$fullpath/README";
      }
      else
      {
         $searchfile = "";
      }

      # check note type if set
      unless( $note_type eq "" )
      {
         next unless ( -e "$fullpath/.type" );

         open(INPUT, "$fullpath/.type");
         read(INPUT, $this_note_type, 80);
         close(INPUT);

         # strip out extra non alpha chars (that vi puts in if edited)
         $this_note_type =~ s#[^A-Za-z].*##;

         if( "$note_type" eq "unanswered_question" &&
            ( "$this_note_type" eq "question" ) )
         {
            next unless dir_has_files($fullpath);
         }
         elsif( ! ( $this_note_type eq $note_type ) )
         {
            next;
         }
      }

      print "DIR: $fullpath:\n" if $debug;
   }
   else # file
   {
      next unless( $note_type eq "" );
      unless (-r $fullpath) { print "Unreadable: $fullpath\n"; next }
      
      next DIR if ( defined($wkn::define::skip_files) and
           $file =~ m/$wkn::define::skip_files/);
      foreach (@skip_files)
      {
         next DIR if ($file =~ m/$_/);
      }
      
      $searchfile = $fullpath;
      print "FILE: $fullpath:\n" if $debug;
   }

   # now search the filename for keyword matches
   if( $keywords eq "" )
   {
      $found = 1;
   }
   else
   {
      @not_found_words = @keyword_list;
      $found = 0;

      # we have filled all keywords locate additional matches
      if($key_dir_depth)
      {
         $found = &find_keyword($exact_match, $file,
            \@not_found_words);
         # found repeat if found.
      }
      else
      {
         $dir_words = join ( ' ', @dirs, $file);
         $dir_words =~ s:_: :g;
         &find_keywords($exact_match,
            $dir_words, \@not_found_words);
         if(@not_found_words < 1) # array empty
         {
            $key_dir_depth = 1;
            $found = 1;
         }
      }
   }

   next if( $days_old && ( &calc_days_old($searchfile) > $days_old ));

   if( $search_contents && !$found && $searchfile )
   {
      # in a path that already matches everything.  Find any match.
      if($key_dir_depth)
      {
         @not_found_words = @keyword_list;
      }

      print "searching $searchfile\n" if ($debug);
      open(SEARCHFILE, $searchfile);
      select(SEARCHFILE); $/ = undef; select(STDOUT);
      while(<SEARCHFILE>)
      {
         $line = $_;

         # we have filled all keywords locate additional matches
         if($key_dir_depth)
         {
            if(&find_keyword($exact_match,
               $line, \@not_found_words))
            {
               $found = 1;
               last;
            }
         }
         else
         {
            &find_keywords($exact_match, $line,
               \@not_found_words);
            if(@not_found_words < 1)
            {
               $found = 1;
               last;
            }
         }
      }
      close (SEARCHFILE);
   }

   if ($found )
   {
      if(auth::check_file_auth( $user, auth::get_user_info($user),
         'r', $notes_subpath ))
      {
         &print_file_match_html($subpath, $file);
         $number_of_hits++;
      }
   }
}

if (! $number_of_hits)
{
   &print_no_match_html;
}
&print_footer_html;

# directory has non-hidden, non README files            
sub dir_has_files
{
   my($dir) = @_;
   open(DIR, $dir);
   my $file ;

   my $rtn = 0;
   while(defined( $file = readdir("DIR")))
   {
      $rtn = 1 if( ! ( $file =~ /^README/ ) &&
         ( ! ( $file =~ /^\./  ) ) )
   }
   close(DIR);
   return $rtn;
}

#calc_days_old
sub calc_days_old
{
   my($filename) = @_;
   my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
      $atime,$mtime,$ctime,$blksize,$blocks);

   ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
      $atime,$mtime,$ctime,$blksize,$blocks)
      = stat($filename);
	
   return ( ( time() - $mtime ) / 86400 );
}

############################################################
# find_keywords
#     $exact_match  if we are not pattern matching
#     $line = line to search on
#     $not_found_words = array reference of keywords that have not 
#                        matched yet
#   Output:
#     @$not_found_words will have keywords spliced out of it
#     as they are found.
############################################################
sub find_keywords
{
   my($exact_match, $line, $not_found_words ) = @_;
   my($x, $match_word);
   
   if ( $exact_match )
   {
      $x = @$not_found_words - 1;
      foreach $match_word (@$not_found_words)
      {
         if ( $line =~ /\b$match_word\b/i )
         {
#   print "found:$match_word:$line\n";
            splice(@$not_found_words, $x, 1);
         }
         $x--;
      }
   }
   else
   {
      $x = @$not_found_words - 1;
      foreach $match_word (@$not_found_words)
      {
         if ($line =~ /$match_word/i)
         {
#   print "found:$match_word:$line\n";
            splice(@$not_found_words,$x, 1);
         }
         $x--;
      }
   }
}

# same as above, but returns on first match
sub find_keyword
{
   my($exact_match, $line, $not_found_words ) = @_;
   my($x, $match_word);
   
   my($rtn)=0;
   
   if ($exact_match)
   {
      $x = @$not_found_words - 1;
      foreach $match_word (@$not_found_words)
      {
         # \b matches on word boundary
         if ($line =~ /\b$match_word\b/i)
         {
            $rtn = 1;
            last;
         }
         $x--;
      }
   }
   else
   {
      $x = @$not_found_words;
      foreach $match_word (@$not_found_words)
      {
         if ($line =~ /$match_word/i)
         {
            $rtn = 1;
            last;
         }
         $x--;
      }
   }
   
   $rtn;
}

### html pieces ###
 
sub print_header_html
{
    print <<EOT;
<HTML><HEAD><TITLE>search results</TITLE></HEAD>
<BODY>
<H2>Your search for:  
EOT
    if( $keywords )
    {
       print "keywords = $keywords,<br>";
    }

    if( $notes_subpath )
    {
       print "WebKNotes subpath = $notes_subpath,<br> ";
    }

    if( $days_old )
    {
       print "days_old = $days_old,<br>";
    }

    if( $note_type )
    {
       print "note_type = $note_type,<br>";
    }

    print "<br>appeared at the following locations:</H2><HR><UL>";

}

sub print_footer_html
{
    print <<EOT;
<P>
<HR>
</CENTER> </BODY> </HTML>
EOT
}

sub print_no_match_html
{
   print <<EOT;

<P>
<H2>No matches found.</H2>
<P>
EOT
}

sub print_file_match_html
{
    my($filename, $title) = @_;

    my $filename_enc =  wkn::url_encode_path($filename);

    my $prefix;
    if( -d "$auth::define::doc_dir/$filename" || $filename =~ m:\.(htm|html|txt)|README:)
    {
        $prefix = $match_prefix_url;
    }
    else
    {
       $prefix = "$auth::define::doc_wpath/";
    }
    print <<EOT;
<LI>
<B>
<A HREF="$prefix$filename_enc">
$title</A> ($filename)
</B>
<BR>
EOT
}

# form to input keywords
sub print_input_form_html
{
    print <<EOT;
<HTML>
<HEAD>
<TITLE>WebKNotes Search </TITLE>
</HEAD> 
<H2>WebKNotes Search </H2>
<hr>

<FORM METHOD="POST" ACTION="search.cgi">
<B>Notes Subpath( optional ):</B> <INPUT TYPE="text" SIZE="30" NAME="notes_subpath" MAXLENGTH="80" VALUE="$notes_subpath" > <br>
<hr>
<B>Enter your keywords:</B> <INPUT TYPE="text" SIZE="30" NAME="keywords" value="$keywords" MAXLENGTH="80"> <br>
<p>
<INPUT TYPE=checkbox NAME="exact_match"> Exact Match Search <br>
<INPUT TYPE=radio NAME="search_contents" VALUE="off" checked> Search Topic Keywords only <br>
<INPUT TYPE=radio NAME="search_contents" VALUE="on"> Examine Message Contents also <br>
<hr>    
<B>Date constraint:</B> <SELECT  WIDTH=33 NAME="days_old" >
<OPTION VALUE="" SELECTED>Days Old =>
<OPTION VALUE="1">New today
<OPTION VALUE="2">New in 2 days
<OPTION VALUE="3">New in 3 days
<OPTION VALUE="7">New this week
<OPTION VALUE="30">30 days
</SELECT><INPUT TYPE="text" SIZE="10" name=days_old2 value="$days_old" MAXLENGTH="10"><br>
<hr>    
<B>Restrict note type to:</B> <SELECT  WIDTH=33 NAME="note_type">
<OPTION VALUE="" SELECTED >All notes
<OPTION VALUE="note">General Notes
<OPTION VALUE="question">Questions
<OPTION VALUE="answer">Answers
<OPTION VALUE="topic">Topics
<OPTION VALUE="unanswered_question">Unanswered Questions
</SELECT>
<hr>
<INPUT TYPE=hidden NAME="notes_mode" VALUE="$notes_mode">
<INPUT TYPE="SUBMIT" VALUE="Do Search">
<INPUT TYPE="RESET" VALUE="Clear this form">
</FORM>
</BODY></HTML>

EOT

}
