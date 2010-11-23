package CIF::WebAPI::APIKey;
use base 'CIF::DBI';

our $VERSION = '0.00_02';

__PACKAGE__->table('apikeys');
__PACKAGE__->columns(Primary => 'apikey');
__PACKAGE__->columns(All => qw/apikey userid revoked write created/);
__PACKAGE__->sequence('apikeys_id_seq');

use OSSP::uuid;

sub genkey {
    my ($self,$uid) = @_;
    my $uuid    = OSSP::uuid->new();
    $uuid->make('v4');
    my $str = $uuid->export('str');
    undef $uuid;

    my $r = $self->insert({
        apikey  => $str,
        userid  => $uid,
    });
    return($r);
} 

1;

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::APIKEY - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::APIKEY;
  blah blah blah

=head1 DESCRIPTION

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Wes Young, E<lt>wes@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Wes Young

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut

