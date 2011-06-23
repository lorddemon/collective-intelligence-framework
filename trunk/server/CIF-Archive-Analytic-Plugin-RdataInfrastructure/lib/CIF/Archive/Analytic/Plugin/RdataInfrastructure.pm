package CIF::Archive::Analytic::Plugin::RdataInfrastructure;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

require CIF::Archive;
use Regexp::Common qw/net/;

sub process {
    my $self = shift;
    my $data = shift;

    return unless(ref($data) eq 'HASH');
    my $addr = $data->{'rdata'};
    return unless($addr);
    return unless($addr =~ /^$RE{'net'}{'IPv4'}/);

    my $conf = $data->{'confidence'} || 25;
    $conf = ($conf / 2);
    my $impact = $data->{'impact'};
    $impact =~ s/domain/infrastructure/;

    my ($err,$id) = CIF::Archive->insert({
         description    => $data->{'description'},
         impact         => $impact,
         severity       => $data->{'severity'},
         confidence     => $conf,
         portlist       => $data->{'portlist'},
         protocol       => $data->{'protocol'},
         address        => $addr,
         restriction    => $data->{'restriction'},
         alternativeid  => $data->{'alternativeid'},
         alternativeid_restriction  => $data->{'alternativeid_restriction'},
     });
     warn $err if($err);
     warn $id if($::debug);
 }

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::Archive::Analytic::Plugin::RdataInfrastructure - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::Archive::Analytic::Plugin::RdataInfrastructure;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for CIF::Archive::Analytic::Plugin::RdataInfrastructure, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

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

Copyright (C) 2011 by Wes Young

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
