// The WebKNotes system is Copyright 1996-2010 Don Mahurin.
// For information regarding the copying/modification policy read 'LICENSE'.
// dmahurin@sf.net

// this filter translates "Htxt" files. These are text files with implied
// paragraphing and simple Hyperlinks.

// The HTXT "specification is:
//   - If a paragraph has no leading spaces then it is assumed to be <P> text.
//  - If a paragraph has leading spaces, then it is assumed to be <pre> text.
//   - Attachments/links and references are [[link]] or <<link>> and [[http://...]]
//   - There is no other markup. This is not a new wiki.

// This file is derived from WebKnotes filter_htxt.pl

// function to create a link to either browse existing htxt/note or add
// non-existent htxt.
function my_link_translate()
{
	var ref = arguments[1];
	var text = ref;
	var matches;

	if(null != (matches = ref.match(/(.*?)\|(.*)/)))
	{
		ref = matches[1];
		text = matches[2];
	}

	if(ref.match(/^[a-z]+\:\/\/[^\/]+/))
	{
	}
	else if((matches = ref.match(/^mailto:(.*)/)))
	{
		if(text == null)
			text = matches[1];
	}
	// No dot. assume htxt
	else if(null == (ref.match(/\./)))
	{
		ref = ref + ".htxt";
	}
	// directory
	else if((matches = ref.match(/\/$/)))
	{
	}
	// file
	else
	{
		if(text == null)
		{
			if((matches = ref.match(/([^\/]+)\.(html?|txt|wiki|htxt|url)$/)))
				text = matches[1];
		}
	}
	ref = ref.replace(/\s/g, '%20');

	return '<a href="' + ref + '">' + text + '</a>';
}

function htxt2html(text)
{
	text = text.replace(/^<pre>/,'');
	text = text.replace(/<\/pre>$/,'');

	// change "htxt" << >> markup to [[ ]]
	text = text.replace(/<<([^>]+)>>/g, '[[$1]]');

	text = text.replace(/</g, '&lt;');
	text = text.replace(/>/g, '&gt;');

	// convert raw URL to [[ ]]
	text = text.replace(/(^|[^\[])((http|ftp|mailto):.*)(?=$)/g, '$1[[$2]]');
	// process  htxt [[ ]] markup
	text = text.replace(/\[\[([^\]]+)\]\]/g, my_link_translate);
   
	// mark each paragraph as either <p> or <pre>
	var textout = "";
	var thistext;
	var type;
	var matches;

	while(text != '')
	{
		if(null != (matches = text.match(/([^]*?)(^|\n)(\s*)(\n|$)([^]*)$/)))
		{
			thistext = matches[1];
			text = matches[5];
			if(thistext == '') continue; // leading blank
		}
		else
		{
			thistext = text;
			text = '';
		}
		if(thistext == '') continue;
		type = (null != thistext.match(/^\s/)) ? "pre" : "p";
	
		textout += ("<" + type + ">\n" + thistext + "\n</" + type + ">\n");
	}

	return textout;
}

function convert()
{
	document.body.innerHTML = htxt2html(document.body.innerHTML);
}

window.onload = convert;
