#!/usr/bin/perl
if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }
require 'wkn_define.pl';
require 'wkn_lib.pl';

print "Content-Type: text/html\n\n";
print "<html><head>
<TITLE>WKN browse help</TITLE>
<base target=\"_top\">
</HEAD><BODY>
<H1>WKN Browse help</H1>
<body>";

print <<"END";

<dl>
<dt>Table
<dd>
This version displays the text for topic directory and lists subdirs in a
table.
</dl>

<dl>
<dt>
Tables
<dd>
This version puts the topic text in a table, and does the same thing for all of its
sub directories.
</dl>

<dl>
<dt>
Extended Tables
<dd>
This version puts the topic text in a table, and for each of the subdirectories, creates a table with the subtopic text and sub-sub topic list.
</dl>

<dl>
<dt>
List
<dd>
Hierarchy using HTML list, with possible maximum depth
</dl>

<dl>
<dt>
Expanding List
<dd>
Expanding Hierarching using HTML tables and [+] and [-] tags for
expand/collapse.
</dl>

<dl>
<dt>
JavaScript Expanding List
<dd>
Expanding Hierarching using HTML tables and [+] and [-] tags for
expand/collapse.
</dl>

<dl>
<dt>
Frames List
<dd>
Puts Expanding List Index on Left, Current Directory as main frame and has
a title and footer section.
</dl>

<dl>
<dt>
Frames JavaScript
<dd>
Puts Expanding List Index on Left, Current Directory as main frame and has
a title and footer section.
</dl>

<dl>
<dt>
Plain
<dd>
No table, just Topic text separate from subtopic list.
</dl>

<dl>
<dt>
News Page
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
Browse Notes
<dd>
Just brose the notes directory using the web servers file browsing.
</dl>

END
print "</body></html>\n";
