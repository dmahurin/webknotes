function get_line_chords(line, chord_positions) {
	var line_chords = [[], []];
	if(chord_positions === undefined) {
		return [[], [line]];
	}

	var [pos, chord] = chord_positions.shift()
	var phrase = line.substring(0, pos);
	if(pos != 0) {
		line_chords[0].push('');
		line_chords[1].push(phrase);
	}

	while(chord_positions.length) {
		var [next_pos, next_chord] = chord_positions.shift()
		phrase = line.substring(pos,next_pos);
		line_chords[0].push([chord]);
		line_chords[1].push([phrase]);
		chord = next_chord;
		pos += phrase.length;
	}
	phrase = line.substring(pos);
	line_chords[0].push([chord]);
	line_chords[1].push([phrase]);
	return line_chords;
}

function chords2html(text)
{
	text = text.replace(/^<pre>/i, '');
	text = text.replace(/<\/pre>$/i, '');
	var lines = text.split("\n");
	var chord_positions = [];
	var line_chord = [];
	var lines_chords = [];

	// A B#m C(text) (text)D E#maj/F#min G7
	for (var line of lines) {
		var regex = /^(\s*(\([^\s\)]+\))?[ABCDEFG]#?(b|m|maj|min|sus)?[2-9]?([\/\-][ABCDEFG]#?(b|m|maj|min|sus)?[2-9]?)?(\([^\s\)]+\))?(?=\s|$))+\s*$/;
		if(regex.test(line)) {
			if(chord_positions.length) {
				lines_chords.push(get_line_chords('', chord_positions));
			}
			chord_positions = [];
			pos = line.match(/^(\s*)/)[0].length;
			line = line.substring(pos);
			while(line != '') {
				chord = line.match(/^(\S*\s*)/)[1]
				chord_positions.push([pos, chord]);
				n = chord.length
				pos += n;
				line = line.substring(n);
			}
		} else if(chord_positions.length) {
			lines_chords.push(get_line_chords(line, chord_positions));
			chord_positions = [];
		} else {
			lines_chords.push(get_line_chords(line));
		}
	}
	if(chord_positions.length) {
		lines_chords.push(get_line_chords(line));
	}

	text = '';
	var td_style = 'white-space: pre; padding-left: 0px; padding-right: 0px';
	for(var line_chords of lines_chords) {
		if(line_chords[0].length == 0 && line_chords[1].length == 1) {
			var line = line_chords[1][0];
			var m;
			if(m = line.match(/(.*[^\*])\s*([\*]+)/)) {
				var h = h > 3 ? 1 : 4 - m[2].length;
				line = '<h'+h+'>'+m[1]+'</h'+h+'>';
			} else if(m = line.match(/^\[(.*)\]$/)) {
				line = '<i>' + m[1] + '</i><br>';
			} else if(m = line.match(/^\s*$/)) {
				line += '<p>';
			} else {
				line = line + '</br/>';
				console.log(line);
			}
			text += line;
			continue;
		}
		text += '<table border=0" cellspacing=0><tr><td style="'+td_style+'"><b>';
		text += line_chords[0].join('</b></td><td style="'+td_style+'"><b>');
		text += '</b></tr><td style="'+td_style+'">';
		text += line_chords[1].join('</td><td style="'+td_style+'">');
		text += '</td></tr></table>';
	}
	return text;
}

function convert()
{
	document.body.innerHTML = chords2html(document.body.innerHTML);
}

window.onload = convert;
