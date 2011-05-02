package CIF::Archive::Analytic::Plugin::DNSParse;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use Regexp::Common qw/net/;

## http://www.iana.org/assignments/dns-parameters
## TODO -- move this up the stack to the domain datatype
my $codes = {
    1   => 'A',
    2   => 'NS',
    5   => 'CNAME',
    6   => 'SOA',
    12  => 'PTR',
    15  => 'MX',
    16  => 'TXT',
    28  => 'AAAA',
    99  => 'SPF',
};

sub process {
    my $self = shift;
    my $data = shift;
    my $config = shift;

    my $a = $data->{'address'};
    return unless($a);
    return unless($data->{'impact'} =~ /search/);
    return unless($a =~ /^$RE{'net'}{'IPv4'}$/);

    $config = $config->param(-block => 'dnsparse');

    ## TODO -- whitelist?
    require LWP::UserAgent;
    require XML::Simple;
    my $ua = LWP::UserAgent->new();
    $ua->timeout(10);
    $ua->credentials($config->{'site'},$config->{'realm'},$config->{'user'},$config->{'pass'});

    my $r = $ua->get($config->{'url'}.$a);
    my $xml = XML::Simple::XMLin($r->decoded_content());
    my $res = $xml->{'results'}->{'result'};
    return unless($res);

    my @rdata = $res;

    require CIF::Archive;
    foreach(@rdata){
        $_->{'rrtype'} = $codes->{$_->{'rrtype'}};
        my ($err,$id) = CIF::Archive->insert({
            impact          => 'passive dns',
            description     => $_->{'query'},
            address         => $_->{'query'},
            rdata           => $_->{'answer'},
            detecttime      => $_->{'lastseen'},
            type            => $_->{'rrtype'},
        });
        warn $err if($err);
    }
}
1;
__END__
=head1 NAME

CIF::Archive::Analytic::Plugin::PassiveAuckland - a CIF::Archive::Analytic plugin for reading the DNSParse project

=head1 SEE ALSO

 http://code.google.com/p/collective-intelligence-framework/
 CIF::Archive
 http://www.caida.org/workshops/wide/0707/slides/bojan.pdf

=head1 AUTHOR

 Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

 Copyright (C) 2011 by Wes Young (claimid.com/wesyoung)
 Copyright (C) 2011 by the Trustee's of Indiana University (www.iu.edu)
 Copyright (C) 2011 by the REN-ISAC (www.ren-isac.net)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
