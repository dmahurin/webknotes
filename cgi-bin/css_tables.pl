#bug workarounds for css in tables

package css_tables;
sub box_begin
{
   my($class) = @_;
   return '<table  width="100%" cellpadding=3 cellspacing=0 border=0><tr>' .
      "<td class=\"$class\">";
}
sub box_end
{
   return "</td></tr></table>";
}

sub trtd_begin
{
   my($class) = @_;
   return "<tr><td class=\"$class-border\">" . 
      '<table  width="100%" cellpadding=6 cellspacing=1 border=0><tr>' . 
      "<td class=\"$class\">";
}

sub trtd_end
{
   return "</td></tr></table></td></tr>";
}


sub table_begin
{
   my($class, $props) = @_;
   return "<table cellspacing=0 cellpadding=2 border=0><tr>" . 
      "<td class=\"$class-border\"><table $props cellpadding=0 cellspacing=0 border=0 class=\"$class\">";
}

sub table_end
{
   return "</table></td></tr></table>";
}


# below works and is cleaner, except:
# 1. transparent images anywhere mess up Netscpape borders
# 2. Mozilla makes the table background 100%

package css_tables0;
sub td_begin
{
   my($class) = @_;
   return "<td class=\"$class\"><div class=\"$class-border\">";
}

sub td_end
{
   return "</div></td>";
}

sub table_begin
{
   my($class) = @_;
   return "<div class=\"$class-back\"><div class=\"$class-border\"><table  cellpadding=0 cellspacing=0 border=0 class=\"$class\">";
}

sub table_end
{
   return "</table></div></div>";
}

1;
