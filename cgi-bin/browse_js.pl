#!/usr/bin/perl
use strict;
package browse_js;
no strict 'refs';

sub show_page
{
   my($path) = @_;

my $target_line;
if($view::view_mode{"target"})
{
   $target_line = "target=\"" . $view::view_mode{"target"} . "\"";
}

my $head_tags = view::get_style_head_tags();

print <<"EOT";
<html>
  <head>$head_tags
    <title>js menu</title>
    <base $target_line>
  </head>
  <body class=\"topic-listing\">
EOT
  show($path);
print <<"EOT";
</body>
</html>
EOT
}

sub show
{
   my($notes_path) = @_;
   unless( auth::check_current_user_file_auth( 'r', $notes_path ) )
   {
      print "You are not authorized to access this path.\n";
      return(0);
   }

$notes_path =~ m:([^/]*)$:;
my $notes_name = $1;

my ($this_bprefix, $this_bsuffix) = view::get_cgi_prefix();
&view::unset_view_mode("target"); # don't want to pass target to main script

&view::set_view_mode("superlayout", "framed");

my ($script_prefix, $bsuffix) = view::get_cgi_prefix();

my $OPENED_SYMBOL = &view::file_type_icon_tag('opened', '[-]'); 
my $CLOSED_SYMBOL = &view::file_type_icon_tag('closed', '[+]'); 
my $FILE_SYMBOL = &view::file_type_icon_tag('file', '[o]'); 
my $DIR_SYMBOL = &view::file_type_icon_tag('dir', '[o]'); 

print <<"EOT";
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
        setCookie ("jsWin", "exploade", toExpire, null, null, false);
      }

      function doJoin ()
      {
        setCookie ("jsWin", "join", toExpire, null, null, false);
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
        this.statusString = getCookie ("jsWin");
        this.name = "jsWin";
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

    var window = new winObj ("jsWindow");
    var menu = new menuObj("jsMenu");
    menu.title = "JavaScript menus";

EOT
# now populate the menu with the directories

my($toppath) = "$filedb::define::doc_dir";
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
      next if($filename =~ m:^\.:);
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
      $name = view::define::filename_filter($filename) if defined(&view::define::filename_filter);
      next unless ( defined($name));

      my $fullpath = $dirs[$#dirs] ne "" ? "$dirs[$#dirs]/$filename" : $filename;
      my $encoded_notes_path = view::url_encode_path("$notes_base$fullpath");

      next if ( defined($view::define::skip_files) and $filename =~ m/$view::define::skip_files/);

      my $struct_prefix = "menu";
      for $count(@counts, $count)
      {
         $struct_prefix .= ".section[${count}]";
      }

      my $link;
      # Dir, traverse down it
      if (-d "$toppath/$fullpath")
      {
         $link = $script_prefix . $encoded_notes_path . $bsuffix;
         if(defined($view::define::max_depth) and $depth >= $view::define::max_depth)
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
          $link = $script_prefix . $encoded_notes_path . $bsuffix;
            $count++;
       }
       else
       {
          $link = "$filedb::define::doc_wpath/$encoded_notes_path";
            $count++;
       }
      print "$struct_prefix = new sectionObj();\n";
      $name =~ s:':' + "'" + ':g;
      print "${struct_prefix}.title = '$name';\n";
      print "${struct_prefix}.link = '$link';\n";
   }
}

my $back_link;
if($notes_name)
{
   $notes_path =~ m:([^/]*)$:;
   $back_link = "<a target=\"_self\" href=\"$this_bprefix" . &view::url_encode_path($`) . 
   $this_bsuffix . "\">[&lt;-]</a>";
}
else
{
   $notes_name = "Main";
   $back_link = '[/]';
}

my($notes_query_string) = view::get_query_string();


print <<"EOT";
// End script hiding-->
   </script>
${back_link}<a href="$script_prefix$notes_path$bsuffix">$notes_name</a><br>
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
EOT
return  1;
}
1;
