package CIF::Archive::Storage::Plugin::Iodef;
use base 'CIF::Archive::Storage';

use Module::Pluggable search_path => ['CIF::Archive::Storage::Plugin::Iodef'], require => 1;

use strict;
use warnings;

use XML::IODEF;
use XML::LibXML;

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

    $info->{'format'}   = 'iodef';

    my $iodef = XML::IODEF->new();
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
    return($iodef->out());
}

sub from {
    my $self = shift;
    my $msg = shift;

    my $iodef = XML::IODEF->new();
    $iodef->in($msg);
    my $hash = $iodef->to_hash();

    my ($prefix,$asn,$rir,$cc);
    if(exists($hash->{'IncidentEventDataFlowSystemAdditionalData'})){
        my @adm = @{$hash->{'IncidentEventDataFlowSystemAdditionalDatameaning'}};
        my @ad = @{$hash->{'IncidentEventDataFlowSystemAdditionalData'}};
        my %m = map { $adm[$_],$ad[$_] } (0 ... $#adm);
        $prefix = $m{'prefix'};
        $asn    = $m{'asn'};
        $rir    = $m{'rir'};
    }

    my $h = {
        address     => $hash->{'IncidentEventDataFlowSystemNodeAddress'}[0],
        description => $hash->{'IncidentDescription'}[0],
        detecttime  => $hash->{'IncidentDetectTime'}[0],
        confidence  => $hash->{'IncidentAssessmentConfidence'}[0],
        impact      => $hash->{'IncidentAssessmentImpact'}[0],
        protocol    => $hash->{'IncidentEventDataFlowSystemServiceip_protocol'}[0],
        portlist    => $hash->{'IncidentEventDataFlowSystemServicePortlist'}[0],
        severity    => $hash->{'IncidentAssessmentImpactseverity'}[0],
        source      => $hash->{'IncidentIncidentIDname'}[0],
        restriction => $hash->{'Incidentrestriction'}[0],
        asn         => $asn,
        cidr        => $prefix,
        cc          => $hash->{'IncidentEventDataFlowSystemNodeLocation'}[0],
        rir         => $rir,
        alternativeid               => $hash->{'IncidentAlternativeIDIncidentID'}[0],
        alternativeid_restriction   => $hash->{'IncidentAlternativeIDIncidentIDrestriction'}[0],
    };
    return($h);
}
    
1;
