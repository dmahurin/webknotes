#!/usr/bin/perl -cw
use strict;

require 'auth_define.pl';
require 'filedb_define.pl';

# auth-lib - library used for user authentication for a web based system
package auth;

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

# store current user and info, so we only get them once.
#use vars qw($current_user $current_user_info);
#local($current_user, $current_user_info);
#$current_user_info = ();
#$current_user = ();

# localize a sub ref (needed for mod_perl) to non-persist globals accross 
#sessions
sub localize_sub
{
   my($subref) = shift;
   return sub 
   { 
      local($auth::current_user, $auth::current_user_info);
use vars qw($current_user $current_user_info);
      &$subref;
   }
}

sub init_private_dir()
{
   (-d "$auth::define::private_dir/users") ||
      mkdir("$auth::define::private_dir/users", 0700) || return 0;
   (-d "$auth::define::private_dir/groups") ||
      mkdir("$auth::define::private_dir/groups", 0700) || return 0;
   (-d "$auth::define::private_dir/sessions") ||
      mkdir("$auth::define::private_dir/sessions", 0700) || return 0;
   return 1;
}

sub set_user
{
  my($user)=@_;
  $current_user = $user;
}

sub get_user
{
   return $current_user if(defined($current_user));
   my($chip,$value);
   my(%cookie);
   foreach (split(/; /, $ENV{'HTTP_COOKIE'}))
   {
      ($chip,$value) = split(/=/);
      $cookie{$chip} = $value;
   }
   unless(defined($cookie{'sessionid'}))
   {
      return () 
      unless($auth::define::allow_remote_user_auth eq "any" or
         $auth::define::allow_remote_user_auth eq $ENV{AUTH_TYPE});
      return () unless defined(my $user = $ENV{REMOTE_USER});
      if( -f "$auth::define::private_dir/users/$user" ||
         ! $auth::define::autoadd_remote_auth_users)
      {
         $current_user = $user;
         return $user;
      }
      
      $user=auth::check_user_name($user);
      return () unless($user);
      return () unless( auth::write_user_info($user, 
         { "PassKey"=>"*",
         "AuthRoot"=>$auth::define::newuser_path,
	    "Permissions"=>$auth::define::newuser_flags, 
	    "FromHost"=>$ENV{REMOTE_HOST}, 
            "FromAddr"=>$ENV{REMOTE_ADDR}})
      );
      $current_user = $user;
      return $user;
   }
   my($user, $vword) =  split(/:/,$cookie{sessionid});
   my($sess_file);
   if($user =~ m:^([^/]*)$:) { $user = $1; } # untaint
   else { $user = "invalid"; }
   $sess_file = "$auth::define::private_dir/sessions/$user";
   unless( -f $sess_file )
   {
      print "No session file: $sess_file<br>\n";
      print "Check setuid permissions\n";
      return ();
   }
   open(SFILE, $sess_file);
   my($line) = <SFILE>;
   close(SFILE);
   my($vcrypt,$addr) = split(/:/, $line);
   if($ENV{'REMOTE_ADDR'} ne $addr or pcrypt1($vword) ne $vcrypt )
   {
      print "mismatch of remote address and session address\n";
      return ();
   }
   $current_user = $user;
   return $user;
}

sub url_encode_path
{
   my($path) = @_;
   my $after;
   if($path =~ m:(#|\.cgi):) # we don't want to encode after these
   {
      $path = $`;
      $after = $& . $';
   }
   $path =~s/([^\w\/\.\~-])/sprintf("%%%02lx", unpack('C',$1))/ge;
   return $path . $after;
}

sub url_unencode_path
{
   my($path) = @_;
   $path=~s/%(..)/pack("c",hex($1))/ge;
   return $path;
}

# check for evil hacks in a path ( '..')
sub path_check
{
   my($path) = @_;
 
   #take off leading and trailing /'s and remove \'s
   $path =~ s:^/*::;
   $path =~ s:/*$::;
   $path =~ s:\\::g;
   if ( $path =~ m:(/|^)\.\.($|/):)
   {
      print "illegal chars\n";
      return ();
   }
   # else path is ok. untaint it
   $path =~ m:^:;
   $path = $';

   return $path;
}

sub change_flags
{
   my($flags, $new_flags, $op) = @_;
   
   if($op eq '+')
   {
      $flags .= $new_flags;
   }
   elsif($op eq '-')
   {
      for (split(//, $new_flags))
      {
	 $flags =~ s:$_::g;
      }
   }
   else
   {
      $flags = $new_flags;
   }

   return $flags;
}

sub check_path_exists
{
   my($path) = @_;
   
   if( ! -e "$filedb::define::doc_dir/$path" )
   {
     #     print "Note not found: $auth::define::doc_dir/$notes_path<br>\n";
     #print "If you want, you can <a href=\"add_topic.cgi?notes_path=$notes_path_encoded\"> Add </a> the note yourself<br>\n";
     return 0;
   }
   return 1;
}

sub check_file_auth
{
  my($user, $user_info, $check_flag, $file_path) = @_;
  
  return 1 if(defined($user_info) && $user_info->{"Permissions"} =~ m:s:);

  my $have_auth_flags;

  my($file_dir) = $file_path;
  if ( -f "$filedb::define::doc_dir/$file_dir")
  {
     unless($file_dir =~ s:/[^/]*$::) #strip off file
     {
        $file_dir = "";
     }
  }
  if( ! -d "$filedb::define::doc_dir/$file_dir" )
  {
     return 0;     
  }
  my(@path_permissions) = split(/,/, filedb::get_hidden_data($file_dir, "permissions")) 
     or ();
  if(defined($auth::define::path_permissions))
  {
     my $key;
     for $key (keys %$auth::define::path_permissions)
     {   
	if($key eq "" or $file_path =~ m:^$key:)
	{
	   unshift(@path_permissions, split(/,/, 
	      $auth::define::path_permissions->{$key}));
	}
     }
  }	
  
  my $owner = filedb::get_hidden_data($file_dir, "owner");
  my $is_owner = (defined($owner) && $user eq $owner);
  my $group = filedb::get_hidden_data($file_dir, "group");
  my $group_info;
  my $in_group = (defined($group) && 
     defined($group_info = get_group_info($group)) &&
     $group_info->{"Members"} =~ m:(^|,)$user(,|$): );
  
  if(defined($user_info  
     and $file_path =~ m:^$user_info->{"AuthRoot"}:))
  {
     $have_auth_flags = $user_info->{"Permissions"};
  }
  else
  {
     $have_auth_flags = "";
  }
  my $permissions;
  for $permissions (@path_permissions)
  {                
     if($permissions =~ m:^(o|u|g|a)?(\+|-|=):)
     {
	if($1 eq 'o') # owner of directory
	{
	   $have_auth_flags = change_flags($have_auth_flags, $', $2)
	      if($is_owner);
	}
        elsif($1 eq 'u') # user (not anonymous)
        {
           print "XXX\n" if (defined($user_info));
          $have_auth_flags = change_flags($have_auth_flags, $', $2)
             if(defined($user_info));
        }
	elsif($1 eq 'g') # in directory group
	{
	   $have_auth_flags = change_flags($have_auth_flags, $', $2 )
	      if($in_group);
	}
	else
	{
	   $have_auth_flags = change_flags($have_auth_flags, $', $2 );
	}
     }
     else
     {
	$have_auth_flags = change_flags($have_auth_flags, '=', $permissions);
     }
  }
  
  if( $have_auth_flags =~ m:$check_flag: )
  {
     return 1;
  }
  else
  {
     return 0;
  }
}

sub check_current_user_file_auth
{
   get_current_user_info(); # current user globals set
   return check_file_auth($current_user, $current_user_info, @_);
}

sub user_exists
{
   my($username) = @_;

   return( -f "$auth::define::private_dir/users/$username");
}

sub check_user_name
{
   my($username) = @_;

   if($username =~ m:^([^/]+)$:)
   {
      return $1;
   }
   else
   {
      return ();
   }
}
   
sub write_user_info
{
   my($username, $user_info) = @_;

   init_private_dir() || return 0;
   return 0 unless open( UFILE, ">$auth::define::private_dir/users/$username");
   
   my $key;
   for $key ( keys %$user_info)
   {
      print UFILE "$key: $user_info->{$key}\n";
   }
   close(UFILE);
   return 1;
}

sub check_group_name
{
   my($group);
   if($group =~ m:^([^/]+)$:)
   {
      return $1;
   }
   else
   {
      return ();
   }
}

sub write_group_info
{
   my($group, $group_info) = @_;
   
   init_private_dir() || return 0;
   return 0 unless open( GFILE, ">$auth::define::private_dir/groups/$group");
   
   my $key;
   for $key ( keys %$group_info)
   {
      print UFILE "$key: $group_info->{$key}\n";
   }
   close(GFILE);
   return 1;
}

sub get_user_info
{
   my($user) = @_;
   my(%info) = ();
# did I do below for some reason?
#   return \%info unless (defined($user));
   return () unless (defined($user));
   if(open(UFILE, "$auth::define::private_dir/users/$user"))
   {
      my($key, $value);
      while(<UFILE>)
      {
         chomp;
         ($key, $value) = split ': ';
         $info{$key} = $value;
      }
         
      close(UFILE);
   }
   return \%info;
}

sub get_current_user_info
{
   return $current_user_info if(defined($current_user_info));
   get_user() unless(defined($current_user));
   $current_user_info = get_user_info($current_user);
   return $current_user_info;
}

sub get_group_info
{
   my($group) = @_;
   my(%info);
   return () unless (defined($group));
   if(open(GFILE, "$auth::define::private_dir/groups/$group"))
   {
      my($key, $value);
      while(<GFILE>)
      {
         chomp;
         ($key, $value) = split ': ';
         $info{$key} = $value;
      }
         
      close(GFILE);
   }
   return \%info;
}

sub check_pass
{
   my($user, $user_info, $pass) = @_;

   return 0 unless defined($user_info->{"PassKey"});
   my $auth_pass = $user_info->{"PassKey"};

   return ( $auth_pass eq "" or pcrypt1($pass) eq $auth_pass);
} 

sub pcrypt1
{
        my($word) = @_;
        return crypt($word,"MM");
}

sub pcrypt2
{
        my($word) = @_;
        return substr(crypt($word, "DO"), 2,8);
}

sub create_session
{
   my($user) = @_;

   my($vword) = create_vword();
   my($vcrypt) = pcrypt1($vword);
   my($sessionid) = "$user:$vword";
   my($addr) = $ENV{'REMOTE_ADDR'};
   $user =~ m:^([^/]+)$:;
   my($sfile) = "$auth::define::private_dir/sessions/$1";

   return 0 unless(open(SFILE, ">$sfile")); 
   print SFILE "$vcrypt:$addr"; 
   close(SFILE);
   print "Set-Cookie: sessionid=$sessionid; path=/\n";
   return 1;
}

sub create_vword
{
   my($i, $word, $num,$add);
   $word = "";

   for($i = 0; $i < 8; $i++)
   {
      $num = rand(62);
      if( $num < 10)
      {
         $add = 48;
      }
      elsif ( $num < 36 )
      {
         $add = 55;
      }
      else
      {
         $add = 61;
      }

      $word .= pack("C", $num +$add);
   }

   return $word;
}
1;
