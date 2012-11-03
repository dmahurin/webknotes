// convert from twiki (twiki.org) to html
// dmahurin@sf.net

function convert_code(text) {
	return '<pre>' + text + '</pre>';
}
function convert_list(text) {
	var out = '';
	var indent = 0;
        var indents = [];
	var m;
	while(null !== (m = text.match(/([\s\S]*?)^(\s*)\*\s*(.*)$([\s\S]*)/m))) {
		out += ( m[1] + m[2]);
		if(indents.length == 0 || m[2].length > indents[indents.length - 1]) { out += "<ul>"; indents.push (m[2].length); }
		while(indents.length > 0 && m[2].length < indents[indents.length - 1]) { out += "</ul>"; indents.pop(); }
		if(m[2].length + 1 < indent) { out += "</ul>"; indent = m[2].length + 1; }
		out+= ('<li>' + m[3]);
		text = m[4];
        }
	while(indents.length > 0) { out += "</ul>"; indents.pop(); }
	return(out);
}

function convert_text(text) {
	var replacements = [
	// --++ -> h2
	[ /^\s*---(\++)(\!\!)?\s+(.*)$/mg, function(m,p,b,t) { return( '<h' + p.length + '>' + t + '</h' + p.length + '>')}],
	// blank line -> paragraph
	[/^\s*(?=\n)/mg, '<p>'],
	// *bold*
	//[/([\W\s^])\*(.*?)\*(?=[\W\s$])/ig, function(m,p,t) { return p + '<b>' + t + '</b>' }],
	[/\*([^\s\*]([^\*]|\S\*)*[^\s\*])\*/ig, function(m,t) { return '<b>' + t + '</b>' }],
	[/__([a-z[\sa-z0-9]*[a-z])__/ig, function(m,t) { return '<b><i>' + t + '</b></i>' }],
	[/_([a-z[\sa-z0-9]*[a-z])_/ig, function(m,t) { return '<i>' + t + '</i>' }],
	[/==([a-z[\sa-z0-9]*[a-z])==/ig, function(m,t) { return '<b><span style="font-family: monospace">' + t + '</span></b>' }],
	[/=([a-z[\sa-z0-9]*[a-z])=/ig, function(m,t) { return '<span style="font-family: monospace">' + t + '</span>' }],
	[/\[\[(?:\%ATTACHURL\%\/)?([^\]]+)\](?:\[([^\]]+)\])?\]]/g, function(m,l,t) { if(t === undefined) { t = l }; return '<a href="files/' + l + '>' + t + '</a>'; }],
	[/\[\[(?:[^/]*\/)?([^\]]+)\](?:\[([^\]]+)\])?\]/g, function(m,l,t) { if(t === undefined) { t = l }; return('<a href="files/' + l + '">' + t + '</a>'); }],
	[/(\!?)([A-Z]+[a-z0-9]+[A-Z]+[A-Zaa-z0-9]*)/g, function(m,b,t) { if(b != '') { return t; } else { return '<a href="' + t + '.html">' + t + '</a>'; }}],
	[/\%IMAGE\{\"([^\"]+)\"\}\%/g, function(m,t) { return ('<img src="files/' + t + '">'); }],
	[/^%TOC%$/mg, ''],
	[/%(?:END)?TWISTY(?:{.*})?%$/mg, ''],

	];

	for (var i in replacements) {
		text = text.replace(replacements[i][0], replacements[i][1]);
        }
	return text;
}

function convert(text) {
	return text.replace(/([\s\S]*?)(?:%CODE\{"[^"]*"\}%([\s\S]*?)%ENDCODE%|(?:\n|^)((?:(?:   )+\*.*(?:\n|$))+)|$)/g, function(m,a,b,c) { return convert_text(a) + (b !== undefined ? convert_code(b) : (c !== undefined ? convert_text(convert_list(c)): '')) ; });
}

window.onload = function() {
	var text = document.body.innerHTML;
	text = text.replace(/^\s*<pre>/i,'');
	text = text.replace(/<\/pre>\s*$/i,'');
	document.body.innerHTML = '';
	document.body.innerHTML = convert(text);
};
