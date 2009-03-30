package Windows::Live;

our $VERSION = '0.5';

use 5.010000;

use strict;
use warnings;

use Carp;

use Moose;
use Moose::Util::TypeConstraints;

use URI::Escape;

use Windows::Live::Config;

use constant DEFAULT_CONFIG_FILE => 'app.config';

subtype 'Windows.Live.Config'
  => as class_type('Windows::Live::Config');

coerce 'Windows.Live.Config'
  => from 'Str'
    => via { Windows::Live::Config->new(config => $_) };

has 'config' => (
  is      => 'ro',
  isa     => 'Windows.Live.Config',
  coerce  => 1,
  default => sub { new Windows::Live::Config({config => DEFAULT_CONFIG_FILE}) }
);

has 'logged_in' => (
  is      => 'ro',
  isa     => 'Bool',
  default => 0,
);

has 'cgi' => (
  is      => 'ro',
  isa     => 'CGI',
  default => undef,
);

sub BUILD {
  my $self = shift;

  # just a 1x1 white gif file c/o the GIMP
  $self->{_logout_gif} = 
    join('', 
      map(chr, (
        0x47,0x49,0x46,0x38,0x37,0x61,0x01,0x00,
        0x01,0x00,0x80,0x00,0x00,0xff,0xff,0xff,
        0xff,0xff,0xff,0x2c,0x00,0x00,0x00,0x00,
        0x01,0x00,0x01,0x00,0x00,0x02,0x02,0x44,
        0x01,0x00,0x3b
    )));

  # if we have been supplied with a cgi object, check it for action
  if (defined $self->{cgi}) {
    my $cgi = $self->{cgi};
    
    # ignore errors in do_action 
    eval {
      $self->do_action($cgi->param('action'), $cgi->param('stoken'));
    };

    if ($@) { print $@;}
  }
    
}

sub do_action {
  my $self = shift;
  my ($action, $stoken) = @_;

  confess "Must provide 'action'" if (!defined $action);

  my $handler = "_do_$action";

  croak "Windows::Live does not support Actions of type '$action'"
    if (!$self->can($handler));

  eval { $self->$handler($action, $stoken); };
}

sub _do_login {
  my $self = shift;
  my ($action, $stoken) = @_;
  
  confess "Must supply 'action' and 'stoken' to _do_login"
    if (!defined $action || !defined $stoken);

  $self->{logged_in} = 1;
}

# see: http://msdn.microsoft.com/en-us/library/bb676640.aspx
sub _do_clearcookie {
  my $self = shift;

  # TODO: clear cookie
  
  # return a GIF to signify completion of "clearcookie"
  print "Content-Type: image/gif\n\n";
  print $self->{_logout_gif};
  
}

# see: http://msdn.microsoft.com/en-us/library/bb676640.aspx
sub _do_logout {
  my $self = shift;

  $self->{logged_in} = 0;
}

sub login_or_out_url() {
  my $self = shift;

  return ($self->{logged_in} ? $self->logout_url() : $self->login_url());
}

sub login_url {
  my $self = shift;

  map(uri_escape, @_) if (@_);

  my ($context, $market) = @_ || ('', '');

  return $self->{config}->{webauth_login_url} .
                            '?appid=' . $self->{config}->{appid}             .
                              '&alg=' . $self->{config}->{securityalgorithm} .
         ($context ne '' ? '&appctx=' . $context : '')                       .
         ($market  ne '' ?    '&mkt=' . $market  : '');
}

sub logout_url {
  my $self = shift;

  my $market = uri_escape(shift) || '';

  return $self->{config}->{webauth_logout_url}  .
         '?appid=' . $self->{config}->{appid}   .
         ($market ne '' ? '&mkt=' . $market : '');
}
  
sub login {
  my $self = shift;
  my $token = shift || croak "Must provide token when logging in!";
  my $context = shift;

  $self->{user} = new Windows::Live::User(token => $token);

  return $self->{user};
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Windows::Live - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Windows::Live;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Windows::Live, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.


=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

A. U. Thor, E<lt>nachmore@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
