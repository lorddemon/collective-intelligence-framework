package CIF::Archive::Analytic::Plugin::SpamhausDBL;

use strict;
use warnings;

my $codes = {
    '127.0.1.2' => {
        impact      => 'suspicious domain',
        description => 'spammed domain',
        severity    => 'low',
        confidence  => 95,
    },
    '127.0.1.3' => {
        impact      => 'suspicious domain',
        description => 'spammed redirector domain',
        severity    => 'low',
        confidence  => 95,
    },
    '127.0.1.255'   => {
        description => 'YOU ARE BANNED!',
    },
};

foreach(4 ... 19){
    $codes->{'127.0.1.'.$_} = {
        impact  => 'suspicious domain',
        description => 'spammed domain',
        severity    => 'low',
        confidence  => 95,
    };
}

foreach(20 ... 39){
   $codes->{'127.0.1.'.$_} = {
        impact      => 'phishing domain',
        description => 'phishing domain',
        severity    => 'medium',
        confidence  => 95,
    };
}

foreach(20 ... 39){
   $codes->{'127.0.1.'.$_} = {
        impact      => 'malware domain',
        description => 'malware domain',
        severity    => 'medium',
        confidence  => 95,
    };
}

sub process {
    my $self = shift;
    my $data = shift;
    my $config = shift;
    my $archive = shift;

    return unless(ref($data) eq 'HASH');
    my $addr = $data->{'address'};
    return unless($addr);
    $addr = lc($addr);
    return unless($addr =~ /^[a-z0-9.-]+\.[a-z]{2,5}$/);
    my $aid = $data->{'alternativeid'};
    return if($aid && $aid =~ /spamhaus\.org/);
    return unless($data->{'impact'});
    return if($data->{'impact'} =~ /whitelist/ && $data->{'confidence'} >= 50);

    require Net::DNS::Resolver;
    my $r = Net::DNS::Resolver->new(recursive => 0);
    my $lookup = $addr.'.dbl.spamhaus.org';
    my $pkt = $r->send($lookup);
    my @rdata = $pkt->answer();
    return unless(@rdata);
    
    foreach(@rdata){
        next unless($_->{'type'} eq 'A');
        my $code = $codes->{$_->{'address'}};
        unless($codes->{$_->{'address'}}){
            warn ::Dumper($_) if($::debug);
        }
        if($code->{'description'} =~ /BANNED/){
            warn ::Dumper($_);
            warn 'BANNED';
            return;
        }
        return if($code->{'description'} =~ /BANNED/);

        my ($err,$id) = $archive->insert({
            guid                        => $data->{'guid'},
            relatedid                   => $data->{'uuid'},
            address                     => $data->{'address'},
            impact                      => $code->{'impact'},
            description                 => $code->{'description'},
            severity                    => $code->{'severity'} || 'medium',
            confidence                  => $code->{'confidence'} || 85,
            restriction                 => $data->{'restriction'}, 
            alternativeid               => 'http://www.spamhaus.org/query/dbl?domain='.$addr,
            alternativeid_restriction   => 'public',
        });
        warn $err if($err);
        warn $id->{'uuid'} if($::debug && $id);
    }
}

1;
__END__

=head1 NAME

CIF::Archive::Analytic::Plugin::SpamhausDBL - a CIF::Archive::Analytic plugin for resolving spamhaus DBL information around a domain

=head1 SEE ALSO

 http://code.google.com/p/collective-intelligence-framework/
 CIF::Archive
 http://www.spamhaus.org/dbl/

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
