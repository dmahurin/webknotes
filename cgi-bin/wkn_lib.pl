#!/usr/bin/perl
# main WebKNotes functions

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require 'wkn_define.pl';
require 'auth_lib.pl';

my $img_border = " border=0 hspace=3";

package wkn;

my %view_mode; # used to store layout, theme, and target of wkn sessions

my @current_args; # 

sub url_encode_path
{
   my($path) = @_;
   my ($skip, $after);
   if($path =~ m:(\.cgi\??):) # don't encode cgi? and # #a name refs
   {
      $path = $`;
      $skip = $&;
      $after = $';
      return url_encode_path0($path) . $skip . url_encode_cgipath($after);
   }
   else
   {
      return url_encode_path0($path);
   }
}


sub url_encode_name
{
  my($name) = @_;
  $name =~s/([^\w\.\~\-\_])/sprintf("%%%02lx", unpack('C',$1))/ge;
  return $name;
}
sub url_encode_path0
{
  my($name) = @_;
  $name =~s/([^\w\.\~\-\_\/\#])/sprintf("%%%02lx", unpack('C',$1))/ge;
  return $name;
}
sub url_encode_cgipath
{
  my($name) = @_;
  $name =~s/([^\&\=\w\.\~\-\_\/\#])/sprintf("%%%02lx", unpack('C',$1))/ge;
  return $name;
}


sub url_unencode_path
{
   my($path) = @_;
   $path=~s/%(..)/pack("c",hex($1))/ge;
   return $path;
}

sub url_encode_paths
{
   my(@out) = ();
   foreach(@_)
   {
      push(@out,wkn::url_encode_path($_));
   }
   return @out;
}

sub url_unencode_paths
{
   my(@out) = ();
   foreach(@_)
   {
      push(@out,wkn::url_unencode_path($_));
   }
   return @out;
}

sub get_query_string
{
   if(defined($ENV{QUERY_STRING}))
   {
      return $ENV{QUERY_STRING};
   }
   else
   {
      return join('&', url_encode_paths(@ARGV));
   }
}

sub get_query_args
{
   if(defined($ENV{QUERY_STRING}))
   {
      return url_unencode_paths(split(/\&/, $ENV{QUERY_STRING}));
   }
   else
   {
      return @ARGV;
   }
}

sub strip_view_mode_args
{
   my(@args);
   my $arg;
   foreach $arg (@_)
   {
# below strips off trailing '/', and breaks list2
#      $arg = auth::path_check($arg);
      if($arg =~ /^(theme|layout|target|frame)=/)
      {
         $wkn::view_mode{$1} = $';
      }
#some temporary hackery to make path= arg work
      elsif($arg =~ /^path=/)
      {
         push(@args, $');
      }
      else
      {
         push(@args, $arg);
      }
   }
   return @args;
}

sub get_args
{
   return wkn::strip_view_mode_args(wkn::get_query_args());
}

sub actions1
{
   my( $notes_path ) = @_;
}

sub actions2
{
   my($notes_path) = @_;

   my($is_dir);

   my($dir_file);
   if ( -f "$auth::define::doc_dir/$notes_path" )
   {
      $dir_file = $notes_path;
      $notes_path =~ s:(/|^)[^/]+$::;
   }
   else
   {
      if( ! defined( $dir_file = &wkn::dir_file(${notes_path})))
      {
         $dir_file = "$notes_path/README.html";
      }
      $is_dir = 1;
   }
   $notes_path .= '/' if($notes_path ne "");

   my($notes_path_encoded) = url_encode_path($notes_path);
   $dir_file = url_encode_path($dir_file);

   if( $is_dir )
   {
      print "[ <A HREF=\"add_topic.cgi?notes_path=${notes_path_encoded}\">Add</A> ]\n";
      #if(auth::check_current_user_file_auth( 'd', $notes_path))
      #{
      #print "[ <A HREF=\"delete.cgi?$notes_path\">Delete</A> ]\n";
      #}
      #if(auth::check_current_user_file_auth('u', $notes_path))
      #{
      #print "[ <A HREF=\"upload.cgi?notes_path=${notes_path}\">Upload</A> ]\n";
      #}
      #      if(auth::check_current_user_file_auth( 'p', $notes_path))
      #{
      #print "[ <A HREF=\"permissions.cgi?path=${notes_path}\">Access</A> ]\n";
      #}
   }
   
      print "[ Edit \n";
   if(auth::check_current_user_file_auth('m', $notes_path))
   {
      print "<A HREF=\"edit.cgi?file=$dir_file\">File</a> | \n";
   }
      print "<A HREF=\"browse_edit.cgi?$notes_path_encoded\">Directory</a> ]\n";
   print "[ Browse ";
   print "<A HREF=\"$auth::define::doc_wpath/${notes_path_encoded}\">Directory</A> | \n";
   print "<A HREF=\"$auth::define::doc_wpath/$dir_file\">File Only</A> \n";
   print "| <A HREF=\"" . &wkn::get_cgi_prefix("layout_theme.cgi") . "path=$notes_path_encoded\">Layout/Theme</A> ]\n";
   #   print "<br>\n";
}

sub actions3
{
        my( $notes_path ) = @_;

	if ( $notes_path eq "" )
	{
		$notes_dir ="";
	}
	else
	{      
		$notes_path = url_encode_path($notes_path);
		# /,non-/'s,/* 
		$parent_notes = $notes_path;
		$parent_notes =~ s:(^|/)[^/]*/?$::;

                $parent_notes_ref = 
                   &wkn::get_cgi_prefix() .
                   $parent_notes;
		$notes_dir = "$notes_path/";
print "[ <A HREF=\"${parent_notes_ref}\"> Parent topic</A> ]\n";
	}
	print <<EOT;
[ <A HREF="search.cgi?notes_mode=$wkn::define::mode&notes_subpath=${notes_path}">Search</A> ]
[ <A HREF="user_access.cgi"> User Accounts </a> ]
EOT
}

sub print_link_html
{
	my( $notes_path ) = @_;
        my($found) = 0;

	if( $notes_path eq "" )
	{
		$real_path=$auth::define::doc_dir;
		$file = "";
		$notes_wpath ="";
		$web_path=$auth::define::doc_wpath;
	}
	else
	{
		$real_path="$auth::define::doc_dir/$notes_path";
		$notes_path =~ m:([^/*]*)$:;
		$file = $1;
		$notes_wpath = url_encode_path($notes_path);
		$web_path="$auth::define::doc_wpath/${notes_wpath}";
	}

        return if(defined($wkn::define::skip_files) and $file =~ m/$wkn::define::skip_files/ ); 
        $file = &wkn::define::filename_filter($file) if(defined(&wkn::define::filename_filter));
	if ( -f $real_path )
	{
		$file_base = $file;
		$file_base =~ s/\.[^\.]*$//;
		$file_ext = $&;
		$file_ext =~ s/^\.*$//;
		SWITCH:
		{
			last SWITCH if ($file =~ m/^\./ );
                        last if ($filename eq 'README' or
                           $filename =~ m:^(README|index)\.(txt|html|htm)$: );
#			$file_ext =~ /^\.html/ && do
#			{
#				print "<A HREF=\"${web_path}",
#				"\">${file_base}",
#				"</A>(h)\n";
#				last SWITCH;
#			};
			$file_ext =~ /^\.url/ && do
			{
		        	print '<A HREF="';
				&wkn::print_file($notes_path);
				print '">';
                                print &wkn::text_icon($wkn::define::url_icon_text, $wkn::define::url_icon);
				print "$file_base",
				'</A>';
				last SWITCH;
			};
                        $file_ext =~ /^\.(c|h|c\+\+|cxx|hxx|idl|java)$/ && do
                        {
                           print "<A HREF=\"" .
                              &wkn::get_cgi_prefix() .
                              $notes_wpath . '">';
                           print &wkn::text_icon($wkn::define::file_icon_text, $wkn::define::file_icon);
                           
                           print $file, "</A>\n";

                           last SWITCH;
                        };
			$file_ext =~ /^\.(txt|html|htm)/ && do
                        {
                           print "<A HREF=\"" .
                              &wkn::get_cgi_prefix() .
                              $notes_wpath . '">';
                           print &wkn::text_icon($wkn::define::file_icon_text, $wkn::define::file_icon);
                           
                           print $file_base, "</A>\n";
                              #				print "<A HREF=\"",
                              #				"${web_path}",
                              #				"\">${file}</A>\n";
                              last SWITCH;
			};

			#default case
			print "<A HREF=\"${web_path}\">";
                        print &wkn::text_icon($wkn::define::unknown_file_icon_text, $wkn::define::unknown_file_icon);
                        print "$file</a>\n";
		}
	}	
	elsif ( -d $real_path )
	{
		return 0 if($file =~ /^\..*/ );
		
		my($icon_image) = $wkn::define::dir_icon;
                if ( -r "${real_path}/.icon")
                {
		        if(open(ICONFILE, "$real_path/.icon"))
			{
				$icon_image = <ICONFILE>;
				chomp($icon_image);
				close(ICONFILE);
			}
		}
		if(defined($icon_image))
		{
			print '<A HREF="',
                        &wkn::get_cgi_prefix() ,
                        "${notes_wpath}" ,
                        '">';
                        $icon_image =~ m:([^/\.]*)[^/]*$:;
                        print &wkn::text_icon($wkn::define::dir_icon_text, 
                           $icon_image);
                        print "$file</A>\n";
                }
		else
		{
                   print "<A HREF=\"",
                   &wkn::get_cgi_prefix() ,
			"$notes_wpath",
			'">', $file,
                        "</A>\n";
		}
	}
        return 1;
}

sub get_icon
{
	my( $notes_path ) = @_;

	if( $notes_path eq "" )
	{
		$real_path=$auth::define::doc_dir;
		$file = "";
		$notes_wpath ="";
		$web_path=$auth::define::doc_wpath;
	}
	else
	{
		$real_path="$auth::define::doc_dir/$notes_path";
		$notes_path =~ m:([^/*]*)$:;
		$dir = $1;
		$notes_wpath = $notes_path;
		$notes_wpath = url_encode_path($notes_wpath);
		$web_path="$auth::define::doc_wpath/${notes_wpath}";
	}
	
        return () if($dir =~ /^\..*/ );
	
        my($icon_image) = $wkn::define::dir_icon;
        if ( -r "${real_path}/.icon" )
        {
           open(ICONFILE, "$real_path/.icon") || return ();
           $icon_image = <ICONFILE>;
           chomp($icon_image);
           close(ICONFILE);
        }
        return  "$wkn::define::icons_wpath/$icon_image" if(defined($icon_image));
        return ();
}

sub print_icon_img
{
	my( $notes_path ) = @_;

	if( $notes_path eq "" )
	{
		$real_path=$auth::define::doc_dir;
		$file = "";
		$notes_wpath ="";
		$web_path=$auth::define::doc_wpath;
	}
	else
	{
		$real_path="$auth::define::doc_dir/$notes_path";
		$notes_path =~ m:([^/*]*)$:;
		$dir = $1;
		$notes_wpath = $notes_path;
		$notes_wpath = url_encode_path($notes_wpath);
		$web_path="$auth::define::doc_wpath/${notes_wpath}";
	}
	
	if ( -d $real_path )
	{
		return if($dir =~ /^\..*/ );
		
                my($icon_image) = $wkn::define::dir_icon;
                if ( -r "${real_path}/.icon" )
                {
		        open(ICONFILE, "$real_path/.icon") || die "icon file";
			$icon_image = <ICONFILE>;
			chomp($icon_image);
			close(ICONFILE);
                }
                if(defined($icon_image))
                {
			$icon_image =~ m:([^/\.]*)[^/]*$:;
                        
                        print &wkn::text_icon($1, $icon_image);
                        
                        return 1;
                }
	}
        return 0;
}


sub list_files_html
{
   my($notes_path) = @_;
   my($rtn) = 0;

   # If you have index.html, not README.html, assume you want list files
   return 0 if( -f "$auth::define::doc_dir/$notes_path/index.html");
   return 0 if( -f "$auth::define::doc_dir/$notes_path/index.htm");

   return 0 unless
   opendir(DIR, "$auth::define::doc_dir/$notes_path") || return;
   while(defined($file = readdir(DIR)))
   {
	next if( -d "$auth::define::doc_dir/$notes_path/$file" );
        next if( $file =~ m:^\.: );
        next if( $file =~ m:^README(\.html)?:);
        next if( $file eq "index.html");
        next if( $file eq "index.htm");

        if( $file =~ m:^([^/]*)$: ) # untaint dir entry
        {
                $file = $1;
        }
        else
        {
                print "hey, /'s ? not good.\n";
                exit;
        }
        if(print_link_html( "$notes_path/$file"))
        {
           $rtn = 1;
           print "<br>\n";
        }
   }
   closedir(DIR);
   return $rtn;
}

sub list_dirs_html
{
   my($notes_path) = @_;
   return () unless
      opendir(DIR, "$auth::define::doc_dir/$notes_path");
   my $found = 0;
   while(defined($file = readdir(DIR)))
   {
	next if( -f $file );
        next if( $file =~ m:^\.: );

        if( $file =~ m:^([^/]*)$: ) # untaint dir entry
        { $file = $1; }
        else
        { die "hey, /'s ? not good.\n"; }
        print "<br>" if ($found);

        next unless(print_link_html( "$notes_path/$file"));
        $found = 1;
        
   }
   closedir(DIR);
   return $found;
}

sub list_html
{
	my( $notes_path ) = @_;
   my($found) = 0;

	if ( ! -d "$auth::define::doc_dir/$notes_path" )
	{
		return 0;
	}

	if( $notes_path eq "" )
	{
		$notes_dir="";
		$real_path=$auth::define::doc_dir;
		$web_path=$auth::define::doc_wpath;
		$notes_wdir = "";
	}
	else
	{
		$notes_dir="${notes_path}/";
		$real_path="$auth::define::doc_dir/${notes_path}";
		$notes_wpath = url_encode_path($notes_path);
		$notes_wdir="${notes_wpath}/";
		$web_path="$auth::define::doc_wpath/${notes_wpath}";
	}

	opendir (NOTESDIR, ${real_path});
	while( defined($file = readdir NOTESDIR))
	{
		$label = $file;
		$wfile = url_encode_path($file);
                $label = wkn::define::filename_filter($label)
                   if(defined($wkn::define::filename_filter));
		if ( -f "${real_path}/$file" )
		{
			$file_base = $file;
			$file_base =~ s/\.[^\.]*$//;
			$file_ext = $&;
			$file_ext =~ s/^\.*$//;

			SWITCH:
			{
				last SWITCH if ($file =~ /^\..*/ );
				last SWITCH if ($file =~ /\~$/ );
				last SWITCH if ($file =~ /^README(\.html)?$/ );
				last SWITCH if ($file eq "index.html" );
				last SWITCH if ($file eq "index.htm" );
                                $found = 1;
				$file_ext =~ /^\.html/ && do
				{
					print "<A HREF=\"${web_path}/",
					"${wfile}\">${file_base}",
					"</A>(html)<br>\n";
					last SWITCH;
				};
				$file_ext =~ /^\.url/ && do
				{
			        	print '<A HREF="';
					&wkn::print_file("${real_path}/${file}");
					print '">',
					"$file_base",
					'</A>(l)';
					print "<br>\n";
					last SWITCH;
				};
				$file_ext =~ /^\.txt/ && do
				{
					print "<A HREF=\"",
					"${web_path}/${wfile}",
					"\">${file}</A><br>\n";
					last SWITCH;
				};
				$file_ext && do
				{
					print "<A HREF=\"${web_path}/${wfile}\">
					${file}</A>(?)<br>\n";
					last SWITCH;
				};
				#default case
                                print "<A HREF=\"${web_path}/",
                                        "${wfile}\">${file}",
                                        "</A><br>\n";
			}
		}	
		elsif ( -r "${real_path}/${file}" )
		{
			if($file =~ /^\..*/ )
			{
				next;
			}
		        $found = 1;
                        my($icon_image) = $wkn::define::dir_icon;

	                if ( -r "${real_path}/${file}/.icon" and
                         open(ICONFILE, "${real_path}/${file}/.icon") )
                        {
                           $icon_image = <ICONFILE>;
			chomp($icon_image);
			close(ICONFILE);
                        }
                if(defined($icon_image))
                {
		print '<A HREF="',
                        &wkn::get_cgi_prefix() ,
                        "${notes_wdir}${wfile}",
                        '">';
                        print &wkn::text_icon("[x]", $icon_image);
                        print $file,"</A><br>\n";
                }
			else
			{
				print '<A HREF="',
                                &wkn::get_cgi_prefix() ,
				"${notes_wdir}$wfile",
				'">',
				$label, "</A><br>\n";
			}
		}	
	}
	close(NOTESDIR);
	return $found;
}

sub dir_file
{
	my($notes_path) = @_;

	return $notes_path if( -f "$auth::define::doc_dir/$notes_path");

	chdir("$auth::define::doc_dir/$notes_path");
	return "$notes_path/index.html" if ( -f "index.html" );
	return "$notes_path/index.htm" if ( -f "index.htm" );
	return "$notes_path/README.html" if ( -f "README.html" );
	return "$notes_path/README" if ( -f "README" );
        return ();
}

sub print_dir_file
{
	my($notes_path) = @_;

	if( -f "$auth::define::doc_dir/$notes_path" )
	{
		if( $notes_path =~ m:\.html?$: )
		{
			wkn::print_hfile($notes_path);
		}
		elsif(defined(&wkn::define::code_filter) && 
                $notes_path =~ /\.(c|h|c\+\+|cxx|hxx|idl|java)$/ )
                {
                   print '<pre>',
                   &wkn::define::code_filter($1, get_file($notes_path)),
                   '</pre>';

 	        }
		else
		{
			wkn::print_tfile($notes_path);
		}
		return $notes_path;
	}

        chdir("$auth::define::doc_dir/$notes_path") or return ();
	if( -f "index.html" )
	{
		$file = "index.html";
                wkn::print_hfile("$notes_path/$file");
        }
	elsif( -f "index.htm" )
	{
		$file = "index.htm";
                wkn::print_hfile("$notes_path/$file");
        }
	elsif( -f "README.html" )
        {
		$file = "README.html";
        	wkn::print_hfile("$notes_path/$file");
        }
        elsif( -f "README" )
        {
		$file = "README";
	  	wkn::print_tfile("$notes_path/$file");
        }
	else
        {
	 return ();
	}
        return $file;
}

sub print_modification
{
	my($notes_path) = @_;

        my ($dir_file);
        if(! defined( $dir_file = wkn::dir_file($notes_path)) )
        {
           $dir_file = $notes_path;
        }
my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
$atime,$mtime,$ctime,$blksize,$blocks)
           = stat("$auth::define::doc_dir/$dir_file");

        my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
           localtime($mtime);
        $year +=1900;
        my(@months) = ( "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" );
        my $mtime_str = "$year $months[$mon] $mday $hour:$min:$sec";
        
         print "Modified: $mtime_str \n";

        $owner = auth::get_path_owner($notes_path);
        if( defined($owner))
        {
	  print ": Owner <a href=\"show_user.cgi?username=$owner\">$owner</a>\n";
        }
        my $group;
        if(defined($group= auth::get_path_group($notes_path)))
        {
	  print ": Group <a href=\"show_group.cgi?group=$group\">$group</a>\n";
        }
        
        #	print "<br>\n";
}

sub get_file
{
        my($notes_file) = @_;

        open(MYFILE, "$wkn::define::notes_dir/$notes_file") || return 0;
        local $/ = undef;
        my($text) = <MYFILE>;
        close(MYFILE);
        return($text);
}

sub print_tfile
{
	my($notes_file) = @_;

	open(MYFILE, "$auth::define::doc_dir/$notes_file") || return 0;
  	while(defined($line = <MYFILE>))
	{
		if( $line =~ /^http:/ ||
			$line =~ /^ftp:/ ||
                        $line =~ s/^mailto:// )
		{
			$line = "<A HREF=\"$line\">$line</A>\n";
		}
                
                $line = translate_html($line, $notes_file);

		if($line =~ m:^( +):)
                {
                   my $a = $1;
                   my $b = $';   
                   $a =~ s:\s:&nbsp;:g;
                   $line = $a . $b;
                }
       		print("$line<br>");
	}
        close(MYFILE);
        return 1;
}

sub print_file
{
	my($notes_file) = @_;
        my($line);

	open(MYFILE, "$auth::define::doc_dir/$notes_file") || return 0;
	while(defined($line = <MYFILE>))
	{
		print($line);
	}
	close(MYFILE);
        return 1;
}

# translate a href's to work as if just the html file was loaded
sub smart_ref
{
   my( $path_enc, $ref_enc ) = @_;
   if($ref_enc =~ m:^#: )
   {
      return $ref_enc;
   }
   
   return $ref_enc if ( $ref_enc =~ m/^\w+:/ );
   return $ref_enc if ( $ref_enc =~ m:^/: );
   my $ref = url_unencode_path($ref_enc);

   # ??
   if($ref =~ m:#: )
   {
      $ref = "$auth::define::doc_wpath/$path_enc$ref";
   }
   elsif( $ref =~ m:\.cgi(\?|$): ) # cgi script
   #elsif( $ref =~ m:^[^/]+\.cgi: ) # local cgi script
   {
       if( -f "$auth::define::doc_dir/$path_enc/$ref")
       {
          $path_enc =~ s:^/::;
          $path_enc =~ s:(/|^)[^/]*$:$1:; # strip off file
          return $auth::define::doc_wpath . '/' . $path_enc . $ref_enc;
       }
   }
   elsif($path_enc =~ m:/[^/]*$:) # strip off README.html or xxx.html
   {
      $ref = "$auth::define::doc_wpath/$`/$ref";
   }
   else
   {
      $ref = "$auth::define::doc_wpath/$ref";
   }
   
   #collapse dir/.. to nothing
   while($ref =~ s~(^|/+)(?!\.\./)[^/]+/+\.\.($|/)~$1~g){}

   if($wkn::define::no_browse_links or $ref =~ m:\.([^\.]*)$: and ! ($1 =~ m:^(txt|html|htm)$:))  
   {
      return url_encode_path($ref);
   }
   
   $ref =~ s:/+$::;
   if($ref =~ m-^$auth::define::doc_wpath/*- )
   {
      return &wkn::get_cgi_prefix() . url_encode_path($');
   }
   elsif(defined(%wkn::define::wpath_prefix_translation))
   {
      for my $key ( keys %wkn::define::wpath_prefix_translation )
      {
         if($ref =~ m/^$key/ )
         {
            return $wkn::define::wpath_prefix_translation{$key} .
            url_encode_path($');
         }
      }
   }
   
   return  url_encode_path($ref);
}

sub print_hfile
{
   my($notes_file) = @_;
   my($line);

   open(MYFILE, "$auth::define::doc_dir/$notes_file") || return 0;
   
   my $savesep = $/;
   undef $/;
   my($text) = <MYFILE>;
   close(MYFILE);
   $/ = $savesep;
   $text =~ s:^(.*<HTML>)?(.*<HEAD>)?(.*</HEAD>)?(.*<BODY[^>]*>)?::si;
   $text =~ s:(</BODY>.*)?(</HTML>.*)?$::si;
   
   if(defined(&wkn::define::code_filter))
   {
      $text =~ s=<code\s*([^\s>]*)>(((?!</code>).)*)=&wkn::define::code_filter($1,$2);=gsie;
   }
   
   print translate_html($text, $notes_file);
}

sub translate_html
{
   my($text, $notes_file) = @_;
   # translate a hrefs 
   $text =~ s/<a href\s*=\s*\"?([^\">]+)\"?([^>]*)>/sprintf("<a href=\"%s\"$2>",&smart_ref($notes_file,$1))/gie;
   
   # translate relative image paths to full http paths
   my $this_path = ($notes_file =~ m:/[^/]*$:) ? "$`/" : "";
   my $this_hpath = url_encode_path("$auth::define::doc_wpath/$this_path");
   $text =~ s!(<img\s[^>]*src=\")([^:\/>\"]+)!$1$this_hpath$2!gi;
   
   return $text;
}

sub log
{
   my($notes_path) = @_;

   my $user=auth::get_user();
   my $date=localtime;
   my $log = "$date:$user:$ENV{'REMOTE_ADDR'}:$ENV{'REMOTE_HOST'}\n";

   if(open(LOG, ">>$auth::define::doc_dir/$notes_path/.log"))
   {
      print LOG $log;
      close(LOG);
   }
}

sub get_cgi_prefix
{
   my ($script) = shift; # optionally start with a cgi script
   
   unless($script)
   {
     $script = "browse_" . 
      ( $wkn::view_mode{"layout"}
            || $wkn::define::default_layout )
         . ".cgi";
   }
   my($prefix) = "${script}?";
         
   if($wkn::view_mode{"theme"})
   {
      $prefix .= ( "theme=" . $wkn::view_mode{"theme"} . "&" );
   }
   if($wkn::view_mode{"target"})
   {
      $prefix .= ( "target=" . $wkn::view_mode{"target"} . "&" );
   }
   if($wkn::view_mode{"frame"})
   {
      $prefix .= ( "frame=" . $wkn::view_mode{"frame"} . "&" );
   }
   return $prefix;
}

# return the <HEAD> tags to style/css to current theme along with
# site specific head tags
sub get_style_head_tags
{
   my $theme = $wkn::view_mode{"theme"};
   if(! defined($theme))
   {
      my $user_info = auth::get_current_user_info();
      $theme = $user_info->{"Theme"};
      $theme =  $wkn::define::default_theme unless(defined($theme));
   }
   my $head_tags = (-f "$wkn::define::themes_dir/$theme.css") ?
   "<LINK HREF=\"$wkn::define::themes_wpath/$theme.css\" REL=\"stylesheet\" TITLE=\"Default Styles\"
      MEDIA=\"screen\" type=\"text/css\" >\n" : "";

   $head_tags .= "\n$wkn::define::head_tags"
      if(defined($wkn::define::head_tags));
   return $head_tags;
}

sub text_icon
{
   my($text, $icon ) = @_;
   if(defined($icon))
   {
      return "<img src=\"$wkn::define::icons_wpath/$icon\" $img_border " .
         "alt=\"$text\"" . ">";
   }
   else
   {
      return $text;
   }
}
1;
