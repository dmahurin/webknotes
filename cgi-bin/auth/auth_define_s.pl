#!/usr/bin/perl
package auth::define;

$main_base = "/misc/pdweb2/fnd/dev/oi";

$users_dir = "$main_base/wkn/private/users";
$groups_dir = "$main_base/wkn/private/groups";
$session_dir = "$main_base/wkn/private/sessions";
$doc_dir = "$main_base/docs";

# permissions a new user gets:
# o - owner privilage
# r - read
# c - create
# m - modify
# d - delete
# n - ability to add "notes"
$owner_flags = "rnmdc";
$default_flags = "orn";
$default_path = "/";
$newuser_flags = "orn";
$newuser_path = "/";

# For browser server specific authentication
$allow_remote_user_auth = "any"; # allow any type of auth
#$allow_remote_user_auth = "basic"; # Netscape authentication ?
$autoadd_remote_auth_users = 1; # allow unregistered users to have user access
