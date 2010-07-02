package CIF::Message::Domain;
use base 'CIF::DBI';

use strict;
use warnings;

use CIF::Message::IODEF;

__PACKAGE__->table('domains');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description address type rdata cidr asn asn_desc cc rir class ttl whois impact confidence source alternativeid alternativeid_restriction severity restriction detecttime created tsv/);
__PACKAGE__->columns(Essential => qw/id uuid description address rdata impact restriction created/);
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};
    
    my $uuid    = $info->{'uuid'};
    my $source  = $info->{'source'};
    
    $source = CIF::Message::genSourceUUID($source) unless(CIF::Message::isUUID($source));
    $info->{'source'} = $source;

    unless($uuid){
        $uuid = CIF::Message::IODEF->insert({
            message => $self->toIODEF($info)
        });
        $uuid = $uuid->uuid();
    }

    my $id = eval { $self->SUPER::insert({
        uuid        => $uuid,
        description => $info->{'description'},
        address     => $info->{'address'},
        type        => $info->{'type'},
        rdata       => $info->{'rdata'},
        cidr        => $info->{'cidr'},
        asn         => $info->{'asn'},
        asn_desc    => $info->{'asn_desc'},
        cc          => $info->{'cc'},
        rir         => $info->{'rir'},
        class       => $info->{'class'},
        ttl         => $info->{'ttl'},
        source      => $source,
        impact      => $info->{'impact'} || 'malicious domain',
        confidence  => $info->{'confidence'},
        severity    => $info->{'severity'},
        restriction => $info->{'restriction'} || 'private',
        detecttime  => $info->{'detecttime'},
        alternativeid => $info->{'alternativeid'},
        alternativeid_restriction => $info->{'alternativeid_restriction'} || 'private',
    }) };
    if($@){
        die unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $self->retrieve(uuid => $uuid);
    }
    return($id);    
}

sub toIODEF {

    my $self = shift;
    my $info = {%{+shift}};

    my $impact      = $info->{'impact'};
    my $address     = $info->{'address'} || die('no address given');
    my $description = $info->{'description'} || $impact.' - '.$address;
    my $confidence  = $info->{'confidence'} || 'low';
    my $severity    = $info->{'severity'} || 'low';
    my $restriction = $info->{'restriction'} || 'private';
    my $source      = $info->{'source'};
    my $detecttime    = $info->{'detecttime'};
    my $relatedid   = $info->{'relatedid'};
    my $rdata       = $info->{'rdata'};
    my $asn         = $info->{'asn'};
    my $asn_desc    = $info->{'asn_desc'};
    my $cidr        = $info->{'cidr'};
    my $cc          = $info->{'cc'};
    my $rir         = $info->{'rir'};
    my $alternativeid  = $info->{'alternativeid'};
    my $alternativeid_restriction = $info->{'alternativeid_restriction'} || 'private';

    my $iodef = XML::IODEF->new();
    $iodef->add('Incidentrestriction',$restriction);
    $iodef->add('IncidentDescription',$description);
    $iodef->add('IncidentDetectTime',$detecttime) if($detecttime);
    $iodef->add('IncidentIncidentIDname',$source);
    if($relatedid){
        $iodef->add('IncidentRelatedActivityIncidentID',$relatedid);
    }
    if($alternativeid){
        $iodef->add('IncidentAlternativeIDIncidentID',$alternativeid);
        $iodef->add('IncidentAlternativeIDIncidentIDrestriction',$alternativeid_restriction);
    }
    $iodef->add('IncidentAssessmentImpact',$impact);
    $iodef->add('IncidentAssessmentConfidencerating','numeric');
    $iodef->add('IncidentAssessmentConfidence',$confidence);
    $iodef->add('IncidentAssessmentImpactseverity',$severity);
    $iodef->add('IncidentEventDataFlowSystemNodeLocation',$cc) if($cc);
    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeAddressext-category','domain');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);
    if($rdata){
        ## TODO -- autodetect Addresscategory with regex
        $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ipv4-addr');
        $iodef->add('IncidentEventDataFlowSystemNodeAddress',$rdata);
    }
    if($cidr){
        $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ipv4-net');
        $iodef->add('IncidentEventDataFlowSystemNodeAddress',$cidr);
    }
    if($asn){
        $asn .= ' '.$asn_desc if($asn_desc);
        $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','asn');
        $iodef->add('IncidentEventDataFlowSystemNodeAddress',$asn);
    }
    if($rir){
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','RIR');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$rir);
    }
    return $iodef->out();
}

# send in a Net::DNS $res and the domain
# returns an array

sub getrdata {
    my ($res,$d) = @_;
    return undef unless($d);

    my @rdata;
    my $q = $res->search($d);
    if($q){
        foreach my $rr ($q->answer()){
            my $address;
            for($rr->type()){
                if(/^PTR$/){
                    $address = $rr->ptrdname();
                    push(@rdata,{ address => $rr->ptrdname(), type => $rr->type(), class => $rr->class(), ttl => $rr->ttl });
                    last;
                }
                if(/^A/){
                    push(@rdata,{ address => $rr->address(), type => $rr->type(), class => $rr->class(), ttl => $rr->ttl });
                    last;
                }
                if(/^CNAME$/){
                    push(@rdata,{ address => $rr->cname(), type => $rr->type(), class => $rr->class(), ttl => $rr->ttl });
                    my $q2 = $res->search($rr->cname());
                    foreach my $rrr (grep { $_->type() eq 'A' } $q2->answer()){
                        push(@rdata,{ cname => $rr->cname(), address => $rrr->address(), type => 'A', class => $rrr->class(), ttl => $rr->ttl()});
                    }
                    last;
                }
            }
        }
    }

    # snag the nameservers
    $q = $res->query($d,'NS');
    if($q){
        foreach my $rr (grep { $_->type eq 'NS' } $q->answer()){
            my $q2 = $res->search($rr->nsdname());
            if($q2){
                foreach my $rrr ( grep { $_->type eq 'A' } $q2->answer()){
                    my $address = ($rr->type() eq 'CNAME') ? $rrr->cname() : $rrr->address();
                    push(@rdata,{ nameserver => $rr->nsdname(), address => $address, type => $rrr->type(), class => $rrr->class(), ttl => $rrr->ttl });
                }
            }
            push(@rdata,{ address => $rr->nsdname(), type => 'NS', class => 'IN', ttl => $rr->ttl() });
        }
    }

    if($#rdata == -1){
        push(@rdata, { address => undef, type => 'A', class => 'IN', ttl => undef });
    }

    return(@rdata);
}

__PACKAGE__->set_sql('by_address' => qq{
    SELECT * 
    FROM __TABLE__
    WHERE lower(address) LIKE lower(?)
    AND NOT EXISTS (
        SELECT lower(address) FROM domains_whitelist WHERE lower(__TABLE__.address) = lower(domains_whitelist.address)
    )
    LIMIT ?
});

__PACKAGE__->set_sql('by_asn' => qq{
    SELECT *
    FROM __TABLE__
    WHERE asn = ?
    AND NOT EXISTS (
        SELECT address from inet_whitelist WHERE __TABLE__.rdata::inet <<= inet_whitelist.address
    )
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;
