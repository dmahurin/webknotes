#!/usr/bin/perl
if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'wkn_define.pl';
require 'wkn_lib.pl';

print "Content-Type: text/html\n\n";
print "<html><head>
<TITLE>Other WKN browse methods</TITLE>
<base target=\"_top\">
</HEAD><BODY>
<H1>Other browse methods</H1>
<body>";

my($notes_path) = $ENV{QUERY_STRING};
if ( $notes_path =~ m/\.\./ )
{
       print "illegal chars\n";
       exit 0;
}
# else notes_path is ok. untaint it
$notes_path =~ m:^:;
$notes_path = $';

#take off leading and trailing /'s and remove \'s
$notes_path =~ s:^/*::;
$notes_path =~ s:/*$::;
$notes_path =~ s:\\::g;


#$notes_path=~s/%(..)/pack("c",hex($1))/ge;

print <<"END";

<dl>
<dt><A HREF=\"browse_table.cgi?$notes_path\"> Table </A>
<dd>
This version displays the text for topic directory and lists subdirs in a
table.
</dl>

<dl>
<dt>
<A HREF=\"browse_tables.cgi?$notes_path\"> Tables
</A>
<dd>
This version puts the topic text in a table, and does the same thing for all of its
sub directories.
</dl>

<dl>
<dt>
<A HREF=\"browse_tables2.cgi?$notes_path\"> Extended Tables
</A>
<dd>
This version puts the topic text in a table, and for each of the subdirectories, creates a table with the subtopic text and sub-sub topic list.
</dl>

<dl>
<dt>
<A HREF=\"browse_list.cgi?$notes_path\"> List </A>
<dd>
Hierarchy using HTML list, with possible maximum depth
</dl>

<dl>
<dt>
<A HREF=\"browse_list2.cgi?$notes_path\"> Expanding List </A>
<dd>
Expanding Hierarching using HTML tables and [+] and [-] tags for
expand/collapse.
</dl>

<dl>
<dt>
<A HREF=\"browse_js.cgi?$notes_path\"> JavaScript Expanding List </A>
<dd>
Expanding Hierarching using HTML tables and [+] and [-] tags for
expand/collapse.
</dl>

<dl>
<dt>
<A HREF=\"browse_frames_list.cgi?$notes_path\"> Frames List</A>
<dd>
Puts Expanding List Index on Left, Current Directory as main frame and has
a title and footer section.
</dl>

<dl>
<dt>
<A HREF=\"browse_frames_js.cgi?$notes_path\"> Frames JavaScript</A>
<dd>
Puts Expanding List Index on Left, Current Directory as main frame and has
a title and footer section.
</dl>

<dl>
<dt>
<A HREF=\"browse_plain.cgi?$notes_path\"> Plain </A>
<dd>
No table, just Topic text separate from subtopic list.
</dl>

<dl>
<dt>
<A HREF=\"browse_page.cgi?$notes_path\"> News Page </A>
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
<a href=\"$auth::define::doc_wpath/$notes_path"> Browse Notes </a>
<dd>
Just brose the notes directory using the web servers file browsing.
</dl>

<dl>
<dt><A HREF=\"$auth::define::doc_wpath/$notes_path\"> File Indexing </A>
<dd>
Just use the web server's directory indexing.
</dl>

END
print "</body></html>\n";
