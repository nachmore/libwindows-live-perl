package Windows::Live::Utils;

use strict;

# collection of useful 'static' functions that can be included by all
# libraries.

use Exporter 'import';
our @EXPORT_OK = qw(parse);

sub parse {
  my $string = shift || return {};

  my $rv = {};

  my @sections = split '&', $string;

  foreach my $section (@sections) {

    if ($section =~ /(.*?)=(.*)/) {
      $rv->{$1} = $2;
    } 
		# invalid areas are simply ignored...

  }

  return $rv;
}


