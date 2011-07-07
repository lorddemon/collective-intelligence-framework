package CIF::Archive::Analytic::Plugin::DNSParse;

use strict;
use warnings;

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
    $config = $config->param(-block => 'dnsparse') || return;
    return unless(ref($data) eq 'HASH');
    my $addr = $data->{'address'};
    return unless($addr);
    return unless($data->{'impact'});
    return if($data->{'confidence'} >= 20 && $data->{'impact'} =~ /whitelist/);
    return unless($data->{'impact'} =~ /search/);
    return unless($addr =~ /^$RE{'net'}{'IPv4'}$/);


    ## TODO -- whitelist?
    require LWP::UserAgent;
    require XML::Simple;
    my $ua = LWP::UserAgent->new();
    $ua->timeout($config->{'timeout'} || 60);
    $ua->credentials($config->{'site'},$config->{'realm'},$config->{'user'},$config->{'pass'});

    warn 'getting: '.$addr if($::debug);
    my $r;
    ## TODO -- fix this
    ## https://rt.perl.org/rt3//Public/Bug/Display.html?id=16807
    eval { 
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm 10;
        $r = $ua->get($config->{'url'}.$addr);
        alarm 0;
    };
    if($@){
        warn $@ if($::debug);
        return;
    }
    return unless($r);
    warn 'processing: '.$addr if($::debug);
    my $content = $r->decoded_content();
    $content =~ s/[^[:ascii:]]//g;
    my $xml = XML::Simple::XMLin($r->decoded_content());
    warn 'xml done' if($::debug);
    my $res = $xml->{'results'}->{'result'};
    return unless($res);

    my @rdata;
    if(ref($res) eq 'HASH'){
        push(@rdata,$res);
    } else {
        @rdata = @$res;
    }
    warn 'processing: '.$#rdata.' recs';

    @rdata = sort { $b->{'lastseen'} cmp $a->{'lastseen'} } @rdata;
    my $max = $config->{'max'} || 50;
    $max = $#rdata if($max > $#rdata);

    require CIF::Archive;
    foreach(0 ... $max){
        $_ = $rdata[$_];
        $_->{'rrtype'} = $codes->{$_->{'rrtype'}};
        my ($err,$id) = CIF::Archive->insert({
            impact          => 'passive dns',
            description     => $_->{'query'},
            address         => $_->{'query'},
            rdata           => $_->{'answer'},
            detecttime      => $_->{'lastseen'},
            type            => $_->{'rrtype'},
            severity        => 'low',
            confidence      => 85,
        });
        warn $err if($err);
        warn $id->uuid() if $::debug;
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
