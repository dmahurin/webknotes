#!/usr/bin/perl

package auth::define;
$main_base = "/home/dmahurin/web";

$users_dir = "$main_base/private/users";
$groups_dir = "$main_base/private/groups";
$session_dir = "$main_base/private/sessions";
$doc_dir = "$main_base/public";

$owner_flags = "rnmc";
$default_flags = "orn";
$default_path = "notes";
$newuser_flags = "orn";
$newuser_path = "notes";
