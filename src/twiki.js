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
	[/(\s|^)\*([^\s\*].*?[^\s\*])\*(?!\w)/ig, function(m,s,t) { return s + '<b>' + t + '</b>' }],
	[/(\s|^)__(\S.*\S)__(?!\S)/igm, function(m,s,t) { return s + '<b><i>' + t + '</b></i>' }],
	[/(\s|^)_(\S.*\S)_(?!\S)/igm, function(m,s,t) { return s + '<i>' + t + '</i>' }],
	[/(\s|^)==(\S.*\S)==(?!\S)/igm, function(m,s,t) { return s + '<b><span style="font-family: monospace">' + t + '</span></b>' }],
	[/(\s|^)=(\S.*\S)=(?!\S)/igm, function(m,s,t) { return s + '<span style="font-family: monospace">' + t + '</span>' }],
	[/\[\[(?:\%ATTACHURL\%\/)?([^\]]+)\](?:\[([^\]]+)\])?\]]/g, function(m,l,t) { if(t === undefined) { t = l }; return '<a href="files/' + l + '>' + t + '</a>'; }],
	[/\[\[(?:[^/]*\/)?([^\]]+)\](?:\[([^\]]+)\])?\]/g, function(m,l,t) { if(t === undefined) { t = l }; return('<a href="files/' + l + '">' + t + '</a>'); }],
	[/(\s|^)(\!?)([A-Z]+[a-z0-9]+[A-Z]+[A-Zaa-z0-9]*)/g, function(m,s,b,t) { if(b != '') { return s + t; } else { return s + '<a href="' + t + '.html">' + t + '</a>'; }}],
	[/\b(https?\S+)/g, function(m,r) { return '<a href="' + r + '">' + r + '</a>'; }],
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
	return text.replace(/([\s\S]*?)(?:<verbatim>([\s\S]*?)<\/verbatim>|%CODE\{"[^"]*"\}%([\s\S]*?)%ENDCODE%|(?:\n|^)((?:(?:   )+\*.*(?:\n|$))+)|$)/g,
		function(m,a,v,b,c) {
			if(v !== undefined) b = v;
			return convert_text(a) +
				(b !== undefined ?
					convert_code(b) :
					(c !== undefined ? convert_text(convert_list(c)): '')) ; });
}

window.onload = function() {
	var text = document.body.innerHTML;
	text = text.replace(/^\s*<pre>/i,'');
	text = text.replace(/<\/pre>\s*$/i,'');
	document.body.innerHTML = '';
	document.body.innerHTML = convert(text);
};
