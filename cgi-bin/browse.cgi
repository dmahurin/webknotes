#!/usr/bin/perl
# wrapper that calls the underlying browse layout script.
my $runpath;
if( $0 =~ m:/([^/]*)$: ) { $runpath = $`; push @INC, $runpath}

require 'auth_lib.pl';
require 'wkn_define.pl';

use CGI qw(:standard);

my $layout = param(layout);
unless(defined($layout))
{
   my $user_info = auth::get_current_user_info();
   $layout = $user_info->{"Layout"};
   $layout = $wkn::define::default_layout unless(defined($layout));
}
if( -f "$runpath/browse_${layout}.cgi")
{
   exec ("$runpath/browse_${layout}.cgi", @ARGV);
}
else
{
   print header;
   print "Error executing cgi script\n";
}
