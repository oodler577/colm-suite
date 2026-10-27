
use strict;
use warnings;





my $greeting_start = 1;
my $greeting_first_final = 9;
my $greeting_error = 0;


for my $data ("HELLO:BRETT\n", "HELLO:\n", "HELLO:brett\n") {
    my ($p, $pe, $cs) = (0, length($data), 0);
    my $name = '';

$cs = 1;


{
 use bytes;
 while ($p < $pe && $cs != 0) {
  my $_ragel_key = ord(substr($data, $p, 1));
  if ($cs == 1) {
   if ($_ragel_key >= 0 && $_ragel_key <= 71) {
    $cs = 0;
   }
   elsif ($_ragel_key >= 72 && $_ragel_key <= 72) {
    $cs = 2;
   }
   elsif ($_ragel_key >= 73 && $_ragel_key <= 255) {
    $cs = 0;
   }
   else { $cs = 0; }
  }
  elsif ($cs == 2) {
   if ($_ragel_key >= 0 && $_ragel_key <= 68) {
    $cs = 0;
   }
   elsif ($_ragel_key >= 69 && $_ragel_key <= 69) {
    $cs = 3;
   }
   elsif ($_ragel_key >= 70 && $_ragel_key <= 255) {
    $cs = 0;
   }
   else { $cs = 0; }
  }
  elsif ($cs == 3) {
   if ($_ragel_key >= 0 && $_ragel_key <= 75) {
    $cs = 0;
   }
   elsif ($_ragel_key >= 76 && $_ragel_key <= 76) {
    $cs = 4;
   }
   elsif ($_ragel_key >= 77 && $_ragel_key <= 255) {
    $cs = 0;
   }
   else { $cs = 0; }
  }
  elsif ($cs == 4) {
   if ($_ragel_key >= 0 && $_ragel_key <= 75) {
    $cs = 0;
   }
   elsif ($_ragel_key >= 76 && $_ragel_key <= 76) {
    $cs = 5;
   }
   elsif ($_ragel_key >= 77 && $_ragel_key <= 255) {
    $cs = 0;
   }
   else { $cs = 0; }
  }
  elsif ($cs == 5) {
   if ($_ragel_key >= 0 && $_ragel_key <= 78) {
    $cs = 0;
   }
   elsif ($_ragel_key >= 79 && $_ragel_key <= 79) {
    $cs = 6;
   }
   elsif ($_ragel_key >= 80 && $_ragel_key <= 255) {
    $cs = 0;
   }
   else { $cs = 0; }
  }
  elsif ($cs == 6) {
   if ($_ragel_key >= 0 && $_ragel_key <= 57) {
    $cs = 0;
   }
   elsif ($_ragel_key >= 58 && $_ragel_key <= 58) {
    $cs = 7;
   }
   elsif ($_ragel_key >= 59 && $_ragel_key <= 255) {
    $cs = 0;
   }
   else { $cs = 0; }
  }
  elsif ($cs == 7) {
   if ($_ragel_key >= 0 && $_ragel_key <= 64) {
    $cs = 0;
   }
   elsif ($_ragel_key >= 65 && $_ragel_key <= 90) {
    $cs = 8;
 $name .= '[';
 $name .= chr($_ragel_key);
   }
   elsif ($_ragel_key >= 91 && $_ragel_key <= 255) {
    $cs = 0;
   }
   else { $cs = 0; }
  }
  elsif ($cs == 8) {
   if ($_ragel_key >= 0 && $_ragel_key <= 9) {
    $cs = 0;
   }
   elsif ($_ragel_key >= 10 && $_ragel_key <= 10) {
    $cs = 9;
   }
   elsif ($_ragel_key >= 11 && $_ragel_key <= 64) {
    $cs = 0;
   }
   elsif ($_ragel_key >= 65 && $_ragel_key <= 90) {
    $cs = 8;
 $name .= chr($_ragel_key);
   }
   elsif ($_ragel_key >= 91 && $_ragel_key <= 255) {
    $cs = 0;
   }
   else { $cs = 0; }
  }
  elsif ($cs == 9) {
   if ($_ragel_key >= 0 && $_ragel_key <= 255) {
    $cs = 0;
   }
   else { $cs = 0; }
  }
  else { $cs = 0; }
  last if $cs == 0;
  ++$p;
 }
 RAGEL_PERL_OUT: ;
}

    print(($cs >= $greeting_first_final ? 'ACCEPT' : 'FAIL'), ":$name\n");
}
