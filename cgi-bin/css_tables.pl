#!/usr/bin/perl
#bug workaround for css in tables

package css_tables;

sub new
{
   my $type = shift;
   my $class;

   my $agent = $ENV{"HTTP_USER_AGENT"};

   #Netscape
   # Mozilla/4.75 [en] (X11; U; Linux 2.4.1 i686)
   if($agent =~ m:^Mozilla/4:)
   {
      $class = "css_tables_ns4";
   }

   #Galeon
   # Mozilla/5.0 (X11; U; Linux 2.4.1 i686; en-US; Galeon) Gecko/20010215

   else
   {
      $class = css_tables_normal;
   }
   require "${class}.pl";

   bless \$class, $type;
}

sub box_begin
{
   my $this = shift;
   return &{"${$this}::box_begin"}(@_);
}

sub box_end
{
   my $this = shift;
   return &{"${$this}::box_end"}(@_);
}

sub trtd_begin
{
   my $this = shift;
   return &{"${$this}::trtd_begin"}(@_);
}

sub trtd_end
{
   my $this = shift;
   return &{"${$this}::trtd_end"}(@_);
}


sub table_begin
{
   my $this = shift;
   return &{"${$this}::table_begin"}(@_);
}

sub table_end
{
   my $this = shift;
   return &{"${$this}::table_end"}(@_);
}
1;
