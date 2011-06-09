package CIF::Archive::Storage::Plugin::Iodef;
use base 'CIF::Archive::Storage';

our $VERSION = '0.01_02';
$VERSION = eval $VERSION;

require 5.008;
use strict;
use warnings;

require XML::IODEF;
use Module::Pluggable search_path => [__PACKAGE__], require => 1;

sub prepare {
    my $class = shift;
    my $info = shift;

    foreach($class->plugins()){
        return(1) if($_->prepare($info));
    }
    return(0);
}

sub convert {
    my $class = shift;
    my $info = shift;

    my $impact                      = $info->{'impact'};
    my $address                     = $info->{'address'};
    my $description                 = lc($info->{'description'});
    my $confidence                  = $info->{'confidence'};
    my $severity                    = $info->{'severity'};
    my $restriction                 = $info->{'restriction'} || 'private';
    my $source                      = $info->{'source'};
    my $sourceid                    = $info->{'sourceid'};
    my $relatedid                   = $info->{'relatedid'};
    my $detecttime                  = $info->{'detecttime'};
    my $alternativeid               = $info->{'alternativeid'};
    my $alternativeid_restriction   = $info->{'alternativeid_restriction'} || 'private';
    my $cidr                        = $info->{'cidr'};
    my $asn                         = $info->{'asn'};
    my $asn_desc                    = $info->{'asn_desc'};
    my $cc                          = $info->{'cc'},
    my $rir                         = $info->{'rir'},
    my $protocol                    = $info->{'protocol'};
    my $portlist                    = $info->{'portlist'};
    my $purpose                     = $info->{'purpose'} || 'mitigation';

    my $dt = $info->{'detecttime'};
    # default it to the hour
    unless($dt){
        $dt = DateTime->from_epoch(epoch => time());
        $dt = $dt->ymd().'T'.$dt->hour().':00:00Z';
    }
    $info->{'detecttime'} = $dt;

    $info->{'format'}   = 'iodef';

    my $iodef = XML::IODEF->new();
    $iodef->add('Incidentpurpose',$purpose);
    $iodef->add('IncidentIncidentIDname',$source) if($source);
    $iodef->add('IncidentDetectTime',$detecttime) if($detecttime);
    $iodef->add('IncidentRelatedActivityIncidentID',$relatedid) if($relatedid);
    if($alternativeid){
        $iodef->add('IncidentAlternativeIDIncidentID',$alternativeid);
        $iodef->add('IncidentAlternativeIDIncidentIDrestriction',$alternativeid_restriction);
    }
    $iodef->add('Incidentrestriction',$restriction);
    $iodef->add('IncidentDescription',$description) if($description);
    $iodef->add('IncidentAssessmentImpact',$impact) if($impact);
    if($confidence){
        $iodef->add('IncidentAssessmentConfidencerating','numeric');
        $iodef->add('IncidentAssessmentConfidence',$confidence);
    }
    if($severity){
        $iodef->add('IncidentAssessmentImpactseverity',$severity);
    }
    $iodef->add('IncidentEventDataFlowSystemServicePortlist',$portlist) if($portlist);
    $iodef->add('IncidentEventDataFlowSystemServiceip_protocol',$protocol) if($protocol);

    foreach($class->plugins()){
        if($_->prepare($info)){
            $iodef = $_->convert($info,$iodef);
        }
    }
    require JSON;
    return(JSON::to_json($iodef->to_tree()));
}

sub data_hash_simple {
    my $class = shift;
    my $data = shift;
    my $h = $class->data_hash($data);
    return unless($h);

    my $sh = {
        relatedid                   => $h->{'RelatededActivity'}->{'IncidentID'}->{'content'},
        description                 => $h->{'Description'},
        impact                      => $h->{'Assessment'}->{'Impact'}->{'content'},
        severity                    => $h->{'Assessment'}->{'Impact'}->{'severity'},
        confidence                  => $h->{'Assessment'}->{'Confidence'}->{'content'},
        source                      => $h->{'IncidentID'}->{'name'},
        restriction                 => $h->{'restriction'},
        alternativeid               => $h->{'AlternativeID'}->{'IncidentID'}->{'content'},
        alternativeid_restriction   => $h->{'AlternativeID'}->{'IncidentID'}->{'restriction'},
        detecttime                  => $h->{'DetectTime'},
        purpose                     => $h->{'purpose'},
   };

    foreach my $p ($class->plugins()){
        my $ret = eval { $p->data_hash_simple($h) };
        warn $@ if($@);
        next unless($ret);
        map { $sh->{$_} = $ret->{$_} } keys %$ret;
    }
    return($sh);
}        

1;

=head1 SYNOPSIS

See CIF::Archive

=head1 DESCRIPTION

Storage Plugin for CIF::Archive

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
