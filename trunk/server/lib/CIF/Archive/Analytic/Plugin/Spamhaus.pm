package CIF::Archive::Analytic::Plugin::Spamhaus;

use strict;
use warnings;

use Regexp::Common qw/net/;

my $codes = {
    '127.0.0.2' => {
        impact      => 'spam infrastructure',
        description => 'Direct UBE sources, spam operations & spam services',
        severity    => 'medium',
        confidence  => 95,
        portlist    => '25,80,443',
    },
    '127.0.0.3' => {
        impact      => 'spam infrastructure',
        description => 'Direct snowshoe spam sources detected via automation',
        severity    => 'medium',
        confidence  => 95,
        portlist    => 25,
    },
    '127.0.0.4' => {
        impact      => 'malware infrastructure',
        description => 'CBL + customised NJABL. 3rd party exploits (proxies, trojans, etc.)',
        severity    => 'medium',
        portlist    => '80,443',
        confidence  => 95,
    },
    '127.0.0.5' => {
        impact      => 'malware infrastructure',
        description => 'CBL + customised NJABL. 3rd party exploits (proxies, trojans, etc.)',
        severity    => 'medium',
        portlist    => '80,443',
        confidence  => 95,
    },
    '127.0.0.6' => {
        impact      => 'malware infrastructure',
        description => 'CBL + customised NJABL. 3rd party exploits (proxies, trojans, etc.)',
        severity    => 'medium',
        portlist    => '80,443',
        confidence  => 95,
    },
    '127.0.0.7' => {
        impact      => 'malware infrastructure',
        description => 'CBL + customised NJABL. 3rd party exploits (proxies, trojans, etc.)',
        severity    => 'medium',
        portlist    => '80,443',
        confidence  => 95,
    },
    '127.0.0.8' => {
        impact      => 'malware infrastructure',
        description => 'CBL + customised NJABL. 3rd party exploits (proxies, trojans, etc.)',
        severity    => 'medium',
        portlist    => '80,443',
        confidence  => 95,
    },
    '127.0.0.10'    => {
        impact      => 'spam infrastructure',
        description => 'End-user Non-MTA IP addresses set by ISP outbound mail policy',
        severity    => 'medium',
        confidence  => 95,
        portlist    => 25,
    },
    '127.0.0.11'    => {
        impact      => 'spam infrastructure',
        description => 'End-user Non-MTA IP addresses set by ISP outbound mail policy',
        severity    => 'medium',
        confidence  => 95,
        portlist    => 25,
    },
};

sub process {
    my $self = shift;
    my $data = shift;

    return unless(ref($data) eq 'HASH');
    my $addr = $data->{'address'};
    return unless($addr);
    return unless($addr =~ /^$RE{'net'}{'IPv4'}{-keep}/);
    $addr = $1;
    my $aid = $data->{'alternativeid'};
    return if($aid && $aid =~ /spamhaus\.org/);

    require Net::DNS::Resolver;
    my $r = Net::DNS::Resolver->new(recursive => 0);
    my @bits = split(/\./,$addr);
    my $lookup = join('.',reverse(@bits));
    $lookup .= '.zen.spamhaus.org';

    my $pkt = $r->send($lookup);
    my @rdata = $pkt->answer();
    return unless(@rdata);
    my ($sev,$conf);

    require CIF::Archive;
    foreach(@rdata){
        next unless($_->{'type'} eq 'A');
        unless($_->{'address'}){
            warn ::Dumper($_) if($::debug);
        }   
        my $code = $codes->{$_->{'address'}};

        # see http://www.spamhaus.org/faq/answers.lasso?section=Spamhaus%20PBL#183
        return if($_->{'address'} =~ /\.(10|11)$/);
        my ($err,$id) = CIF::Archive->insert({
            address                     => $data->{'address'},
            impact                      => $code->{'impact'},
            description                 => $code->{'description'},
            severity                    => $code->{'severity'} || 'medium',
            confidence                  => $code->{'confidence'} || 85,
            restriction                 => 'need-to-know', 
            alternativeid               => 'http://www.spamhaus.org/query/bl?ip='.$addr,
            alternativeid_restriction   => 'public',
            portlist                    => $code->{'portlist'},
            protocol                    => $code->{'protocol'} || 6,
        });
        warn $err if($err);
        warn $id->uuid() if($::debug);
    }
}




# Preloaded methods go here.

1;
__END__

=head1 NAME

CIF::Archive::Analytic::Plugin::Spamhaus - a CIF::Archive::Analytic plugin for resolving spamhaus ZEN information around an address

=head1 SEE ALSO

 http://code.google.com/p/collective-intelligence-framework/
 CIF::Archive
 http://www.spamhaus.org/zen/

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


=cut
