#bug workarounds for css in tables

package css_tables_normal;

sub box_begin
{
   my($class) = @_;
   return "<div class=\"$class\" style=\"padding: 5\">";
}

sub box_end
{
   return "</div>";
}

sub trtd_begin
{
   my($class) = @_;
   return "<tr><td class=\"$class\" style=\"padding: 5\">";
}

sub td_next
{
   my($class) = @_;
   return "</td><td class=\"$class\" style=\"padding: 5\">";
}

sub trtd_end
{
   return "</td></tr>";
}


sub table_begin
{
   my($class, $props) = @_;
#   return "<table cellspacing=0 cellpadding=0 border=0 class=\"$class\">";
   return "<table cellspacing=0 class=\"$class\">";
# . 
#     "<td class=\"$class-border\"><table $props cellpadding=0 cellspacing=0 border=0 class=\"$class\">";
}

sub table_end
{
#   return "</table></td></tr></table>";
return "</table>";
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
