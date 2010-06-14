package CIF::Message::Inet;
use base 'CIF::DBI';

use strict;
use warnings;

use XML::IODEF;
use CIF::Message::IODEF;

__PACKAGE__->table('inet');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description impact address cidr asn asn_desc cc rir protocol portlist confidence source severity restriction whois tsv detecttime reporttime created/);
__PACKAGE__->columns(Essential => qw/id uuid description address restriction created/);
__PACKAGE__->has_a(uuid   => 'CIF::Message');
__PACKAGE__->sequence('inet_id_seq');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    my $proto = convertProto($info->{'protocol'});
    my $uuid = $info->{'uuid'};
    my $source = $info->{'source'};
    $source = CIF::Message::genSourceUUID($source) unless(CIF::Message::isUUID($source));
    $info->{'source'} = $source;
    $info->{'protocol'} = $proto;

    unless($uuid){
        $uuid = CIF::Message::IODEF->insert({
            message => $self->toIODEF($info)
        });
        $uuid = $uuid->uuid();
    }

    my $id = eval { $self->SUPER::insert({
        uuid        => $uuid,
        description => $info->{'description'},
        impact      => $info->{'impact'},
        address     => $info->{'address'},
        cidr        => $info->{'cidr'},
        asn         => $info->{'asn'},
        asn_desc    => $info->{'asn_desc'},
        cc          => $info->{'cc'},
        rir         => $info->{'rir'},
        protocol    => $info->{'protocol'},
        portlist    => $info->{'portlist'},
        confidence  => $info->{'confidence'},
        source      => $info->{'source'},
        severity    => $info->{'severity'},
        restriction => $info->{'restriction'} || 'private',
        whois       => $info->{'whois'},
        detecttime  => $info->{'detecttime'},
        reporttime  => $info->{'reporttime'},
        impact      => $info->{'impact'},
    }) };
    if($@){
        die unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $self->retrieve(uuid => $uuid);
    }
    return($id);
}

sub convertProto {
    my $proto = shift;
    return unless($proto);
    return($proto) if($proto =~ /^\d+$/);

    for(lc($proto)){
        if(/^tcp$/){ $proto = 6; }
        if(/^udp$/){ $proto = 17; }
        if(/^icmp$/){ $proto = 1; }
    }
    $proto = undef unless($proto =~ /^\d+$/);
    return($proto);
}

sub toIODEF {
    my $self = shift;
    my $info = {%{+shift}};

    my $impact      = $info->{'impact'};
    my $address     = $info->{'address'} || die('no address given');
    my $description = $info->{'description'} || $impact.' - '.$address;
    my $cidr        = $info->{'cidr'};
    my $asn         = $info->{'asn'};
    my $asn_desc    = $info->{'asn_desc'};
    my $cc          = $info->{'cc'},
    my $rir         = $info->{'rir'},
    my $protocol    = $info->{'protocol'};
    my $portlist    = $info->{'portlist'};
    my $confidence  = $info->{'confidence'} || 'low';
    my $severity    = $info->{'severity'} || 'low';
    my $restriction = $info->{'restriction'} || 'private';
    my $whois       = $info->{'whois'};
    my $source      = $info->{'source'};
    my $detecttime  = $info->{'detecttime'};
    my $reporttime  = $info->{'reporttime'};
    my $relatedid   = $info->{'relatedid'};
    my $externalid  = $info->{'externalid'};
    my $externalid_restriction = $info->{'externalid_restriction'} || 'private';

    die('source or source uuid required') unless($source);

    my $iodef = XML::IODEF->new();
    $iodef->add('Incidentrestriction',$restriction);
    $iodef->add('IncidentDescription',$description);
    $iodef->add('IncidentIncidentIDname',$source);
    if($relatedid){
        $iodef->add('IncidentRelatedActivityIncidentID',$relatedid);
    }
    if($externalid){
        $iodef->add('IncidentAlternativeIDIncidentID',$externalid);
        $iodef->add('IncidentAlternativeIDIncidentIDrestriction',$externalid_restriction);
    }

    $iodef->add('IncidentReportTime',$reporttime) if($reporttime);
    $iodef->add('IncidentDetectTime',$detecttime) if($detecttime);
    $iodef->add('IncidentAssessmentImpact',$impact);
    $iodef->add('IncidentAssessmentConfidencerating','numeric');
    $iodef->add('IncidentAssessmentConfidence',$confidence);
    $iodef->add('IncidentAssessmentImpactseverity',$severity);
    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ipv4-addr'); ## TODO -- regext this
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);
    $iodef->add('IncidentEventDataFlowSystemServicePortlist',$portlist) if($portlist);
    $iodef->add('IncidentEventDataFlowSystemServiceip_protocol',$protocol) if($protocol);
    if($asn){
        $asn .= ' '.$asn_desc if($asn_desc);
        $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','asn');
        $iodef->add('IncidentEventDataFlowSystemNodeAddress',$asn);
    }
    if($cidr){
        $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ipv4-net');
        $iodef->add('IncidentEventDataFlowSystemNodeAddress',$cidr);
    }
    if($cc){
        $iodef->add('IncidentEventDataFlowSystemNodeLocation',$cc);
    }
    if($rir){
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','RIR');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$rir);
    }
    return $iodef->out();
}

__PACKAGE__->set_sql('history_byreporttime', => qq{
    SELECT *
    FROM __TABLE__
    WHERE reporttime >= ?
    ORDER BY reporttime DESC
});

__PACKAGE__->set_sql('history_bycreatetime', => qq{
    SELECT *
    FROM __TABLE__
    WHERE createtime >= ?
    ORDER BY createtime DESC
});


1;

__END__
