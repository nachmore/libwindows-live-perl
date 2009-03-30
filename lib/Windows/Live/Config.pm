package Windows::Live::Config;

use strict;

use Carp;

use Moose;

sub BUILD {
	my ($self, $params) = @_;

	$self->load($params->{config});
}

sub load {
	my $self   = shift;
	my $config = shift;

	return $self->error('Undefined config source for Windows::Live::Config!') 
		if !defined $config;

	# if this is a file - the load the contents
	if (-f $config) {
		open (FH, '<' . $config) || return $self->error("Unable to open file $config for reading ($!)");
			my @lines = <FH>;
		close (FH);

		$config = join '', @lines;
	}

	$self->_parse_config($config) ||
	  croak("Invalid config string ($config) passed to Windows::Live::Config " .
					'(was not a valid filename or valid xml config)');
}

sub _parse_config {
	my $self   = shift;
	my $config = shift;

	if ($config =~ /<appSettings>([\S\s]*?)<\/appSettings>/) {
		my $settings = $1;

		while ($settings =~ /<add\s+?key\s*?=\s*?"wll_(.*?)"\s+?value\s*?=\s*?"(.*?)"\s*?\/>/g) {
			$self->{$1} = $2;
		}	

	} else {
		return 0;
	}

	return 1;
	
}

1;
