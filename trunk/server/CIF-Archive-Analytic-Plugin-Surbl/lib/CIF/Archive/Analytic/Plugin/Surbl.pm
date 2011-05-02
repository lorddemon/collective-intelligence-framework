package CIF::Archive::Analytic::Plugin::Surbl;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use Regexp::Common qw/net/;

## TODO -- enumerate SURBL's whacky encoding schema.
my $codes = {
    '127.0.0.2' => {
        impact      => 'spam infrastructure',
        description => 'Direct UBE sources, spam operations & spam services',
    },
};

sub process {
    my $self = shift;
    my $data = shift;

    return unless(ref($data) eq 'HASH');
    my $a = $data->{'address'};
    return unless($a =~ /^$RE{'net'}{'IPv4'}{-keep}/);
    $a = $1;

    require Net::DNS::Resolver;
    my $r = Net::DNS::Resolver->new(recursive => 0);
    my @bits = split(/\./,$a);
    $a = join('.',reverse(@bits));
    $a .= '.multi.surbl.org';

    my $pkt = $r->send($a);
    my @rdata = $pkt->answer();
    return unless(@rdata);

    require CIF::Archive;
    foreach(@rdata){
        my ($err,$id) = CIF::Archive->insert({
            address                     => $data->{'address'},
            impact                      => 'suspicious infrastructure',
            description                 => 'surbl listed',
            relatedid                   => $data->{'uuid'},
            severity                    => $data->{'severity'},
            confidence                  => $data->{'confidence'},
            restriction                 => 'need-to-know', 
            alternativeid               => 'http://www.surbl.org/surbl-analysis',
            alternativdid_restriction   => 'public',
        });
        warn $err if($err);
        warn $id;
    }
}

1;
__END__
=head1 NAME

CIF::Archive::Analytic::Plugin::Spamhaus - a CIF::Archive::Analytic plugin for resolving surbl data

=head1 SEE ALSO

 http://code.google.com/p/collective-intelligence-framework/
 CIF::Archive
 http://www.surbl.org/faqs

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
