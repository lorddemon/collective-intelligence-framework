package CIF::Archive::Analytic::Plugin::ResolveUrl;

use strict;
use warnings;

use Regexp::Common qw/URI/;

sub process {
    my $self = shift;
    my $data = shift;

    return unless(ref($data) eq 'HASH');
    my $a = $data->{'address'};
    return unless($a && $a =~ /^$RE{'URI'}{'HTTP'}/);

    my $address;
    my $port;
    ## todo -- fix this, it flags on things like trainer.exe
    ## test with malc0de specifically
    if($a =~ /^(http?\:\/\/)?([A-Za-z0-9-\.]+\.[a-z]{2,5})(:\d+)?\//){
        $address = $2;
        $port = $3;
    } elsif($a =~ /^(https?\:\/\/)?($RE{'net'}{'IPv4'})(:\d+)?\//) {
        $address = $2;
        $port = $3;
    } else {
        return;
    }
    $port =~ s/^:// if($port);
    $port = 80 unless($port && ($port ne ''));
    my $severity = $data->{'severity'};
    my $conf = $data->{'confidence'};
    $conf = ($conf / 2);
    my $impact = $data->{'impact'};
    require CIF::Archive;
    my $bucket = CIF::Archive->new();
    my ($err,$id) = $bucket->insert({
        relatedid                   => $data->{'uuid'},
        address                     => $address,
        impact                      => $impact,
        description                 => $data->{'description'},
        severity                    => $severity,
        confidence                  => $conf,
        alternativeid               => $data->{'alternativeid'},
        alternativeid_restriction   => $data->{'alternativeid_restriction'},
        portlist                    => $port || '80',
        protocol                    => 6,
        source                      => $data->{'source'},
        restriction                 => $data->{'restriction'},
        detecttime                  => $data->{'detecttime'},
    });
    warn $err if($err);
    warn $id if($::debug);
}

1;
__END__

=head1 NAME

CIF::Archive::Analytic::Plugin::ResolveUrl - a CIF::Archive plugin for resolving urls (domains, ip's, etc...)

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
