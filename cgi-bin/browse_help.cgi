#!/usr/bin/perl
if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'wkn_define.pl';
require 'wkn_lib.pl';

print "Content-Type: text/html\n\n";
print "<html><head>
<TITLE>WKN browse methods</TITLE>
<base target=\"_top\">
</HEAD><BODY>
<H1>WKN Browse methods</H1>
<body>";

my($cgi_query_str) = wkn::get_query_string();


print "<h3>Theme</h3>\n";
my($save) = 0;
if($cgi_query_str =~ s:save=1&::)
{
   $save = 1;
}
my $untheme_cgi_query_str;
my $theme;

if($cgi_query_str =~ m:theme=([^&]*)&?:)
{
   $untheme_cgi_query_str = $` . $';
   $theme = $1;
}

   print "Current theme is : $theme<br>\n";
   print "<a href=\"browse_help.cgi?$c\">Reset theme</a><br>";
   
   if($save)
   {
      my $username = auth::get_user();
      if( ! defined($username) )
      {
         print "Not logged in, can't save\n";
      }
      else
      {
         my($user_info) = auth::get_user_info($username);
         $user_info->{"theme"} = $theme;
         if(! &auth::write_user_info(auth::check_user_name($username), $user_info))
         {
            print "Could not modify user information?\n";
         }
      }
   }
   else
   {
      print "<a href=\"browse_help.cgi?save=1&$cgi_query_str\">Save theme</a><br>";
   }
}
else
{
   if(opendir(CDIR, $wkn::define::themes_dir))
   {
      while(defined($file = readdir(CDIR)))
      {
         if($file =~ m:\.css$:)
         {
            print "<a href=\"browse_help.cgi?theme=$`&$cgi_query_str\">$`</a><br>";
         }
      }
      closedir(CDIR);
   }
}
print "<h3>Layout</h3>\n";
   
print <<"END";

<dl>
<dt><A HREF=\"browse_table.cgi?$cgi_query_str\"> Table </A>
<dd>
This version displays the text for topic directory and lists subdirs in a
table.
</dl>

<dl>
<dt>
<A HREF=\"browse_tables.cgi?$cgi_query_str\"> Tables
</A>
<dd>
This version puts the topic text in a table, and does the same thing for all of its
sub directories.
</dl>

<dl>
<dt>
<A HREF=\"browse_tables2.cgi?$cgi_query_str\"> Extended Tables
</A>
<dd>
This version puts the topic text in a table, and for each of the subdirectories, creates a table with the subtopic text and sub-sub topic list.
</dl>

<dl>
<dt>
<A HREF=\"browse_list.cgi?$cgi_query_str\"> List </A>
<dd>
Hierarchy using HTML list, with possible maximum depth
</dl>

<dl>
<dt>
<A HREF=\"browse_list2.cgi?$cgi_query_str\"> Expanding List </A>
<dd>
Expanding Hierarching using HTML tables and [+] and [-] tags for
expand/collapse.
</dl>

<dl>
<dt>
<A HREF=\"browse_js.cgi?$cgi_query_str\"> JavaScript Expanding List </A>
<dd>
Expanding Hierarching using HTML tables and [+] and [-] tags for
expand/collapse.
</dl>

<dl>
<dt>
<A HREF=\"browse_frames_list.cgi?$cgi_query_str\"> Frames List</A>
<dd>
Puts Expanding List Index on Left, Current Directory as main frame and has
a title and footer section.
</dl>

<dl>
<dt>
<A HREF=\"browse_frames_js.cgi?$cgi_query_str\"> Frames JavaScript</A>
<dd>
Puts Expanding List Index on Left, Current Directory as main frame and has
a title and footer section.
</dl>

<dl>
<dt>
<A HREF=\"browse_plain.cgi?$cgi_query_str\"> Plain </A>
<dd>
No table, just Topic text separate from subtopic list.
</dl>

<dl>
<dt>
<A HREF=\"browse_page.cgi?$cgi_query_str\"> News Page </A>
<dd>
Multiple topics can be given. Separate topics with &'s.
Table is created with each topic put in Table with topic text.
<br>
An empty topic means end of row.
<p>
Understood tags(use separatly before topics):<br>
columns=n - maximum number of columns<br>
colspan=n , rowspan=n - Same use as with HTML

Just brose the notes directory using the web servers file browsing.
</dl>
 
<dl>
<dt>
<a href=\"$auth::define::doc_wpath/$notes_dir"> Browse Notes </a>
<dd>
Just brose the notes directory using the web servers file browsing.
</dl>

<dl>
<dt><A HREF=\"$auth::define::doc_wpath/$notes_dir\"> File Indexing </A>
<dd>
Just use the web server's directory indexing.
</dl>

END
print "</body></html>\n";
