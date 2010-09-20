// Client side only WebDav/SVN/HTTP File/Directory editor

var force_edit = false;

if(window != top)
{
	throw 'can only load from top window';
}

var INDEX_ORDER = { '':999, 'index.html':1, 'index.htm':2, 'index.wiki':3, 'index.htxt':4};

function is_edit_on()
{
	return(null != document.getElementById('button_area') || force_edit);
}

// create tool document using toolbar html/element and document html/element
function create_tool_doc(tool,main,other)
{
	var script = get_script_src();
	var href = get_top_href();

	// workaround for some browsers requiring input in div,span or form
	other = other != null ? '<span>' + other + '</span>': '';

	if(!is_edit_on())
	{
		document.open("text/html");
		document.writeln('<html><head><base href="' + href +'"/><script type="text/javascript" src="' + script + '"></script></head><body>' +
		main +
		other +
		'</body></html>');
		document.close();
		return;
	}
	document.open("text/html");
	document.writeln('<html><head><base href="' + href +'"/><script type="text/javascript" src="' + script + '"></script></head>');
	document.write('<body><table cellpadding="0" cellspacing="0" border="0" style="width:100%;height:100%;"><tr><td><span id="button_area">' +
	tool +
	'</span><hr/></td></tr>' +
	'<tr><td style="height:100%;">' +
	'<div style="position:relative;width:100%;height:100%;">' +
	main +
	'</div></td></tr>' +
	'</table>' +
	other +
	'</body></html>');
	document.close();
}

function frame_load()
{
	var file_doc = document.getElementById('file_area');
	if(file_doc)
		file_doc = frame_document(file_doc);
	if(file_doc && file_doc.body)
	{
		var path = get_filepath();
		file_doc.body.innerHTML = wkn_fix_links(file_doc.body.innerHTML, dirname(path));
	}
}

function create_full_iframe(id, text)
{
	// perhaps consider using iframe src=data:text/html;charset=utf-8,'+ URLencode(text)
	return '<iframe onload="frame_load();" id="' + id + '" style="position:absolute;width:100%;height:100%;border:0;" frameborder="0"></iframe><script>var doc = document.getElementById(\'' + id + '\'); doc = doc.contentDocument || doc.contentWindow.document; doc.open("text/html"); doc.write("'+ text.replace(/\\/g, "\\\\").replace(/\n/g, "\\n").replace(/"/g, "\\\"").replace(/script/g, 'scr"+"ipt') +'"); doc.close();</script>';
}

function frame_document(frame)
{
	return frame.contentDocument? frame.contentDocument : frame.contentWindow.document;
}

function FileList(path)
{
	// if given a non-index/system file with known extention, pass to FileShow
	if(null != path.match(/\.(html?|txt|wiki|chopro|htxt)$/))
	{
		if(null != path.match(/\/(edit|view|index).html$/))
		{
			path=dirname(path);
		}
		else
		{
			// Use ShowDirect to avoid deferred load (which would interfere with Back on initial sceen)
			FileShowDirect(path);
			return;
		}
	}
	var responses = null;

	// try PROPFIND and ignore for non-webdav, non-svn, or file
	try
	{
		var req = new XMLHttpRequest();
		req.open("PROPFIND", path, false);
		req.setRequestHeader("Depth", "1");
		req.setRequestHeader("Content-Length", 0);
		req.send(null);
		if(req.status < 300)
			responses = req.responseXML.getElementsByTagName("D:multistatus")[0].getElementsByTagName("D:response");
	}
	catch(err)
	{
	}

	var index_page = '';
	var list = [];

	// No WebDAV directory. Get and use the directory index.
	if(responses == null)
	{
		var req = new XMLHttpRequest();
		req.open("GET", path, false);
		req.setRequestHeader('Pragma', 'no-cache');
		req.setRequestHeader('Cache-Control', 'no-cache');
		req.send(null);
		data = req.responseText;

		var reg = /<a\s+href="(([^>"\?\/]+)\/?)"[^>]*>([^>]*)<\/a>/gi;
		while(null != (matches = reg.exec(data)))
		{
			var ref=matches[1];
			var name=matches[2];
			var text=matches[3];
			var name=decodeURI(name);
			ref = path + ref;
			var values = {'name':name, 'href': ref};
			list[name] = values;
			if(INDEX_ORDER[name] != null && INDEX_ORDER[name] < INDEX_ORDER[index_page])
			{
				index_page = name;
			}
		}

		responses = [];
	}

	for (i = 0; i < responses.length; i++)
	{
		var href = responses[i].getElementsByTagName("D:href")[0].firstChild.nodeValue;
		if(href == path) continue;

		var name = responses[i].getElementsByTagName("D:propstat")[0].getElementsByTagName("D:prop")[0].getElementsByTagName("D:displayname")[0];
		if(name)
			name = name.firstChild.nodeValue;
		else
			name = decodeURI(href.replace(/^.*\/([^\/]+)\/?/g, "$1"));

		if(INDEX_ORDER[name] != null && INDEX_ORDER[name] < INDEX_ORDER[index_page])
		{
			index_page = name;
		}

		var values = {'name':name, 'href': href};
		list[name] = values;
	}

	var edit_on = is_edit_on();
	if((!edit_on) && index_page != '')
	{
		FileShow(list[index_page]['href']);
		return false;
	}

	var out = '';
	out += ('<h1>Index of ' + path + '</h1><hr/>');
	out += ('<a href="javascript:top.FileList(\'' + parentdir(path) + '\');">Parent Directory</a><br/>');

	var sorted_keys = [];
	for (var i in list) { sorted_keys.push(i); }
	sorted_keys.sort();

	list.sort(function(a,b){a.name.localeCompare(b.name);})
	for ( var i in sorted_keys)
	{
		var key = sorted_keys[i];
		var values = list[key];
		var href = values['href'];
		var name = values['name'];
		if(null != href.match(/\/$/))
		{
			if(href == path)
				continue;
			else
				out +=('<a href="javascript:top.FileList(\'' + href + '\');">' + name + '/</a>');
		}
		else
		{
			out+=('<a href="' + href + '" onclick="top.FileShow(' + "'" + href + "'" + ');">' + name + '</a>');
		}
		out += "<br>\n";
	}

	var toolbar = '\
<input type="button" value="Up" onClick="FileList(\'' + parentdir(path)  + '\');"/> \
<input id="fileinput" type="file" /> \
<input type="button" value="Add" onClick="FileUpload(\'' + path  + '\');"/> \
<input type="button" value="Exit" onClick="FileExit(\'' + path  + '\');"/> \
<input type="hidden" id="filepath" value="' + path + '"/>';

	var href = get_top_href_base() + path;
	var frame = create_full_iframe(null, '<html><head><base href="' + href + '"/></head><body>' + out + '</body>' + '</html>');
	var toolwin = create_tool_doc(toolbar, frame);

	return false;
}

function get_top_href()
{
	var head = document.getElementsByTagName('head')[0];
	var base = head ? head.getElementsByTagName('base')[0] : null;
	var href = (base && base.href) ? base.href : document.location.href;
	return href;
}

function get_top_href_base()
{
	var head = document.getElementsByTagName('head')[0];
	var base = head ? head.getElementsByTagName('base')[0] : null;
	var href = (base && base.href) ? base.href : document.location.href;
	return href.match(/^([^:\/]+:\/\/[^\/]*)/)[1];
}

function get_top_href_path()
{
	var head = document.getElementsByTagName('head')[0];
	var base = head ? head.getElementsByTagName('base')[0] : null;
	var href = (base && base.href) ? base.href : document.location.href;
	return href.match(/^[^:\/]+:\/\/[^\/]*(.*\/)/)[1];
}

function get_script_src()
{
        var script = top.document.getElementById("edit_script");
	if(!script)
	{
		var head = top.document.getElementsByTagName("head")[0];
		script = head.getElementsByTagName("script")[0]
	}

	return (script && script.src) ? script.src : null;
}

function get_script_href_path()
{
	var path;
	var script = get_script_src();

	if(script && script.match(/:/))
		path = script;
	else
		path = top.document.location.href;

	path = path.replace(/[^\/]*$/, '');

	return path;
}

RegExp.escape = function(str)
{
	var specials = new RegExp("[.*+?|()\\[\\]{}\\\\]", "g"); // .*+?|()[]{}\
	return str.replace(specials, "\\$&");
}

function wkn_fix_links(text, path)
{
	var href_base = get_top_href_base();
	// replace local references with internal function calls
	var reg = new RegExp('<a\\s+href="(?:' + RegExp.escape(href_base + path) + ')?([^\\/":]+(?:\\/[^"\\/]+)*(\\/)?)"', 'gi');
	return text.replace(reg, function($0,$1,$2) { return ('<a href="' + $1 + '" onClick="return top.' + ($2 ? 'FileList' : 'FileShow') + '(\'' + path + $1 + '\'); return false;"'); });
}

function FileShow(file, text, content_type, status_code)
{
	// first call. start get file request
	if(text == null && status_code == null && content_type == null)
	{
		get_file_async(file, FileShow);
		return false;
	}

	var file_type;
	if((file_type = file.match(/\.([^\.]+)$/)))
		file_type = file_type[1];

	// if file is not a text file, abort the request redirect to file
	if(null == content_type || null==content_type.match(/^(text\/|application\/javascript$)/))
	{
		if(file_type.match(/^(html?|wiki|htxt|chopro)$/))
			content_type = "text/plain";
		else
		{
			var toolbar = '<input type="button" value="Back" onClick="top.history.back()"/> \
<input type="button" value="Delete" onClick="FileDelete(\'' + file  + '\');"/> \
<input type="button" value="Exit" onClick="FileExit(\'' + file  + '\');"/>';
			var doc = '<iframe src="' + file + '" style="position:absolute;width:100%;height:100%;border:0;" frameborder="0"></iframe>';
			create_tool_doc(toolbar, doc);
			return false;
		}
	}

	// request is not yet complete. continue.
	if(text == null)
		return true;

	if(status_code == 404)
	{
		if(is_edit_on())
		{
			FileEdit(file);
			return false;
		}
		content_type = "text/html";
	}

	var toolbar =
'<input type="button" value="Up" onClick="FileList(\'' + parentdir(file)  + '\');"/> \
<input type="button" value="Edit" onClick="FileEdit(\'' + file  + '\');"/> \
<input type="button" value="Delete" onClick="FileDelete(\'' + file  + '\');"/> \
<input type="button" value="Exit" onClick="FileExit(\'' + file  + '\');"/>';
	var other = '<input type="hidden" id="filepath" value="' + file + '"/>';

	text = FileShowFilter(file, text, content_type);
	var frame = create_full_iframe('file_area', text);

	var toolwin = create_tool_doc(toolbar, frame, other);
	return false;
}

function FileShowDirect(file)
{
	var text = get_file_data(file);
	FileShow(file, text, "text/html");
}

function FileShowFilter(file, text, content_type)
{
	var matches;

	var is_preview = false;

	var href = get_top_href_base() + file;
	var win;

	var file_type;
	if((file_type = file.match(/\.([^\.]+)$/)))
		file_type = file_type[1];


	if(content_type == 'text/html' || file_type == 'html' || file_type == 'htm')
	{
		if(null == text.match(/<head(?:\s+[^>]+)?>/i))
		{
			text = text.replace(/<html>/i, '<html><head></head>');
		}
		// modify page with base href such that relative links will work
		// modify page target to use new window if preview
		var reg = /<base(\s+[^>]+)?>/i;
		if(null != (matches = reg.exec(text)))
		{
			var params = matches[1];
			if(is_preview)
			{
				var params_reg = /\s+target=[^>\s]+/;
				if(null != params_reg.exec(params))
					params = params.substring(0,params_reg.index) + params.substring(params_reg.lastIndex);
				params += ' target="preview_target"';
			}
			if(null == params.match(/\s+href=[^>\s]+/))
				params += (' href="' + href + '"');
			text = text.substring(0,reg.index) + '<base' + params + '>' + text.substring(reg.lastIndex);
		}
		else
		{
			text = text.replace(/<head>/i, '<head><base href="' + href + (is_preview ? '" target="preview_target' :'') + '">');
		}
	}
	else
	{
		text = text.replace(/&/g, '&amp;');
		text = text.replace(/</g, '&lt;');
		text = text.replace(/>/g, '&gt;');
		text = ('<html><head><base href="' + href + (is_preview ? '" target="preview_target' :'') + '"/>' + 
		(file_type != null ? 
			('<script type="text/javascript" src="' + get_script_href_path() + file_type + '.js"></script>') : '') + 
		'</head><body><pre>' + text + '</pre></body></html>');
	}
	return text;
}

function get_uuid()
{
	return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
    return v.toString(16);
}).toUpperCase();
}

function FileWrite(url, content)
{
	var uuid = get_uuid();
	var matches;
	var svnbase;
	var svnpath;
	var url_file_append = '';
	var checked_in_path;

	req = new XMLHttpRequest();
	req.open("PROPFIND", url, false);
	req.send(null);
	// if not found, assume add. will checkout dir.
	if(req.status == 404)
	{
		var matches = url.match(/^(.*)(\/[^\/]+)$/);
		var url_dir = matches[1];
		url_file_append = matches[2];
		req = new XMLHttpRequest();
		req.open("PROPFIND", url_dir, false);
		req.setRequestHeader("Depth", "0");
		req.send(null);
	}
	//alert("propfind2 " + req.responseText);
	if(req.status < 300)
	{
		var responses = req.responseXML.getElementsByTagName("D:multistatus")[0].getElementsByTagName("D:response");
		checked_in_path = responses[0].getElementsByTagName("D:propstat")[0].getElementsByTagName("D:prop")[0].getElementsByTagName("lp1:checked-in")[0];
		if(checked_in_path)
			checked_in_path = checked_in_path.getElementsByTagName("D:href")[0].firstChild.nodeValue;
		svnpath = responses[0].getElementsByTagName("D:propstat")[0].getElementsByTagName("D:prop")[0].getElementsByTagName("lp3:baseline-relative-path")[0];
	}

	if(svnpath)
	{
		svnpath = '/' + svnpath.firstChild.nodeValue + url_file_append;
		svnbase = url.replace(svnpath, '');
	}

	var comment = top.document.getElementById("comment_text").value;
	if(checked_in_path != null && (comment == null || comment == ''))
	{
		top.document.getElementById("comment_span").style.visibility = 'inherit';
		alert('change comment required');
		return;
	}
	top.document.getElementById("comment_text").value = '';
	top.document.getElementById("comment_span").style.visibility = 'hidden';

	if(svnbase)
	{
		var activity = svnbase + "/!svn/act/" + uuid;

		req = new XMLHttpRequest();
		req.open("MKACTIVITY", activity, false);
		req.send(null);
		//alert("mkactivity " + req.responseText);
		if(req.status == 503)
		{
			svnbase = null;
		}
		else if(req.status >= 300)
		{
			alert(req.responseText);
			return false;
		}
	}

	// Not SVN. Just try PUT
	if(svnbase == null)
	{
		req = new XMLHttpRequest();
		req.open("PUT", url, false);
		req.sendAsBinary(content);
		if(req.status >= 300)
		{
			alert(req.responseText);
			return false;
		}
		var data = get_file_data(url);
		return true;
	}

	req = new XMLHttpRequest();
	req.open("PROPFIND", svnbase + '/!svn/vcc/default', false);
	req.send(null);
	if(req.status >= 300)
	{
		alert(req.responseText);
	}
	else
	{
		var responses = req.responseXML.getElementsByTagName("D:multistatus")[0].getElementsByTagName("D:response");
		var default_checked_in = responses[0].getElementsByTagName("D:propstat")[0].getElementsByTagName("D:prop")[0].getElementsByTagName("lp1:checked-in")[0].getElementsByTagName("D:href")[0].firstChild.nodeValue;
	}

	req = new XMLHttpRequest();
	req.open("CHECKOUT", default_checked_in, false);
	req.send("<?xml version=\"1.0\" encoding=\"utf-8\"?><D:checkout xmlns:D=\"DAV:\"><D:activity-set><D:href>" + activity + "</D:href></D:activity-set></D:checkout>");
	var wbl = req.getResponseHeader('Location');

	// send log/comment
	req = new XMLHttpRequest();
	req.open("PROPPATCH", wbl, false);
	req.send('<?xml version="1.0" encoding="utf-8"?><D:propertyupdate xmlns:D="DAV:"><D:set><D:prop><log xmlns="http://subversion.tigris.org/xmlns/svn/">' + comment + '</log></D:prop></D:set></D:propertyupdate>');

	if(req.status >= 300)
		alert(req.responseText);

	req = new XMLHttpRequest();
	req.open("CHECKOUT", checked_in_path, false);
	
	req.send('<?xml version="1.0" encoding="utf-8"?><D:checkout xmlns:D="DAV:"><D:activity-set><D:href>' + activity + '</D:href></D:activity-set></D:checkout>');
	if(req.status >= 300)
		alert("checkout2: " + req.responseText);

	req = new XMLHttpRequest();
	//alert("try PUT " + svnbase + '/!svn/wrk/' + uuid + svnpath);
	req.open("PUT", svnbase + '/!svn/wrk/' + uuid + svnpath, false);
	req.sendAsBinary(content);
	if(req.status >= 300)
		alert(req.responseText);


	req = new XMLHttpRequest();
	req.open("MERGE", activity, false);
	req.send('<?xml version="1.0" encoding="utf-8"?><D:merge xmlns:D="DAV:"><D:source><D:href>' + activity + '</D:href></D:source></D:merge>');
	//req.send('<?xml version="1.0" encoding="utf-8"?><D:merge xmlns:D="DAV:"><D:source><D:href>' + activity + '</D:href></D:source><D:no-auto-merge/><D:no-checkout/><D:prop><D:checked-in/><D:version-name/><D:resourcetype/><D: creationdate/><D:creator-displayname/></D:prop></D:merge>');
	//alert("merge " + req.responseText);

	req = new XMLHttpRequest();
	req.open("DELETE", activity, false);
	req.send(null);

	var data = get_file_data(url);

	return true;
}

function FileUpload(dir)
{
	var file = document.getElementById("fileinput");
	if(file == null || file.files.length == 0)
	{
		alert("no file selected");
		return;
	}
	var content = file.files[0].getAsBinary();
	var filename = file.value;

	if(!dir.match(/\/$/))
	{
		alert("not in directory");
		return;
	}
	if(!FileWrite(dir + filename, content)) return;
	file.value = '';
	FileList(dir);
}

function FileEditCancel()
{
	top.history.back();
}

function FileExit(path)
{
	if(path == null) path = '';
	top.document.location.replace(path);
}

function get_file_async(file, func)
{
	var req = new XMLHttpRequest();
	req.onreadystatechange = function() { 
		var content_type;
		if(req.readState >=2)
			content_type = req.getResponseHeader("Content-Type");
		if (req.readyState==2)
		{
			if(!func(file, null, content_type, req.status))
				req.abort();
		}
		else if(req.readyState==4)
		{
			//alert(" 4 " + req.responseText);
			func(file, req.responseText, content_type, req.status);
		}
	}
	req.open("GET", file, true);
	req.setRequestHeader('Pragma', 'no-cache');
	req.setRequestHeader('Cache-Control', 'no-cache');
	req.send(null);
}

function get_file_data(file)
{
	var req = new XMLHttpRequest();
	req.open("GET", file, false);
	req.setRequestHeader('Pragma', 'no-cache');
	req.setRequestHeader('Cache-Control', 'no-cache');
	req.send(null);
	return (req.status == 404) ? null : req.responseText;
}

function OnPreviewLoad()
{
	var edit_area = document.getElementById("edit-text");
	var preview_frame = document.getElementById("preview_area");
	var doc = frame_document(preview_frame);

	if(doc.body && doc.body.childNodes.length)
	{
		var path = get_filepath();
		doc.body.innerHTML = wkn_fix_links(doc.body.innerHTML, dirname(path));
		edit_area.style.visibility = 'hidden';
		document.getElementById("edit-buttons").style.visibility = 'hidden';
		preview_frame.style.visibility = 'visible';
		document.getElementById("preview-buttons").style.visibility = 'visible';
	}
	else
	{
		preview_frame.style.visibility = 'hidden';
		document.getElementById("preview-buttons").style.visibility = 'hidden';
		edit_area.style.visibility = 'visible';
		document.getElementById("edit-buttons").style.visibility = 'visible';
	}
}

function FileEdit(file)
{
	var text = get_file_data(file);
	if(text == null) text = '';

	text = text.replace(/&/g, '&amp;');
	text = text.replace(/</g, '&lt;');
	text = text.replace(/>/g, '&gt;');

	var toolbar =
'<div style="position:relative"> \
<span id="edit-buttons" style="position:absolute"> \
 <input type="button" value="Save" onClick="top.FileEditSave();"/> \
 <input type="button" value="Preview" onClick="top.FileEditPreview();"/> \
 <input type="button" value="Cancel" onClick="top.FileEditCancel();"/> \
 <span id="comment_span" style="visibility:hidden;"> \
Change comment <input id="comment_text" size="40" type="text"/> \
 </span> \
</span> \
<span id="preview-buttons" style="position:absolute;visibility:hidden;"> \
 <input type="button" value="Save" onClick="top.FileEditSavePreview();"/> \
 <input type="button" value="Close Preview" onClick="top.FileEditClosePreview();"/> \
</span> \
<input type="button" value="" style="visibility:hidden;"/> \
<input type="hidden" id="filepath" value="' + file + '"/> \
</div>';

	var pagedata = 
	'<textarea id="edit-text" style="position:absolute;width:100%;height:100%;">' + text + '</textarea>' +
	'<iframe onload="OnPreviewLoad()" id="preview_area" style="position:absolute;width:100%;height:100%;border:0;visibility:hidden;" frameborder="0"></iframe>';

	create_tool_doc(toolbar, pagedata);

	return false;
}

function FileEditSave()
{
	var text = document.getElementById("edit-text").value;
	var path = get_filepath();
	if(!FileWrite(path, text)) return;
	top.history.go(-1);
//	FileShow(path);
}

function FileEditClosePreview()
{
	var edit_area = document.getElementById("edit-text");
	var preview_frame = document.getElementById("preview_area");
	preview_frame.contentWindow.history.back();
}

function FileEditSavePreview()
{
	var text = document.getElementById("edit-text").value;
	var path = get_filepath();
	if(!FileWrite(path, text)) return;
	top.history.go(-2);
//	FileShow(path);
}

function FileEditPreview()
{
	var text = document.getElementById('edit-text').value;

	var file = get_filepath();

	text = FileShowFilter(file, text);

	var preview_frame = document.getElementById("preview_area");
	var doc = frame_document(preview_frame);

	doc.open("text/html");
	doc.write(text);
	doc.close();
}

function dirname(path)
{
    return path.replace(/\\/g,'/').replace(/\/[^\/]*$/, '/');
}

function parentdir(path)
{
    return path.replace(/\\/g,'/').replace(/\/[^\/]*\/?$/, '/');
}

function FileDelete(file)
{
	var dir = dirname(file);

	if(dir == file)
	{
		alert("Cannot delete directory");
	}
	else if(confirm("Are you sure you wish to delete " + file + "?"))
	{
		var req = new XMLHttpRequest();
		req.open("DELETE", file, false);
		req.send(null);
		if(req.status >= 300)
			alert(req.responseText);

		FileList(dir);
	}
}

function get_filepath()
{
	return document.getElementById('filepath').value;
}

function ShowEdit()
{
	force_edit = true;
        FileList(document.location.pathname);
}

function ShowView()
{
	FileList(document.location.pathname);
}
