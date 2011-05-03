package CIF::Archive::Analytic::Plugin::SpamhausDBL;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

my $codes = {
    '127.0.1.2' => {
        impact      => 'spam domain',
        description => 'spam domain',
        severity    => 'medium',
        confidence  => 7,
    },
    '127.0.0.3' => {
        impact      => 'spam domain',
        description => 'spammed redirector domain',
        severity    => 'medium',
        confidence  => 7,
    },
    '127.0.1.255'   => 'YOU ARE BANNED!',
};

foreach(4 ... 19){
    $codes->{'127.0.1.'.$_} => {
        impact  => 'spam domain',
        description => 'spam domain',
        severity    => 'medium',
        confidence  => 7,
    };
}

foreach(20 ... 39){
   $codes->{'127.0.1.'.$_} => {
        impact      => 'phishing domain',
        description => 'pishing domain',
        severity    => 'medium',
        confidence  => 7,
    };
}

foreach(20 ... 39){
   $codes->{'127.0.1.'.$_} => {
        impact      => 'malware domain',
        description => 'malware domain',
        severity    => 'medium',
        confidence  => 7,
    };
}

sub process {
    my $self = shift;
    my $data = shift;

    return unless(ref($data) eq 'HASH');
    my $a = $data->{'address'};
    return unless($a);
    $a = lc($a);
    return unless($a =~ /^[a-z0-9.-]+\.[a-z]{2,5}$/);
    my $aid = $data->{'alternativeid'};
    return if($aid =~ /spamhaus\.org/);

    require Net::DNS::Resolver;
    my $r = Net::DNS::Resolver->new(recursive => 0);
    $a .= '.dbl.spamhaus.org';

    my $pkt = $r->send($a);
    my @rdata = $pkt->answer();
    return unless(@rdata);

    require CIF::Archive;
    foreach(@rdata){
        my $code = $codes->{$_->{'address'}};
        return if($code->{'description'} =~ /BANNED/);

        my ($err,$id) = CIF::Archive->insert({
            address                     => $data->{'address'},
            impact                      => $code->{'impact'},
            description                 => $code->{'description'},
            relatedid                   => $data->{'uuid'},
            severity                    => $code->{'severity'},
            confidence                  => $code->{'confidence'},
            restriction                 => 'need-to-know', 
            alternativeid               => 'http://www.spamhaus.org/query/dbl?domain='.$a,
            alternativdid_restriction   => 'public',
        });
        warn $err if($err);
        warn $id;
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
