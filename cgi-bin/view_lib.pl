#!/usr/bin/perl
# main WebKNotes functions
#use strict;

# The WebKNotes system is Copyright 1996-2000 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require 'view_define.pl';
require 'filedb_lib.pl';
require 'auth_lib.pl';

my $img_border = " border=0 hspace=3";

my $wiki_name_pattern = "([A-Z][a-z]+){2,}";

package view;

#use vars qw(%view_mode);
#local %view_mode; # used to store layout, theme, and target of sessions
#my(%view_mode); # used to store layout, theme, and target of sessions

# localize a sub ref (needed for mod_perl)
sub localize_sub
{
   my($subref) = shift;
   $subref = auth::localize_sub($subref);
   return sub 
   { 
      package view;
use vars qw(%view_mode);
      local(%view::view_mode);
      &$subref;
   }
}

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
#   $path =~ s:\+: :g;
   return $path;
}

sub url_encode_paths
{
   my(@out) = ();
   foreach(@_)
   {
      push(@out,view::url_encode_path($_));
   }
   return @out;
}

sub url_unencode_paths
{
   my(@out) = ();
   foreach(@_)
   {
      push(@out,view::url_unencode_path($_));
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
      if($arg =~ /^(theme|layout|sublayout|target|frame|save)=/)
      {
         $view::view_mode{$1} = $';
      }
#some temporary hackery to make path= arg work
      elsif($arg =~ /^path=/)
      {
         $arg = $';
         $arg =~ s:\+: :g;
         push(@args, $arg);
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
   return view::strip_view_mode_args(view::get_query_args());
}

sub actions1
{
   my( $notes_path ) = @_;
}

sub actions2
{
   my($notes_path) = @_;


#   my($dir_file) = filedb::path_file($notes_path);
#print "dir file : $dir_file,$notes_path\n";
#   $notes_path = filedb::path_dir($notes_path);
   
   my($notes_file_encoded) = url_encode_path(filedb::path_file($notes_path));
   my($notes_path_encoded) = url_encode_path($notes_path);
# What was below for?
#   $notes_path .= '/' if($notes_path ne "");

#   $dir_file = url_encode_path($dir_file);
   
   if(auth::check_current_user_file_auth('m', $notes_path))
   {
      print "[ <A HREF=\"edit.cgi?path=$notes_path_encoded\">Edit</a> text ] \n";
   }
   if( auth::check_current_user_file_auth('a', $notes_path) )
   {
      print "[ <A HREF=\"append.cgi#text?path=$notes_path_encoded\">Append</a> text ] \n";
   }
   print "[ <A HREF=\"add_topic.cgi?notes_path=${notes_path_encoded}\">New Topic</A> ]\n";
      print "[ Raw \n";
   print "<A HREF=\"$filedb::define::doc_wpath/${notes_file_encoded}\">File</A> | \n";
   print "<A HREF=\"$filedb::define::doc_wpath/${notes_path_encoded}\">Directory</A> | \n";
      print "<A HREF=\"browse_edit.cgi?$notes_path_encoded\">Access</a> ]\n";

   if ( $notes_path ne "" )
   {      
      # /,non-/'s,/* 
      my $parent_notes = $notes_path;
      $parent_notes =~ s:(^|/)[^/]*/?$::;

     my $parent_notes_ref = 
      &view::get_cgi_prefix() .
      $parent_notes;
      print "[ <A HREF=\"${parent_notes_ref}\"> Parent topic</A> ]\n";
   }
}

sub actions3
{
        my( $notes_path ) = @_;


	print <<EOT;
[ <A HREF="search.cgi?notes_mode=$view::define::mode&notes_subpath=${notes_path}">Search</A> ]
[ <A HREF="user_access.cgi"> User Accounts </a> ]
EOT
   print "[ <A HREF=\"" . &view::get_cgi_prefix("layout_theme") . "path=$notes_path_encoded\">Layout/Theme</A> ]\n";
}

sub print_link_html
{
	my( $notes_path ) = @_;
        my($web_path, $notes_wpath, $file, $real_path);
        my($found) = 0;

	if( $notes_path eq "" )
	{
		$real_path=$filedb::define::doc_dir;
		$file = "";
		$notes_wpath ="";
		$web_path=$filedb::define::doc_wpath;
	}
	else
	{
		$real_path="$filedb::define::doc_dir/$notes_path";
		$notes_path =~ m:([^/*]*)$:;
		$file = $1;
		$notes_wpath = url_encode_path($notes_path);
		$web_path="$filedb::define::doc_wpath/${notes_wpath}";
	}

        return if(defined($view::define::skip_files) and $file =~ m/$view::define::skip_files/ ); 
        $file = &view::define::filename_filter($file) if(defined(&view::define::filename_filter));
	if ( -f $real_path )
	{
           my($link, $link_type, $link_text);

           my $file_base = $file;
           $file_base =~ s/\.[^\.]*$//;
           my $file_ext = $&;
           $file_ext =~ s/^\.*$//;
           SWITCH:
           {
              last SWITCH if ($file =~ m/^\./ );
              # skip the index files
              last
                 if ($file =~ m:^(index.html|index.htm|HomePage|FrontPage.wiki|FrontPage|README|README.txt)$: );

              $file_ext =~ /^\.url/ && do
              {
                 $link_type = "url";
                 $link = filedb::get_file($notes_path);
                 $link_text = $file_base;
                 last SWITCH;
              };
              ($file_ext =~ /^\.wiki$/ || $file =~ /^$wiki_name_pattern$/ )&& do
              {
                 $link_type = "wiki";
                 $link = &view::get_cgi_prefix() . $notes_wpath;
                 $link_text = $file_base;
                 last SWITCH;
              };
              $file_ext =~ /^\.(c|h|c\+\+|cxx|hxx|idl|java)$/ && do
              {
                 $link_type = "code";
                 $link = &view::get_cgi_prefix() . $notes_wpath;
                 $link_text = $file;
                 last SWITCH;
              };
              $file_ext =~ /^\.(txt)/ && do
              {
                 $link_type = "txt";
                 $link = &view::get_cgi_prefix() . $notes_wpath;
                 $link_text = $file_base;
                 last SWITCH;
              };
              $file_ext =~ /^\.(html|htm)/ && do
              {
                 $link_type = "html";
                 $link = &view::get_cgi_prefix() . $notes_wpath;
                 $link_text = $file_base;
                 last SWITCH;
              };

           }
           if(!defined($link))
           {
              $link_type = "unknown";
              $link = ${web_path};
              $link_text = $file;
           }
           my $link_icon = &view::file_type_icon_tag($link_type);
           print "<A HREF=\"$link\">$link_icon${link_text}</a>";
        }
	elsif ( -d $real_path )
	{
		return 0 if($file =~ /^\..*/ );
		
		my($icon_image) = $view::define::dir_icon;
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
                        &view::get_cgi_prefix() ,
                        "${notes_wpath}" ,
                        '">';
                        $icon_image =~ m:([^/\.]*)[^/]*$:;
                        print &view::icon_tag("[>]", $icon_image);
                        print "$file</A>\n";
                }
		else
		{
                   print "<A HREF=\"",
                   &view::get_cgi_prefix() ,
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
        my($web_path, $notes_wpath, $file, $real_path);
        my($dir);

	if( $notes_path eq "" )
	{
		$real_path=$filedb::define::doc_dir;
		$file = "";
		$notes_wpath ="";
		$web_path=$filedb::define::doc_wpath;
	}
	else
	{
		$real_path="$filedb::define::doc_dir/$notes_path";
		$notes_path =~ m:([^/*]*)$:;
		$dir = $1;
		$notes_wpath = $notes_path;
		$notes_wpath = url_encode_path($notes_wpath);
		$web_path="$filedb::define::doc_wpath/${notes_wpath}";
	}
	
        return () if($dir =~ /^\..*/ );
	
        my($icon_image) = $view::define::dir_icon;
        if ( -r "${real_path}/.icon" )
        {
           open(ICONFILE, "$real_path/.icon") || return ();
           $icon_image = <ICONFILE>;
           chomp($icon_image);
           close(ICONFILE);
        }
        return  "$view::define::icons_wpath/$icon_image" if(defined($icon_image));
        return ();
}

sub print_icon_img
{
	my( $notes_path ) = @_;
        my($web_path, $notes_wpath, $file, $real_path);
        my($dir);

	if( $notes_path eq "" )
	{
		$real_path=$filedb::define::doc_dir;
		$file = "";
		$notes_wpath ="";
		$web_path=$filedb::define::doc_wpath;
	}
	else
	{
		$real_path="$filedb::define::doc_dir/$notes_path";
		$notes_path =~ m:([^/*]*)$:;
		$dir = $1;
		$notes_wpath = $notes_path;
		$notes_wpath = url_encode_path($notes_wpath);
		$web_path="$filedb::define::doc_wpath/${notes_wpath}";
	}
	
	if ( -d $real_path )
	{
		return if($dir =~ /^\..*/ );
		
                my($icon_image) = $view::define::dir_icon;
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
                        
                        print &view::icon_tag("[+]", $icon_image);
                        
                        return 1;
                }
	}
        return 0;
}


sub list_files_html
{
   my($notes_path) = @_;
   my($dir) = $filedb::define::doc_dir;
   $dir .= "/$notes_path" unless( $notes_path eq "");

   my($rtn) = 0;

   # If you have index.html, not README.html, assume you want list files
   return 0 if( -f "$dir/FrontPage.wiki");
   return 0 if( -f "$dir/FrontPage");
   return 0 if( -f "$dir/HomePage");
   return 0 if( -f "$dir/index.html");
   return 0 if( -f "$dir/index.htm");

   my($file);
   opendir(DIR, "$dir") || return 0;
   while(defined($file = readdir(DIR)))
   {
	next if( -d "$dir/$file" );
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
                return 0;
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
   my($dir) = $filedb::define::doc_dir;
   $dir .= "/$notes_path" unless( $notes_path eq "");

   return 0 if( -f "$dir/FrontPage.wiki");
   return 0 if( -f "$dir/FrontPage");
   return () unless
      opendir(DIR, $dir);
   my $file;
   my $found = 0;
   while(defined($file = readdir(DIR)))
   {
        next if( $file =~ m:^\.: );
	next if( -f "$dir/$file" );


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
   my($dir) = $filedb::define::doc_dir;
   $dir .= "/$notes_path" unless( $notes_path eq "");
   
   my($found) = 0;

   my $file;
   opendir (DIR, ${dir});
   while( defined($file = readdir DIR))
   {
	next if( -f $file );
        next if( $file =~ m:^\.: );
        next if( $file =~ m:^README(\.html)?:);
        next if( $file eq "index.html");
        next if( $file eq "index.htm");

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

sub print_dir_file
{
   my($notes_path) = @_;

   my($file) = filedb::path_file($notes_path);
   return () unless(defined($file));
   my($full_path) = filedb::get_full_path($file);
   
      my($file_type) = ();
      $file =~ m:([^\/]+)$: or return ();
      my($file_name) = $1;
      if($file =~ m:\.([^\.]+)$:)
      {
         $file_type = $1;
         if($file_type =~ /^(c|h|c\+\+|cxx|hxx|idl|java)$/)
         {
            $file_type = "code";
         }
      }
      if( !defined($file_type))
      {
         if($file_name eq "README" )
         {
            $file_type = "txt";
         }
         elsif( $file_name =~ m:^([A-Z][a-z]+){2,}$:)
         {
            $file_type = "wiki" ;
         }
         else
         {
            $file_type = $view::define::default_file_type;
         }
      }
      my $prefix = ( $0 =~ m:/[^/]*$: ) ? "$`/":"";
      if(defined($file_type) and -f "${prefix}filter_${file_type}.pl" )
      {
         require "filter_${file_type}.pl";
         &{"filter_${file_type}::print_file"}($file);
      }
      else
      {
         &view::print_file($notes_path);
      }
      
      return $notes_path;
}

sub create_modification_string
{
   my($date, $user, $group) = @_;
   my($text) = "Modified $date ";
   
   if( defined($user))
   {
      $text .= "by <a href=\"show_user.cgi?username=$user\">$user</a>\n";
   }
   if(defined($group))
   {
      $text .= ": group <a href=\"show_group.cgi?group=$group\">$group</a>\n";
   }
   return $text;
}

sub print_modification
{
   my($notes_path) = @_;

   my ($dir_file);
   if(! defined( $dir_file = filedb::path_file($notes_path)) )
   {
       $dir_file = $notes_path;
   }
my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
$atime,$mtime,$ctime,$blksize,$blocks)
   = stat("$filedb::define::doc_dir/$dir_file");

   my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
           localtime($mtime);
   $year +=1900;
   my(@months) = ( "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" );
   my $mtime_str = "$year $months[$mon] $mday $hour:$min:$sec";
        
   print create_modification_string($mtime_str, auth::get_path_owner($notes_path), auth::get_path_group($notes_path));
}

sub print_file
{
	my($notes_file) = @_;
        my($line);

	open(MYFILE, "$filedb::define::doc_dir/$notes_file") || return 0;
	while(defined($line = <MYFILE>))
	{
		print($line);
	}
	close(MYFILE);
        return 1;
}

sub log
{
   my($notes_path) = @_;

   my $user=auth::get_user();
   my $date=localtime;
   my $log = "$date:$user:$ENV{'REMOTE_ADDR'}:$ENV{'REMOTE_HOST'}\n";

   if(open(LOG, ">>$filedb::define::doc_dir/$notes_path/.log"))
   {
      print LOG $log;
      close(LOG);
   }
}

sub get_cgi_prefix
{
   my ($layout) = shift; # optionally start with a cgi script
   my ($prefix);
   
   if($layout eq "layout_theme")
   {
      $prefix = "layout_theme.cgi?";
   }
   else
   {
      $prefix = "browse.cgi?";
   }
   if(defined($view::view_mode{"layout"}))
   {
      $prefix .= ( "layout=" . $view::view_mode{"layout"} . "&" );
   }
#   }
#   else
#   {
#      $prefix = "browse_" . 
#      ( $layout || $view::view_mode{"layout"}
#               || $view::define::default_layout )
#            . ".cgi?";
#   }
         
   if(defined($view::view_mode{"sublayout"}))
   {
      $prefix .= ( "sublayout=" . $view::view_mode{"sublayout"} . "&" );
   }
   if(defined($view::view_mode{"theme"}))
   {
      $prefix .= ( "theme=" . $view::view_mode{"theme"} . "&" );
   }
   if(defined($view::view_mode{"target"}))
   {
      $prefix .= ( "target=" . $view::view_mode{"target"} . "&" );
   }
   if(defined($view::view_mode{"frame"}))
   {
      $prefix .= ( "frame=" . $view::view_mode{"frame"} . "&" );
   }
   return $prefix;
}

sub get_view_mode
{
  my($param) = @_;

  my $val = $view::view_mode{$param};
  if(! defined($val))
   {
     my $user_info = auth::get_current_user_info();
     $val = $user_info->{ucfirst($param)};
  }
  return $val;
}

sub set_view_mode
{
   my($param, $val) = @_;
   $view::view_mode{$param} = $val;
}

sub unset_view_mode
{
   my($param) = @_;
   undef $view::view_mode{$param};
}

# return the <HEAD> tags to style/css to current theme along with
# site specific head tags
sub get_style_head_tags
{
   my $theme = get_view_mode("theme");
   $theme = $view::define::default_theme unless $theme;
   my $head_tags = (-f "$view::define::themes_dir/$theme.css") ?
   "<LINK HREF=\"$view::define::themes_wpath/$theme.css\" REL=\"stylesheet\" TITLE=\"Default Styles\"
      MEDIA=\"screen\" type=\"text/css\" >\n" : "";

   $head_tags .= "\n$view::define::head_tags"
      if(defined($view::define::head_tags));
   return $head_tags;
}

sub icon_tag
{
   my($text, $icon ) = @_;
   if(defined($icon))
   {
      return "<img src=\"$view::define::icons_wpath/$icon\" $img_border " .
         "alt=\"$text\"" . ">";
   }
   else
   {
      return $text;
   }
}

sub file_type_icon_tag
{
   my($file_type) = @_;
   my($icon);
   my($text) = "[${file_type}]";
   
   if(defined($view::define::file_icons->{$file_type}))
   {
      $icon = $view::define::file_icons->{$file_type};
   }
   else
   {
      $icon = $view::define::file_icons->{"file"};
   }
   if(defined($icon))
   {
      return "<img src=\"$view::define::icons_wpath/$icon\" $img_border " .
         "alt=\"$text\"" . ">";
   }
   else
   {
      return $text;
   }
}

sub content_header
{
   print "Content-type: text/html\n\n";
}

sub browse_show_page
{
   my $layout = get_view_mode("layout");
   $layout = $view::define::default_layout unless($layout);
   require "browse_${layout}.pl";
   &{"browse_${layout}::show_page"}(@_);
#   browse::show_page(@_);
#   print "layout: $layout\n";
}

# persistent layout and theme settings for user
sub persist_view_mode
{
   my $username = auth::get_user();

   if( defined($username) )
   {
      my $theme = $view::view_mode{"theme"};
      my $layout = $view::view_mode{"layout"};
      my ($sublayout) = $view::view_mode{"sublayout"};

      my($user_info) = auth::get_current_user_info();
      if(defined($theme) && defined($layout) && defined($sublayout) &&
         ($user_info->{"Theme"} ne $theme ||
                    $user_info->{"Layout"} ne $layout ||
                    $user_info->{"Sublayout"} ne $sublayout)
         )
      {
         $user_info->{"Sublayout"} = $sublayout;
         $user_info->{"Layout"} = $layout;
         $user_info->{"Theme"} = $theme;
         unless(&auth::write_user_info(auth::check_user_name($username), $user_info))
         {
            print "Could not modify user information?\n";
         }
      }
      undef $view::view_mode{"theme"};
      undef $view::view_mode{"layout"};
      undef $view::view_mode{"sublayout"};
   }
}

1;
