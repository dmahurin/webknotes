#!/usr/bin/perl
use strict;
no strict 'refs';


print "Content-type: text/html\n\n";

if( $0 =~ m:/[^/]*$: ) {  push @INC, $` }

require 'wkn_define.pl';
require 'wkn_lib.pl';


my(@args) = split('&', $ENV{QUERY_STRING});
my($notes_path_encoded) = shift(@args);
my ($this_script_prefix, $target);
if($notes_path_encoded =~ m:^target=:) 
{
   $this_script_prefix .= "target=$'&";
   $target = "target=\"$'\"";
   $notes_path_encoded = shift(@args);
}

my($notes_path) = &wkn::path_check(&wkn::url_unencode_path($notes_path_encoded));
exit(0) unless(defined($notes_path));

$notes_path =~ m:([^/]*)$:;
my $notes_name = $1;

my $OPENED_SYMBOL = &wkn::text_icon($wkn::define::file_icon_text, 
                   $wkn::define::file_icon);
my $CLOSED_SYMBOL = &wkn::text_icon($wkn::define::file_icon_text, 
                   $wkn::define::closed_icon);
my $FILE_SYMBOL = &wkn::text_icon($wkn::define::file_icon_text, 
                   $wkn::define::file_icon);
my $DIR_SYMBOL = &wkn::text_icon($wkn::define::file_icon_text, 
                   $wkn::define::dir_icon);

print <<"EOT";
<html>
  <head>
    <title>js menu</title>
    <base $target>
  </head>

  <body>
    <script language="JavaScript">
    <!-- hide from browsers without js enabled

      //SET A NEW COOKIE
      //Arguments:
      //  name: cookie name (string)
      //  value: cookie value (unencoded string)
      //  expiry: expiry date (date)
      //  path: document path (string)
      //  domain: document domain (string)
      //  secure: secure required? (boolean)
      
      function setCookie(name,value,expiry,path,domain,secure)
      {
        var nameString = name + "=" + value;
        var expiryString = (expiry == null) ? "" : ";expires="
          + expiry.toGMTString();
        var pathString = (path == null) ? "" : ";path=" + path;
        var domainString = (path == null) ? "" : ";domain=" + domain;
        var secureString = (secure) ? ";secure" : "";
      
        document.cookie = nameString + expiryString + pathString
                          + domainString + secureString;
      }

      //GET A NEW COOKIE
      //Arguments:
      //  name: cookie name (string)
    
      function getCookie(name)
      {
        var cookieFound = false;
        var start = 0;
        var end = 0;
        var cookieString = document.cookie;
      
        var i = 0;
      
        //LOOK FOR name IN cookieString
        while (i <= cookieString.length)
        {
          start = i;
          end = start + name.length;
          if (cookieString.substring(start,end) == name)
          {
            cookieFound = true;
            break;
          }
          i++;
        } 

        //CHECK IF NAME WAS FOUND
        if (cookieFound)
        {
          start = end + 1;
          end = cookieString.indexOf(";",start);
          if (end < start)
            end = cookieString.length;
          return unescape(cookieString.substring(start,end));
        }

        //NAME WAS NOT FOUND
        return "";
      }

      //DELETE A COOKIE
      //Arguments:
      //  name: cookie name (string);

      function deleteCookie(name)
      {
        var expires = new Date();
        expires.setTime (expires.getTime() - 1);
    
        setCookie(name,"Delete Cookie",expires,null,null,false);
      }

      // MENU MANAGER STARTS HERE
      var open = "o";
      var closed = "c";
      var pointers = new Array();
      var toExpire = new Date();
      toExpire.setTime(toExpire.getTime() + 1000*60*60*24);
    
      function sectionObj()
      {
        this.section = new Array();
        this.title = "";
        this.link = "";
        this.display = displaySection;
        this.open = doOpen;
        this.close = doClose;
        pointers[pointers.length] = this;
        this.number = pointers.length - 1;
        if (this.number >= menu.statusString.length)
        {
          menu.statusString +=closed;
        }
        this.status = menu.statusString.charAt(this.number);
      }

      function doExplode ()
      {
        setCookie ("oiWin", "exploade", toExpire, null, null, false);
      }

      function doJoin ()
      {
        setCookie ("oiWin", "join", toExpire, null, null, false);
      }

      function doOpen()
      {
        this.status = open;
        menu.statusString = "";
        for (k = 0; k < pointers.length; k ++)
        {
          menu.statusString += pointers[k].status;
        }
        setCookie(menu.name,menu.statusString,toExpire,null,null,false);
        self.location = self.location;
      }

      function doClose()
      {
        this.status = closed;
        menu.statusString = "";
        for (k = 0; k < pointers.length; k ++)
        { 
          menu.statusString += pointers[k].status;
        }
        setCookie(menu.name,menu.statusString,toExpire,null,null,false);
        self.location = self.location;
      }
      
      function expandAll ()
      {
        var i;
        for (i = 0; i < menu.section.length; i++)
        {
          menu.section[i].open();
        }
        document.write ('<h1>Running Expand all.</h1>');
      }
    
      function collapseAll ()
      {
        var i;
        for (i = 0; i < pointers.length; i++)
        {
          pointers[i].close();
        }
      }
     
      function displaySection()
      {
        if (this.status == open)
        {
          document.write('<td valign=top>');
          if (this.section.length > 0)
          {
            toprint = '<a href="javascript:pointers[' + this.number
            + '].close()"target="_self">$OPENED_SYMBOL</a></td>' +
'<td>' +
//'<a href="javascript:pointers[' + this.number
//+ '].close()"target="_self">' 
'<a href="' + this.link + '">'
+ this.title + '</a>'; 
          }
          else
          {
            toprint = '$FILE_SYMBOL</td>' +
              '<td><a href="' + this.link +
//              '" target="' + this.target + '">' +
	      '">' + this.title + '</a>';
//              '<td>' + this.title;
          }
          document.write (toprint); 

	  if (this.section.length > 0)
	  {
	    document.write ('<table border=0>');
	    var j = 0;
	    for (j = 0; j < this.section.length; j ++)
	    {
	      document.write ('<tr>');
	      this.section[j].display();
	      document.write ('</tr>');
	    }
	    document.write ('</table>');
	  }

	  document.write ('</td>');
        }
        else
        {
          document.write('<td valign=top>');
          if (this.section.length > 0)
          {

            toprint = '<a href="javascript:pointers[' + this.number
+ '].open()" target="_self">$CLOSED_SYMBOL</a></td>' +
'<td>' +
//'<a href="javascript:pointers[' + this.number + '].open()" target="_self">'
'<a href="' + this.link + '">'
+ this.title + '</a>';
          }
          else
          {
            toprint = 
              '$FILE_SYMBOL</td>' +
              '<td><a href="' + this.link + 
//'" target="' + this.target +
              '">' + this.title + '</a>';
//              '<td>' + this.title;
          }
          document.write(toprint, '</td>');
        }
      }

      function menuObj(menuName)
      {
        this.statusString = getCookie(menuName);
        this.name = menuName;
        this.section = new Array();
        this.title = "";
        this.display = displayMenu;
        this.close = doClose;
        this.expand = expandAll;
        this.collapse = collapseAll;
      }
      
      function winObj (winName)
      {
        this.statusString = getCookie ("oiWin");
        this.name = "oiWin";
        this.title = ""
        this.display = displayWin;
        this.join = doJoin;
        this.explode = doExplode;
      }

      function displayWin ()
      {
        if (this.statusString == "join")
        {
          document.write ('[<a href="contentIndex.html" target="_top"',
                          'onClick = "javascript:pointers[', this.number,
	                  '].explode()">', 'Explode</a>]');
        }
        else
        {
          document.write ('[<a href="index.html"',
                          'onClick = "javascript:pointers[', this.number,
                          '].join()">', 'Join</a>]');
        }
      }

      function initMenu(numSections)
      {
        for (i = 0; i < numSections; i++)
        {
          this.section[i] = new sectionObj();
        }
      }

      function displayMenu()
      {
        document.write ('<table border=0>');
        for (i = 0; i < this.section.length; i ++)
        {
          document.write ('<tr>');
          this.section[i].display();
          document.write ('</tr>');
        }
        document.write ('</table>');
      }

    var window = new winObj ("oiWindow");
    var menu = new menuObj("OImenu");
    menu.title = "OpenIdeas";

EOT
# now populate the menu with the directories

my($toppath) = "$auth::define::doc_dir";
$toppath .= "/$notes_path" if( $notes_path ne "");

my($notes_base) = $notes_path eq "" ? "" : "$notes_path/";

if(-d $toppath)
{
   my $depth = 1;
   
   my @dirs = ( "" );
   my @counts = ( );
   my $count = 0;
   opendir("DIR0", $toppath) or print "Error opening top notes dir\n";

   while( @dirs )
   {
      #done with a directory
      my $filename = readdir("DIR$#dirs");
      unless(defined($filename))
      {
         closedir("DIR$#dirs");
         pop(@dirs);
         $count = pop(@counts) + 1;
         $depth--;
         next;
      }

      next if ($filename eq 'README' or 
         $filename =~ m:^(README|index)\.(txt|html|htm)$: );
      next if ($filename =~ m:(\.bak|~)$:);

      my($name) = $filename;
      $name = wkn::define::filename_filter($filename) if defined(&wkn::define::filename_filter);
      next unless ( defined($name));

      my $fullpath = $dirs[$#dirs] ne "" ? "$dirs[$#dirs]/$filename" : $filename;
      my $encoded_notes_path = wkn::url_encode_path("$notes_base$fullpath");

      next if ( defined($wkn::define::skip_files) and $filename =~ m/$wkn::define::skip_files/);

      my $struct_prefix = "menu";
      for $count(@counts, $count)
      {
         $struct_prefix .= ".section[${count}]";
      }

      my $link;
      # Dir, traverse down it
      if (-d "$toppath/$fullpath")
      {
         $link = "browse_plain.cgi?$encoded_notes_path";
         if(defined($wkn::define::max_depth) and $depth >= $wkn::define::max_depth)
         {
            if( opendir(DIRMAX, "$toppath/$fullpath") )
            {
               my ($count, $dir ) = ( 0 );
               while(defined($dir = readdir(DIRMAX)))
               { $count++ if($dir =~ m:^[^\.]:); }
               close(DIRMAX);
               $name .= " ($count)";
            }
            $count++;
         }
         else
         {
            $depth++;
            push(@counts, $count);
            $count = 0;
            push(@dirs, $fullpath);
            opendir("DIR$#dirs", "$toppath/$fullpath") or
               print "Cannot open dir: $fullpath\n";
         }
       }
       elsif($name =~ m:\.(html|txt)$:)
       {
          $name = $`;
          $link = "browse_plain.cgi?$encoded_notes_path";
            $count++;
       }
       else
       {
          $link = "$auth::define::doc_wpath/$encoded_notes_path";
            $count++;
       }
      print "$struct_prefix = new sectionObj();\n";
      print "${struct_prefix}.title = '$name';\n";
      print "${struct_prefix}.link = '$link';\n";
   }
}

my $back_link;
if($notes_name)
{
   $notes_path =~ m:([^/]*)$:;
   $back_link = "<a href=\"browse_js.cgi?" . &wkn::url_encode_path($`) ."\">[&lt;-]</a>";
}
else
{
   $notes_name = "Main";
   $back_link = '[/]';
}

print <<"EOT";
// End script hiding-->
   </script>
${back_link}<a href="browse_plain.cgi?$notes_path_encoded">$notes_name</a><br>
   <script language="JavaScript">
   <!-- Hide from browsers without js enabled;
   menu.display();
   // End script hiding -->
   </script>
   <NOSCRIPT>
   <hr>
   Your browser does not have JavaScript enabled.
   <p>See <a href="browse_help.cgi">other browse method</a> instead.
   </NOSCRIPT>
</body>
</html>
EOT
