#!/usr/bin/perl
if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'view_define.pl';
require 'view_lib.pl';

print "Content-Type: text/html\n\n";
print "<html><head>
<TITLE>WKN browse help</TITLE>
<base target=\"_top\">
</HEAD><BODY>
<H1>WKN Browse help</H1>
<body>";

print <<"END";

<dl>
<dt><A HREF=\"browse.cgi?layout=table&$cgi_query_str\"> Table </A>
<dd>
This version displays the text for topic directory and lists subdirs in a
table.
</dl>

<dl>
<dt>
<A HREF=\"browse.cgi?layout=tables&$cgi_query_str\"> Tables
</A>
<dd>
This version puts the topic text in a table, and does the same thing for all of its
sub directories.
</dl>

<dl>
<dt>
<A HREF=\"browse.cgi?layout=tables2&$cgi_query_str\"> Extended Tables
</A>
<dd>
This version puts the topic text in a table, and for each of the subdirectories, creates a table with the subtopic text and sub-sub topic list.
</dl>

<dl>
<dt>
<A HREF=\"browse.cgi?layout=list&$cgi_query_str\"> List </A>
<dd>
Hierarchy using HTML list, with possible maximum depth
</dl>

<dl>
<dt>
<A HREF=\"browse.cgi?layout=list2&$cgi_query_str\"> Expanding List </A>
<dd>
Expanding Hierarching using HTML tables and [+] and [-] tags for
expand/collapse.
</dl>

<dl>
<dt>
<A HREF=\"browse.cgi?layout=js&$cgi_query_str\"> JavaScript Expanding List </A>
<dd>
Expanding Hierarching using HTML tables and [+] and [-] tags for
expand/collapse.
</dl>

<dl>
<dt>
<A HREF=\"browse.cgi?layout=frames_list&$cgi_query_str\"> Frames List</A>
<dd>
Puts Expanding List Index on Left, Current Directory as main frame and has
a title and footer section.
</dl>

<dl>
<dt>
<A HREF=\"browse.cgi?layout=frames_js&$cgi_query_str\"> Frames JavaScript</A>
<dd>
Puts Expanding List Index on Left, Current Directory as main frame and has
a title and footer section.
</dl>

<dl>
<dt>
<A HREF=\"browse.cgi?layout=plain&$cgi_query_str\"> Plain </A>
<dd>
No table, just Topic text separate from subtopic list.
</dl>

<dl>
<dt>
<A HREF=\"browse.cgi?layout=page&$cgi_query_str\"> News Page </A>
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
<a href=\"$filedb::define::doc_wpath/$notes_dir"> Browse Notes </a>
<dd>
Just brose the notes directory using the web servers file browsing.
</dl>

END
print "</body></html>\n";
