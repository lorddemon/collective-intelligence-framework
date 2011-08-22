package CIF::Archive::Analytic::Plugin::VirusTotal;

use strict;
use warnings;

# http://search.cpan.org/~santeri/VT-API/lib/VT/API.pm
require VT::API;
use Regexp::Common qw/URI/;
require CIF::Archive;

sub process {
    my $self = shift;
    my $data = shift;
    my $config = shift;

    ## TODO -- finish implementing and testing
    return;

    return unless($data->{'impact'});
    return unless($data->{'impact'} =~ /^search url$/);
    return unless($data->{'address'});
    return unless($data->{'address'} =~ /^$RE{URI}/);

    $config = $config->param(-block => 'virustotal');
    my $apikey = $config->{'apikey'};

    my $vt = VT::API->new(key => $apikey);
    my $r = $vt->get_url_report($data->{'address'});
    return unless($r);

    my $ret = CIF::Archive->insert($r);
}
1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::Archive::Analytic::Plugin::VirusTotal - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::Archive::Analytic::Plugin::VirusTotal;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for CIF::Archive::Analytic::Plugin::VirusTotal, created by h2xs. It looks like the
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
