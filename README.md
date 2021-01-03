# WebKNotes

*WebKNotes* is a dynamic web based Knowledge database.

WebKNotes 2 is a rewrite of WebKNotes 1 in Javascript, with the entire implementation existing on the client side.

Features of WebKNotes
* Files can be created and edited, and deleted.</li>
* Uses WebDAV or WebDAV+DeltaV (SVN) for file access. No server modification required.
* Fallback implementation requires only HTTP GET for directory/file read, and HTTP PUT for write.
* User Authentication is performed by HTTP server usual authentication.</li>
* Client side markup translation for custom formats including .wiki, .htxt, .chopro.</li>
* Bookmarklets are provided to allow use of WebKNotes 2 without installation.</li>

The provided bookmarklets allow editing an arbitrary web page with no setup, other than WebDAV/Delta-V or HTTP PUT support and access.

Future enhancements:
* Directory creation and removal.
* More Delta-V/SVN support.
* Search support using WebDAV Search/DASL
* Theming
