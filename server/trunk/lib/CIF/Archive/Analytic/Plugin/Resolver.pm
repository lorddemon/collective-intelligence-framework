package CIF::Archive::Analytic::Plugin::Resolver;

use strict;
use warnings;

use Net::Abuse::Utils qw(:all); 
use DateTime::Format::DateParse;

sub process {
    my $self = shift;
    my $data = shift;
    my $config = shift;
    my $archive = shift;

    return unless(ref($data) eq 'HASH');
    return unless($data->{'impact'});
    my $addr = $data->{'address'};
    return unless($addr);
    return if($data->{'rdata'} && $data->{'rdata'} ne 'unknown');
    return unless($data->{'type'} && $data->{'type'} eq 'A'); 
    $addr = lc($addr);
    return unless($addr =~ /[a-z0-9.-]+\.[a-z]{2,5}$/);

    require Net::DNS::Resolver;
    my $r = Net::DNS::Resolver->new(recursive => 0);
    $r->udp_timeout(2);
    $r->tcp_timeout(2);
    my $pkt = $r->send($addr);
    my $ns;
    # protect against whitelists and CDN's
    unless($data->{'impact'} =~ /whitelist/ || $data->{'impact'} =~ /nameserver/){
        $ns = $r->send($addr,'NS');
        # work-around for things like co.cc, co.uk, etc..
        ## TODO -- clean this up with official TLD lists
        unless($ns && $ns->answer()){
            $addr =~ m/([a-z0-9-]+\.[a-z]{2,5})$/;
            $addr = $1;
            $ns = $r->send($addr,'NS');
        }
    }
    return unless($pkt);
    my @rdata = $pkt->answer();
    push(@rdata,$ns->answer()) if($ns);
    return unless(@rdata);

    foreach(@rdata){
        my ($as,$network,$ccode,$rir,$date,$as_desc) = asninfo($_->{'address'});
        my $conf = $data->{'confidence'};
        #$conf = ($conf/2) unless($_->{'type'} =~ /^(A|CNAME|PTR)$/);
        #$conf = ($conf / 2);
        
        my $log = log($conf) / log(500);
        $conf = sprintf('%.3f',($conf * $log));
        next if($conf < 20);
        my ($err,$id) = $archive->insert({
            impact      => $data->{'impact'},
            guid        => $data->{'guid'},
            description => $data->{'description'},
            relatedid   => $data->{'uuid'},
            address     => $data->{'address'},
            rdata       => $_->{'address'} || $_->{'cname'} || $_->{'nsdname'} || $_->{'exchange'} || 'unknown',
            type        => $_->{'type'},
            class       => $_->{'class'},
            severity    => $data->{'severity'},
            restriction => $data->{'restriction'},
            alternativeid   => $data->{'alternativeid'},
            alternativeid_restriction   => $data->{'alternativeid_restriction'},
            confidence  => $conf,
            asn         => $as,
            asn_desc    => $as_desc,
            cc          => $ccode,
            prefix      => $network,
            rir         => $rir,
            portlist    => $data->{'portlist'},
            protocol    => $data->{'protocol'},
        });
        warn $err if($err);
        warn $id->{'uuid'} if($::debug && $id);
    }
}

sub asninfo {
    my $a = shift;
    return undef unless($a);

    my ($as,$network,$ccode,$rir,$date) = get_asn_info($a);
    my $as_desc;
    $as_desc = get_as_description($as) if($as);

    $as         = undef if($as && $as eq 'NA');
    $network    = undef if($network && $network eq 'NA');
    $ccode      = undef if($ccode && $ccode eq 'NA');
    $rir        = undef if($rir && $rir eq 'NA');
    $date       = undef if($date && $date eq 'NA');
    $as_desc    = undef if($as_desc && $as_desc eq 'NA');
    $a          = undef if($a eq '');
    return ($as,$network,$ccode,$rir,$date,$as_desc);
}

1;
__END__

=head1 NAME

CIF::Archive::Analytic::Plugin::Resolver - a CIF::Archive::Analytic plugin for resolving domain data

=head1 SEE ALSO

 http://code.google.com/p/collective-intelligence-framework/
 CIF::Archive

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
