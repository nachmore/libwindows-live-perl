package Windows::Live::User;

use strict;

use Windows::Live::Utils qw(parse);

use Moose;

extends 'Windows::Live::Base';

has 'timestamp' => (
	is  => 'ro',
	isa => 'Str'
);

has 'id' => (
	is  => 'rw',
	isa => 'Str'
);

has 'flags' => (
	is  => 'ro',
	isa => 'Str'
);

has 'context' => (
	is  => 'ro',
	isa => 'Str'
);

has 'token' => (
  is  => 'ro',
  isa => 'Windows::Live::Token'
);

sub BUILD {
	my $self = shift;
	my $args = shift;

	my $parsed = parse($args->{token}->{decoded_token});

	$self->{delegation_token} = $parsed->{delt};
	$self->{refresh_token}    = $parsed->{reft};
	$self->{session_key}      = $parsed->{skey};
	$self->{expiry}           = $parsed->{'exp'}; # exp == keyword
	$self->{offers}           = $parsed->{offer};
	$self->{location_id}      = $parsed->{lid};
	$self->{context}          = $args->{context};
	$self->{decoded_token}    = $args->{decoded_token};
	$self->{token}            = $args->{token};

	use Data::Dumper;
	print  Dumper($parsed);

}

1;

