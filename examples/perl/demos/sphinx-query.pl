
use strict;
use warnings;
use bytes;

# A deliberately small Sphinx extended-query syntax demonstration.
# Actions collect tokens; they are displayed only after the whole query matches.



my $sphinx_query_start = 1;
my $sphinx_query_first_final = 9;
my $sphinx_query_error = 0;
my @_sphinx_query_offsets = (0,0,14,25,38,43,56,65,76,89,105,);
my @_sphinx_query_low = (0,32,33,34,35,48,58,64,65,91,95,96,97,123,0,32,33,48,58,65,91,95,96,97,123,0,32,33,34,35,48,58,65,91,95,96,97,123,0,32,33,124,125,0,32,33,48,58,65,91,95,96,97,123,124,125,0,48,58,65,91,95,96,97,123,0,32,33,48,58,65,91,95,96,97,123,0,32,33,34,35,48,58,65,91,95,96,97,123,0,32,33,34,35,48,58,64,65,91,95,96,97,123,124,125,);
my @_sphinx_query_high = (31,32,33,34,47,57,63,64,90,94,95,96,122,255,31,32,47,57,64,90,94,95,96,122,255,31,32,33,34,47,57,64,90,94,95,96,122,255,31,32,123,124,255,31,32,47,57,64,90,94,95,96,122,123,124,255,47,57,64,90,94,95,96,122,255,31,32,47,57,64,90,94,95,96,122,255,31,32,33,34,47,57,64,90,94,95,96,122,255,31,32,33,34,47,57,63,64,90,94,95,96,122,123,124,255,);
my @_sphinx_query_targets = (0,1,0,2,0,5,0,6,5,0,5,0,5,0,0,3,0,3,0,3,0,3,0,3,0,0,3,0,4,0,3,0,3,0,3,0,3,0,0,9,0,1,0,0,9,0,5,0,5,0,5,0,5,0,1,0,0,7,0,7,0,7,0,7,0,0,8,0,7,0,7,0,7,0,7,0,0,8,0,2,0,5,0,5,0,5,0,5,0,0,9,0,2,0,5,0,6,5,0,5,0,5,0,1,0,);
my @_sphinx_query_actions = (0,0,0,0,0,1,0,2,1,0,1,0,1,0,0,3,0,3,0,3,0,3,0,3,0,0,3,0,0,0,3,0,3,0,3,0,3,0,0,4,0,5,0,0,6,0,1,0,1,0,1,0,1,0,7,0,0,8,0,8,0,8,0,8,0,0,0,0,8,0,8,0,8,0,8,0,0,0,0,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0,1,0,2,1,0,1,0,1,0,9,0,);


my @queries = @ARGV ? @ARGV : (
    '@title "state machine" perl | ruby',
    '@body perl search',
    'perl |',
);
for my $query (@queries) {
    # The trailing space lets exit actions fire on the final token.
    my $data = $query . ' ';
    my ($p, $pe, $cs) = (0, length($data), 0);
    my ($field, $text) = ('', '');
    my @tokens;

$cs = 1;


{
 use bytes;
 while ($p < $pe && $cs != 0) {
  my $_ragel_key = ord(substr($data, $p, 1));
  my $_ragel_trans = -1;
  if ($cs >= 0 && $cs < 10) {
   my $_ragel_lo = $_sphinx_query_offsets[$cs];
   my $_ragel_hi = $_sphinx_query_offsets[$cs + 1] - 1;
   while ($_ragel_lo <= $_ragel_hi) {
    my $_ragel_mid = int(($_ragel_lo + $_ragel_hi) / 2);
    if ($_ragel_key < $_sphinx_query_low[$_ragel_mid]) { $_ragel_hi = $_ragel_mid - 1; }
    elsif ($_ragel_key > $_sphinx_query_high[$_ragel_mid]) { $_ragel_lo = $_ragel_mid + 1; }
    else { $_ragel_trans = $_ragel_mid; last; }
   }
  }
  my $_ragel_action = 0;
  if ($_ragel_trans >= 0) {
   $cs = $_sphinx_query_targets[$_ragel_trans];
   $_ragel_action = $_sphinx_query_actions[$_ragel_trans];
  } else { $cs = 0; }
  if ($_ragel_action == 1) {
 $text .= chr(ord(substr($data, $p, 1)));
  }
  if ($_ragel_action == 2) {
 $field = '';
  }
  if ($_ragel_action == 3) {
 $text .= chr(ord(substr($data, $p, 1)));
  }
  if ($_ragel_action == 4) {
 push @tokens, ['PHRASE', $field, $text]; $text = '';
  }
  if ($_ragel_action == 5) {
 push @tokens, ['PHRASE', $field, $text]; $text = '';
 push @tokens, ['OR', '', '|'];
  }
  if ($_ragel_action == 6) {
 push @tokens, ['WORD', $field, $text]; $text = '';
  }
  if ($_ragel_action == 7) {
 push @tokens, ['WORD', $field, $text]; $text = '';
 push @tokens, ['OR', '', '|'];
  }
  if ($_ragel_action == 8) {
 $field .= chr(ord(substr($data, $p, 1)));
  }
  if ($_ragel_action == 9) {
 push @tokens, ['OR', '', '|'];
  }
  last if $cs == 0;
  ++$p;
 }
 RAGEL_PERL_OUT: ;
}

    print "QUERY: $query\n";
    if ($cs >= $sphinx_query_first_final && $p == $pe) {
        for my $token (@tokens) {
            my ($type, $scope, $value) = @$token;
            my $suffix = $scope ne '' ? " field=$scope" : '';
            print "  $type$suffix: $value\n";
        }
    }
    else {
        print "  INVALID (outside supported subset)\n";
    }
}
