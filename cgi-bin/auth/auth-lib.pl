#!/usr/bin/perl -wT
use strict;
# auth-lib - library used for user authentication for a web based system
package auth;

# The auth-lib and all related scripts are part of WebKNotes
# The WebKNotes system is Copyright 1996-1999 Don Mahurin.
# For information regarding the copying/modification policy read 'LICENSE'.
# dmahurin@users.sourceforge.net

require 'auth_define.pl';

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
      return $user if( -f "$auth::define::users_dir/$user");
      return $user unless($auth::define::autoadd_remote_auth_users == 1);
      
      return () unless( auth::modify_user_info($user, "*",
         $auth::define::newuser_path,
         $auth::define::newuser_flags, $user, "unknown",$ENV{REMOTE_HOST}, $ENV{REMOTE_ADDR})
      );
      return $user;
   }
   my($user, $vword) =  split(/:/,$cookie{sessionid});
   my($sess_file);
   if($user =~ m:^([^/]*)$:) { $user = $1; } # untaint
   else { $user = "invalid"; }
   $sess_file = "$auth::define::session_dir/$user";
   unless( -f $sess_file )
   {
      print "No session file: $sess_file\n";
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

sub change_permissions
{
   my($permissions, @new_permissions) = @_;
#   print "change: $permissions:@new_permissions\n";

   my($subtract);
   my($p);
   $permissions = "" unless(@new_permissions);
   foreach $p (@new_permissions)
   {
      if($p eq '=') { $permissions = ""; }
      elsif($p eq '+') { $subtract = 0; }
      elsif($p eq '-') { $subtract = 1; }
      else
      {
          $permissions = "" unless(defined($subtract));
          $permissions =~ s:$p::g;
          $permissions .= $p unless($subtract);
      }
   }
#   print "newperm: $permissions\n";
   return $permissions;
}

sub check_file_auth
{
  my($user, $flag, @filepath) = @_;
  my($file_dir) = join('/', grep(/./, @filepath));
  my($auth_pass, $auth_path, $auth_flags, @other);

  if ( -f "$auth::define::doc_dir/$file_dir")
  {
     unless($file_dir =~ s:/[^/]*$::) #strip off file
     {
        $file_dir = "";
     }
  }
  my(@path_permissions);
  @path_permissions = split(//, get_path_permissions($file_dir)) or 
    undef(@path_permissions);

  if( defined($user))
  {
     if(open(UFILE, "$auth::define::users_dir/$user") )
     {
        ($auth_pass, $auth_path, $auth_flags, @other) = split(/:/, <UFILE>);
        close(UFILE);
     }
     
     return 1 if( $flag ne 'i' and $auth_flags =~ m:s:); # the master key
     
     $auth_flags =
     change_permissions($auth_flags, @path_permissions )
        if(defined(@path_permissions));
     
     my $owner;
     if( $auth_flags =~ m:o: and defined($owner = get_path_owner($file_dir))
     )
     {        
        if( $user eq $owner) 
        {
          $auth_flags = change_permissions($auth_flags,
             '+', split(//, $auth::define::owner_flags) );
        }
     } 
     my($group);
     if( defined($group = get_path_group($file_dir)))
     {
        if(open(GFILE, "$auth::define::groups_dir/$group"))
        {
           my($members, $permissions, @other) = split(/:/, <GFILE>);
           close(GFILE);
           if( $members =~ m:(^|,)$user(,|$): )
           {
              $auth_flags = change_permissions($auth_flags,
                 '+', split(//, $permissions) );
           }
        }
     }
  }
  if( ! defined($auth_flags) )
  {
     $auth_flags = $auth::define::default_flags;
     $auth_path = $auth::define::default_path;
     $auth_flags = change_permissions($auth_flags, @path_permissions)
        if(defined(@path_permissions));
  }
  
  if( defined($auth_path) and ! "/$file_dir/" =~ m:^/*$auth_path/+: )
  {
     return 0;
  }
  if( $auth_flags =~ m:$flag: )
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

   return( -f "$auth::define::users_dir/$username");
}

sub modify_user_info
{
   my($username, $password, $path, $flags, $fullname, $email, $webpage, @otherinfo) = @_;

   if($username =~ m:^([^/]+)$:)
   {
      $username = $1;
   }
   else
   {
      print "illegal user value\n";
      return 0;
   }
   
   if(!defined($password) or $password eq "*") # undefined password
   {
      $password = "*";
   }
   elsif($password eq "") # blank password
   {
      $password = pcrypt1($password);
      my($old_password, @oldstuff) =
         &auth::get_user_info($username);
      $password = defined($old_password) ? 
         $old_password :
         pcrypt1($password); # ok, give them a blank password.
   }
   else
   {
      $password = pcrypt1($password);
   }
   
   return 0 unless open( UFILE, ">$auth::define::users_dir/$username");
   print UFILE join(':', $password, $path, $flags, $fullname, $email, @webpage, @otherinfo);
   close(UFILE);
   return 1;
}

sub modify_group_info
{
   my($group, $users, $permissions, $comment) = @_;

   if($group =~ m:^([^/]+)$:)
   {
      $group = $1;
   }
   else
   {
      print "illegal group value: $group.\n";
      return 0;
   }
      
   return 0 unless open( GFILE, ">$auth::define::groups_dir/$group");
   print GFILE join(':', $users, $permissions, $comment);
   close(GFILE);
   return 1;
}

sub get_group_info
{
   my($group) = @_;

   if( ! -f "$auth::define::groups_dir/$group" )
   {
      return ();
   }
   open(GFILE, "$auth::define::groups_dir/$group");
   my(@info) = split(/:/, <GFILE>);
   close(GFILE);
   return @info;
}

sub check_pass
{
   my($user, $pass) = @_;

   return () unless open(UFILE, "$auth::define::users_dir/$user");
   my($auth_pass, $auth_path, $auth_flags, @other) = split(/:/, <UFILE>);
   close(UFILE);

   return ( $auth_pass eq "" or pcrypt1($pass) eq $auth_pass);
} 

sub get_user_info
{
   my($user) = @_;

   if( ! -f "$auth::define::users_dir/$user" )
   {
      return ();
   }
   open(UFILE, "$auth::define::users_dir/$user");
   my(@info) = split(/:/, <UFILE>);
   close(UFILE);
   return @info;
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
   my($sfile) = "$auth::define::session_dir/$1";

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
