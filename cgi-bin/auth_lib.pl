#!/usr/bin/perl -cw
use strict;
# auth-lib - library used for user authentication for a web based system
package auth;

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require 'auth_define.pl';

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

sub get_user()
{
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
      return $user if( -f "$auth::define::private_dir/users/$user");
      return $user unless($auth::define::autoadd_remote_auth_users == 1);
      
      return () unless( auth::modify_user_info(auth::check_user_name($user), 
	 ("PassKey"=>"*",
         "AuthRoot"=>$auth::define::newuser_path,
	    "Permissions"=>$auth::define::newuser_flags, 
	    "FromHost"=>$ENV{REMOTE_HOST}, 
	    "FromAddr"=>$ENV{REMOTE_ADDR}))
      );
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

sub path_check
{
   my($notes_path) = @_;
 
   if ( $notes_path =~ m/\.\./ )
   {
      print "illegal chars\n";
      return ();
   }
   # else notes_path is ok. untaint it
   $notes_path =~ m:^:;
   $notes_path = $';

   #take off leading and trailing /'s and remove \'s
   $notes_path =~ s:^/*::;
   $notes_path =~ s:/*$::;
   $notes_path =~ s:\\::g;

   return $notes_path;
}


sub get_path_group
{
   my(@path) = @_;
   my($gfile) = join('/', $auth::define::doc_dir, grep(/./,@path), '.group');
   
   if ( -f $gfile and open (GFILE, $gfile))
   {
     my($group) = <GFILE>;
     chomp($group);
     close(GFILE);
     return $group;
   }
   return ();
}

sub get_path_owner
{
   my(@path) = @_;
   my($ofile) = join('/', $auth::define::doc_dir, grep(/./,@path), '.owner');
   
   if ( -f $ofile and open (OFILE, $ofile))
   {
      my($owner) = <OFILE>;
      chomp($owner);
      close(OFILE);
      return $owner;
   }
   return ();
}
      

sub get_path_permissions
{
   my(@path) = @_;
   my($pfile) = join('/', $auth::define::doc_dir, grep(/./,@path), '.permissions');
   if( -f $pfile and open(PFILE, $pfile ) )
   {

      my($permissions) = <PFILE>;
      chomp($permissions);
      close(PFILE);
      return $permissions;
   }
   return "";
}

sub set_path_group
{
   my($group, @path) = @_;
   my($gfile) = join('/', $auth::define::doc_dir, grep(/./,@path), '.group');
   
   if ( open (GFILE, ">$gfile"))
   {
      print GFILE "$group";
      close(GFILE);
      return 0;
   }
   return 1;
}

sub set_path_permissions
{
   my($permissions,@path) = @_;
   my($pfile) = join('/', $auth::define::doc_dir, grep(/./,@path), '.permissions');
   if( open(PFILE, ">$pfile" ) )
   {
      print PFILE "$permissions";
      close(PFILE);
      return 0;
   }
   return 1;
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

sub check_file_auth
{
  my($user, $user_info, $check_flag, @filepaths) = @_;
  my($file_path) = join('/', grep(/./, @filepaths));
  #  my($auth_pass, $auth_path, ags, @other);
  
  return 1 if($user_info->{"Permissions"} =~ m:s:);

  my($file_dir) = $file_path;
  my $have_auth_flags;

  if ( -f "$auth::define::doc_dir/$file_dir")
  {
     unless($file_dir =~ s:/[^/]*$::) #strip off file
     {
        $file_dir = "";
     }
  }
  my(@path_permissions) = split(/,/, get_path_permissions($file_dir)) 
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
  
  my $owner = get_path_owner($file_dir);
  my $is_owner = (defined($owner) && $user eq $owner);
  my $group = get_path_group($file_dir);
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
     if($permissions =~ m:^(o|g|a)?(\+|-|=):)
     {
	if($1 eq 'o')
	{
	   $have_auth_flags = change_flags($have_auth_flags, $', $2)
	      if($is_owner);
	}
	elsif($1 eq 'g')
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
   return \%info unless (defined($user));
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
