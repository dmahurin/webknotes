#!/usr/bin/perl
package auth::define;

$doc_dir = "/home/someone/wkn/public/notes";

$private_dir = "/home/someone/wkn/private";
$users_dir = "$private_dir/users";
$groups_dir = "$private_dir/groups";
$session_dir = "$private_dir/sessions";

# permissions a new user gets:
# o - owner privilage
# r - read
# c - create
# m - modify
# d - delete
# n - ability to add "notes"
$owner_flags = "rnmc";
$default_flags = "orn";
$default_path = "/";
$newuser_flags = "orn";
$newuser_path = "/";

# For browser server specific authentication
#$allow_remote_user_auth = "any"; # allow any type of auth
#$allow_remote_user_auth = "basic"; # Netscape authentication ?
#$autoadd_remote_auth_users = 1; # allow unregistered users to have user access

