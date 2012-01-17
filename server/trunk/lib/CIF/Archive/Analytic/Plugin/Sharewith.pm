package CIF::Archive::Analytic::Plugin::Sharewith;

use strict;
use warnings;

require CIF::Archive;

sub process {
    my $self = shift;
    my $data = shift;
    my $config = shift;
    my $archive = shift;

    $config = $config->param(-block => 'cif_analytic');

    return unless($config->{'sharewith_enabled'});
    return unless(ref($data) eq 'HASH');
    my $sharewith = $data->{'sharewith'};
    return unless($sharewith);
    my @sw = (ref($sharewith) eq 'ARRAY') ? @$sharewith : [$sharewith];
    return unless($sw[0]);
    return unless($data->{'confidence'} >= ($config->{'sharewith_minconfidence'} || 85));
    my $sw_restriction = $config->{'sharewith_restriction'} || 'private';

    @sw = split(/,/,$sw[0]);
    my %info = %$data;

    $info{'relatedid'}                  = $info{'uuid'};
    $info{'uuid'}                       = undef;
    $info{'source'}                     = $config->{'sharewith_source'} || 'localhost';
    $info{'sharewith'}                  = undef;
    $info{'restriction'}                = $sw_restriction;
    $info{'alternativeid'}              = undef;
    $info{'alternativeid_restriction'}  = undef;

    foreach (@sw){
        $info{'guid'} = $_;
        my ($err,$id) = $archive->insert(\%info);
        warn $err if($err);
        warn $id->{'uuid'} if($::debug && $id);
    }
 }


1;
__END__

=head1 NAME

CIF::Archive::Analytic::Plugin::Sharewith - Perl extension for mapping out able to be shared data to new IODEF messages

=head1 AUTHOR

Wes Young, E<lt>wes@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Wes Young

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
