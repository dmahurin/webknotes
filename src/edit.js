// Client side only WebDav/SVN/HTTP File/Directory editor

var ERR_Not_Found = '<html><body>404 Not Found</body></html>';

var INDEX_ORDER = { null:999, 'index.html':1, 'index.htm':2, 'index.wiki':3, 'index.htxt':4};

function is_edit_on()
{
	return top.document.getElementById('button_span').style.visibility!='hidden';
}

function FileList(path)
{
	var edit_on = is_edit_on();

	if(path == undefined)
		path = get_filepath();

	var file_area_document = top.frames['file_area'].document;

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

	if(responses == null)
	{
		file_area_document.location.replace(path);
		return;
	}

	var index_page = null;

	var list = [];
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

	if((!edit_on) && index_page != null)
	{
		FileShow(list[index_page]['href']);
		return;
	}

	file_area_document.open("text/html");
	file_area_document.writeln("<html><body>");
	file_area_document.writeln("<h1>Index of " + path + "</h1><hr><pre>");
	file_area_document.writeln('<a href="javascript:top.FileList(\'' + parentdir(path) + '\')">Parent Directory</a><br>');

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
				file_area_document.writeln('<a href="javascript:top.FileList(\'' + href + '\')">' + name + '/</a>');
		}
/*
		else if(null != (href.match(/\.(txt|html?)$/)))
		{
			file_area_document.writeln('<a href="' + href + '">' + name + '</a>');
		}
*/
		else
		{
			file_area_document.writeln('<a href="javascript:top.FileShow(' + "'" + href + "'" + ')">' + name + '</a>');
		}
	}
	file_area_document.write('<input type="hidden" id="button_mode" value="dir"/>');
	file_area_document.write('<input type="hidden" id="filepath" value="' + path + '"/>');
	file_area_document.writeln("</pre><hr></body></html>");
	file_area_document.close();
}

function get_base_href_path()
{
	return top.document.location.href.replace(/^([^\/]*:\/\/[^\/]*).*/, '$1');
}

function get_script_href_path()
{
	var path;
        var script = top.document.getElementById("edit_script");
	if(!script)
	{
		var head = top.document.getElementsByTagName("head")[0];
		script = script.getElementsByTagName("head")[0]
	}

	if(script && script.src && script.src.match(/:/))
		path = script.src;
	else
		path = top.document.location.href;

	path = path.replace(/[^\/]*$/, '');

	return path;
}

function do_link(file)
{
	if(null != file.match(/\/$/))
		FileList(file);
	else
		FileShow(file);

	return false;
}

function my_onload(win)
{
	var head = win.document.getElementsByTagName("head")[0];
	var base = head.getElementsByTagName("base");
	if(base && base[0])
		base = base[0].href.replace(/^[^\/]*:\/\/[^\/]*(.*\/)[^\/]*/, '$1');
	else
		base = '';

	// replace local references with internal function calls
	win.document.body.innerHTML = win.document.body.innerHTML.replace(/<a href="([^":]*)"/g, '<a href="$1" onClick="return top.do_link(\'' + base + '$1\')"');
/*
	var links = win.document.links;
	for(var i=0; i <links.length;i++)
	{
		links[i].setAttribute('onclick',"return top.on_link('" + links[i].href + "');");
	}
*/
}

function FileShow(file, text)
{
	if(file == null)
		file = get_filepath();

	var type;
	var matches;

	if((matches = file.match(/\.([^\.]+)$/)))
		type = matches[1];

	var view_area_document;
	if(top.document.getElementById('file_span').style.visibility == 'hidden')
		view_area_document = top.frames['preview_area'].document;
	else
		view_area_document = top.frames['file_area'].document;

	if(text == null)
		text = get_file_data(file);

	if(is_edit_on() && text == ERR_Not_Found)
	{
		FileEdit(file);
		return;
	}

	var href = get_base_href_path() + file;

	if((type == 'html' || type == 'htm') && file != top.document.location.href && file != top.document.location.pathname)
	{
		view_area_document.open("text/html");
		var head = top.frames['file_area'].document.getElementsByTagName("head")[0];
		var base = head.getElementsByTagName("base")[0];
		if(base == undefined)
		{
			text = text.replace('<html>', '<html><base href="' + href + '">');
		}
		view_area_document.write(text);
		view_area_document.close();
	}
	else
	{
		text = text.replace(/</g, '&lt;');
		text = text.replace(/>/g, '&gt;');
		view_area_document.open("text/html");
		view_area_document.writeln('<html><head><base href="' + href + '"/>');
		if(type != null)
		{
			view_area_document.writeln('<script src="' + get_script_href_path() + type + '.js"></script>');
			view_area_document.writeln("<script type=\"text/javascript\">var other_onload = window.onload;\nfunction new_onload() { if(other_onload) other_onload(); top.my_onload(window); }\nwindow.onload = new_onload; </script>");
		}
		view_area_document.writeln('</head><body><pre>');
		view_area_document.write(text);
		view_area_document.writeln('</pre></body></html>');
		view_area_document.close();
	}
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
			return;
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
			return;
		}
		var data = get_file_data(url);
		return;
	}

/*
	alert(svnbase);
	req = new XMLHttpRequest();
	req.open("PROPFIND", svnbase + '/!svn/vcc/default', false);
	req.send(null);
	alert("propfind1 " + req.responseText);
	var responses = req.responseXML.getElementsByTagName("D:multistatus")[0].getElementsByTagName("D:response");
	var checked_in = responses[0].getElementsByTagName("D:propstat")[0].getElementsByTagName("D:prop")[0].getElementsByTagName("lp1:checked-in")[0].getElementsByTagName("D:href")[0].firstChild.nodeValue;
	alert(checked_in);

	req = new XMLHttpRequest();
	req.open("CHECKOUT", checked_in, false);
	
	req.send("<?xml version=\"1.0\" encoding=\"utf-8\"?><D:checkout xmlns:D=\"DAV:\"><D:activity-set><D:href>" + activity + "</D:href></D:activity-set></D:checkout>");

	alert("checkout1 " + req.responseText);

*/

	req = new XMLHttpRequest();
	req.open("CHECKOUT", checked_in_path, false);
	
	req.send('<?xml version="1.0" encoding="utf-8"?><D:checkout xmlns:D="DAV:"><D:activity-set><D:href>' + activity + '</D:href></D:activity-set></D:checkout>');
	//alert("checkout2: " + req.responseText);

	req = new XMLHttpRequest();
	//alert("try PUT " + svnbase + '/!svn/wrk/' + uuid + svnpath);
	req.open("PUT", svnbase + '/!svn/wrk/' + uuid + svnpath, false);
	req.sendAsBinary(content);
	//alert(req.responseText);

	req = new XMLHttpRequest();
	req.open("MERGE", activity, false);
	req.send('<?xml version="1.0" encoding="utf-8"?><D:merge xmlns:D="DAV:"><D:source><D:href>' + activity + '</D:href></D:source></D:merge>');
	//req.send('<?xml version="1.0" encoding="utf-8"?><D:merge xmlns:D="DAV:"><D:source><D:href>' + activity + '</D:href></D:source><D:no-auto-merge/><D:no-checkout/><D:prop><D:checked-in/><D:version-name/><D:resourcetype/><D: creationdate/><D:creator-displayname/></D:prop></D:merge>');
	//alert("merge " + req.responseText);

	req = new XMLHttpRequest();
	req.open("DELETE", activity, false);
	req.send(null);

	var data = get_file_data(url);
}

function FileUpload()
{
	var file = top.frames['button_area'].document.getElementById("fileinput");
	if(file == null || file.files.length == 0)
	{
		alert("no file selected");
		return;
	}
	var content = file.files[0].getAsBinary();
	var filename = file.value;
	var dir = get_filepath();

	if(!dir.match(/\/$/))
	{
		alert("not in directory");
		return;
	}
	FileWrite(dir + filename, content)
	file.value = '';
	FileList(dir);
}

function FileEditCancel()
{
	top.frames['file_area'].history.back();
}

function get_file_data(file)
{
	var req = new XMLHttpRequest();
	req.open("GET", file, false);
	req.setRequestHeader('Cache-Control', 'no-cache');
	req.send(null);
	var data;
	if(is_edit_on() && req.status == 404)
		data = ERR_Not_Found;
	else
		data = req.responseText;
	return data;
}

function FileEdit(file)
{
	if(file == null)
		file = get_filepath();

	var data = get_file_data(file);
	if(data == ERR_Not_Found) data = '';

	var mimetype = top.frames['file_area'].document.contentType;
	if( mimetype == undefined )
		mimetype = top.frames['file_area'].document.mimeType;

	var pagedata = '<html>' +
	'<body><form id="edit-form">' +
	'<textarea id="edit-text" style="width:100%;height:100%">' + data + '</textarea></form>' +
	'<input type="hidden" id="button_mode" value="edit"/>' + 
	'<input type="hidden" id="filepath" value="' + file + '"/>' +
	'<input type="hidden" id="mimetype" value="' + mimetype + '"/>' +
	'</body></html>';

	top.frames['file_area'].document.open("text/html");
	top.frames['file_area'].document.write(pagedata);
	top.frames['file_area'].document.close();
}

function FileEditSave()
{
	var text = top.frames['file_area'].document.getElementById("edit-text").value;
	var path = get_filepath();
	FileWrite(path, text);
	top.frames['file_area'].history.back();
//	top.frames['file_area'].location.replace(path);
}

function FileEditClosePreview()
{
	top.frames['file_area'].history.back();
}

function FileEditSavePreview()
{
	var text = top.frames['file_area'].document.getElementById("edit-text").value;
	var path = get_filepath();
	FileWrite(path, text);
	top.frames['file_area'].history.go(-2);

//	top.frames['file_area'].location.replace(path);
}

function FileEditPreview()
{
	var mimetype = top.frames['file_area'].document.getElementById("mimetype").value;
	var text = top.frames['file_area'].document.getElementById("edit-text").value;
	top.document.getElementById('file_span').style.visibility='hidden';
	top.document.getElementById('preview_span').style.visibility='visible';

	var file = get_filepath();

	FileShow(file, text);
}

function dirname(path)
{
    return path.replace(/\\/g,'/').replace(/\/[^\/]*$/, '/');
}

function parentdir(path)
{
    return path.replace(/\\/g,'/').replace(/\/[^\/]*\/?$/, '/');
}

function DirUp()
{
	FileList(parentdir(get_filepath()));
}

function FileDelete()
{
	var file = get_filepath();
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

function get_buttonmode()
{
	if(top.document.getElementById('preview_span').style.visibility == 'visible')
		return "preview"; 

	var button_mode = top.frames['file_area'].document.getElementById('button_mode');

	if(!top.frames['file_area'].document.body.childNodes.length)
		return undefined;
	else if(button_mode)
		return button_mode.value;
/*
	else if(null != top.frames['file_area'].document.location.href.match(/\/$/))
		return "dir";
*/
	else
		return "file";
}

function get_filepath()
{
	var path = top.frames['file_area'].document.getElementById('filepath');
	var head = top.frames['file_area'].document.getElementsByTagName("head")[0];
	var base = head.getElementsByTagName("base");

	// non-file-preview/show windows will have filepath set
	if(path)
		return path.value;
	// if base href is specified and not directory, assume file path
	else if(base && base[0] && base[0].href && null == base[0].href.match(/\/$/))
		return base[0].href.replace(/^[^\/]*:\/\/[^\/]*/, '');
	// otherwise it is a normal file show. use the location path
	else
		return top.frames['file_area'].document.location.pathname;
}

function load_buttons(button_group)
{
	var button_area_document = top.frames['button_area'].document;
	var prev_button_group = button_area_document.getElementById("prev_button_group");

	if(prev_button_group != undefined && prev_button_group.value != '')
	{
		prev_button_group = prev_button_group.value;
		if(button_group != prev_button_group)
		{
			button_area_document.getElementById(prev_button_group).style.visibility = 'hidden';
			if(button_group != null)
				button_area_document.getElementById(button_group).style.visibility = 'visible';
			button_area_document.getElementById('prev_button_group').value = button_group;
		}
		return;
	}

	top.frames['button_area'].document.open("text/html");
	top.frames['button_area'].document.write('\
<html><body> \
<form id="file_buttons" style="position:absolute;visibility:hidden"> \
<input type="button" value="Up" onClick="top.DirUp();"/> \
<input type="button" value="Edit" onClick="top.FileEdit();"/> \
<input type="button" value="Delete" onClick="top.FileDelete();"/> \
<input id="prev_button_group" type="hidden" /> \
</form> \
<form id="dir_buttons" style="position:absolute;visibility:hidden"> \
<input type="button" value="Up" onClick="top.DirUp();"/> \
<input id="fileinput" type="file" /> \
<input type="button" value="Add" onClick="top.FileUpload();"/> \
</form> \
<form id="edit_buttons" style="position:absolute;visibility:hidden"> \
<input type="button" value="Save" onClick="top.FileEditSave();"/> \
<input type="button" value="Preview" onClick="top.FileEditPreview();"/> \
<input type="button" value="Cancel" onClick="top.FileEditCancel();"/> \
</form> \
<form id="preview_buttons" style="position:absolute;visibility:hidden"> \
<input type="button" value="Save" onClick="top.FileEditSavePreview();"/> \
<input type="button" value="Close Preview" onClick="top.FileEditClosePreview();"/> \
</form> \
</body></html>');
	top.frames['button_area'].document.close();

	if(button_group != null)
		button_area_document.getElementById(button_group).style.visibility = 'visible';
	button_area_document.getElementById('prev_button_group').value = button_group;
}

function load_file_buttons()
{
	load_buttons('file_buttons');
}

function load_preview_buttons()
{
	load_buttons('preview_buttons');
}

function OnFramesLoad()
{
	if(!top.frames['file_area'].document.body.childNodes.length)
	{
		FileList(dirname(top.document.location.pathname));
	}
}

function OnLoadPath(mode)
{
	OnFramesLoad();

	if(!top.frames['file_area'].document.body.childNodes.length)
		return;

	if(mode == null)
		mode = get_buttonmode();

	if(mode != undefined && mode != '')
	{
		load_buttons(mode + "_buttons");
	}
}

function OnPreviewLoad()
{
        if(!top.frames['preview_area'].document.body.childNodes.length)
	{
                top.document.getElementById('preview_span').style.visibility='hidden';
		top.document.getElementById('file_span').style.visibility='visible';
	}
	OnLoadPath();
}

function ShowEditFrames()
{
	document.body.innerHTML =
	'<span id="button_span" style="position:absolute;left:0px;top:0px;width:100%;height:50px"aaaa>' +
	'<iframe style="position:absolute;width:100%;height:100%" name="button_area" id="button_area" frameborder="0"> </iframe>' +
	'</span>' +
	'<span id="file_span" style="position:absolute;left:0px;top:50px;right:0px;bottom:0px">' +
	'<iframe style="position:absolute;width:100%;height:100%" name="file_area" id="file_area" frameborder="0" onload="OnLoadPath()"></iframe>' +
	'</span>' +
	'<span id="preview_span" style="position:absolute;left:0px;top:50px;right:0px;bottom:0px;visibility:hidden">' +
	'<iframe style="position:absolute;width:100%;height:100%" name="preview_area" id="file_area" frameborder="0" onload="OnPreviewLoad()"></iframe>' +
	'</span>';
}

function ShowViewFrames()
{
	document.body.innerHTML =
	'<span id="button_span" style="position:absolute;left:0px;top:0px;right:0px;bottom:0px;visibility:hidden">' +
	'<iframe style="position:absolute;width:100%;height:100%" name="button_area" id="button_area" frameborder="0"> </iframe>' +
	'</span>' +
	'<span id="file_span" style="position:absolute;left:0px;top:0px;right:0px;bottom:0px">' +
	'<iframe style="position:absolute;width:100%;height:100%" name="file_area" id="file_area" frameborder="0" onload="OnLoadPath()"></iframe>' +
	'</span>' +
	'<span id="preview_span" style="position:absolute;left:0px;top:0px;right:0px;bottom:0px;visibility:hidden">' +
	'<iframe style="position:absolute;width:100%;height:100%" name="preview_area" id="file_area" frameborder="0" onload="OnPreviewLoad()"></iframe>' +
	'</span>';
}
