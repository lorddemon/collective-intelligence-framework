package CIF::Message::Domain;
use base 'CIF::DBI';

use strict;
use warnings;

use CIF::Message::IODEF;
use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;
use DateTime::Format::DateParse;
use Data::Dumper;
use DateTime;
use IO::Select;

__PACKAGE__->table('domain');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description address type rdata cidr asn asn_desc cc rir class ttl whois impact confidence source alternativeid alternativeid_restriction severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid description address rdata impact restriction created/);
__PACKAGE__->sequence('domain_id_seq');

my $tests = {
    'severity'      => qr/^(low|medium|high)$/,
    'confidence'    => qr/^\d+/,
    'address'       => qr/[a-zA-Z0-9.-]+\.[a-zA-Z]{2,5}$/,
};

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    my ($ret,$err) = $self->check_params($tests,$info);
    return($ret,$err) unless($ret);

    my $uuid    = $info->{'uuid'};
    my $source  = $info->{'source'};
    
    $source = CIF::Message::genSourceUUID($source) unless(CIF::Message::isUUID($source));
    $info->{'source'} = $source;

    my $dt = $info->{'detecttime'};
    if($dt){
        $dt = DateTime::Format::DateParse->parse_datetime($dt);
        unless($dt){
            return(undef,'invalid datetime');
        }
        $dt = $dt->dmy().'T'.$dt->hms().'Z';
    }

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
        return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $self->retrieve(uuid => $uuid);
    }
    return($id);    
}

sub toIODEF {

    my $self = shift;
    my $info = {%{+shift}};

    my $impact      = $info->{'impact'};
    my $address     = $info->{'address'} || return(undef,'no address given');
    my $description = $info->{'description'};
    my $confidence  = $info->{'confidence'};
    my $severity    = $info->{'severity'};
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
    if($confidence){
        $iodef->add('IncidentAssessmentConfidencerating','numeric');
        $iodef->add('IncidentAssessmentConfidence',$confidence);
    }
    $iodef->add('IncidentAssessmentImpactseverity',$severity) if($severity);
    $iodef->add('IncidentEventDataFlowSystemNodeLocation',$cc) if($cc);
    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeAddressext-category','domain');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);
    if($rdata){
        ## TODO -- autodetect Addresscategory with regex
        my $cat = 'domain';
        for($rdata){
            if(/^$RE{net}{CIDR}{IPv4}$/){
                $cat = 'ipv4-net';
                last;
            }
            if(/^$RE{net}{IPv4}$/){
                $cat = 'ipv4-addr';
                last;
            }
        }
        if($cat eq 'domain'){
            $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ext-value');
            $iodef->add('IncidentEventDataFlowSystemNodeAddressext-category',$cat);
        } else {
            $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory',$cat);
        }
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

    if($res){
        my $default = $res->bgsend($d);
        my $ns      = $res->bgsend($d,'NS');
        my $mx      = $res->bgsend($d,'MX');
        
        my $sel = IO::Select->new([$mx,$ns,$default]);
        my @ready = $sel->can_read(5);
        
        if(@ready){
            foreach my $sock (@ready){
                for($sock){
                    $default    = $res->bgread($default) if($default);
                    $ns         = $res->bgread($ns) if($ns);
                    $mx         = $res->bgread($mx) if($mx);
                }
                $sel->remove($sock);
                $sock = undef;
            }
        }
        if(ref($default) eq 'Net::DNS::Packet' && $default->answer()){
            push(@rdata,$default->answer());
        } else {
            push(@rdata, { name => $d, address => undef, type => 'A', class => 'IN', ttl => undef });
        }
        push(@rdata,$ns->answer()) if(ref($ns) eq 'Net::DNS::Packet');
        push(@rdata,$mx->answer()) if(ref($mx) eq 'Net::DNS::Packet');
    }

    if($#rdata == -1){
        push(@rdata, { name => $d, address => undef, type => 'A', class => 'IN', ttl => undef });
    }

    return(@rdata);
}

sub lookup {
    my ($self,$address,$apikey,$limit) = @_;
    $limit = 5000 unless($limit);
    my @recs;
    if($address =~ /^$RE{'net'}{'IPv4'}/){
        @recs = $self->search_rdata($address,$limit);
    } else {
        @recs = $self->search_by_address('%'.$address.'%',$limit);
    }

    my $t = $self->table();
    $self->table('domain_search');
    my $source = CIF::Message::genMessageUUID('api',$apikey);
    my $asn;
    my $description = 'search '.$address;
    my $dt = DateTime->from_epoch(epoch => time());
    $dt = $dt->ymd().'T'.$dt->hour().':00:00Z';

    my $sid = $self->insert({
        address => $address,
        impact  => 'search',
        source  => $source,
        description => $description,
        detecttime  => $dt,
    });
    $self->table($t);
    return @recs;
}

sub isWhitelisted {
    my $self = shift;
    my $a = shift;

    return undef unless($a && $a =~ /\.[a-zA-Z]{2,4}$/);
    return(1) unless($a =~ /\.[a-zA-Z]{2,4}$/);

    my $sql = '';

    ## TODO -- do this by my $parts = split(/\./,$a); foreach ....
    for($a){
        if(/([a-zA-Z0-9-]+\.[a-zA-Z]{2,4})$/){
            $sql .= qq{address LIKE '$1'};
        }
        if(/((?:[a-zA-Z0-9-]+\.){2,2}[a-zA-Z]{2,4})$/){
            $sql .= qq{ OR address LIKE '$1'};
        }
        if(/((?:[a-zA-Z0-9-]+\.){3,3}[a-zA-Z]{2,4})$/){
            $sql .= qq{ OR address LIKE '$1'};
        }
        if(/((?:[a-zA-Z0-9-]+\.){4,4}[a-zA-Z]{2,4})$/){
            $sql .= qq{ OR address LIKE '$1'};
        }
    }
    $sql .= qq{\nORDER BY detecttime DESC, created DESC, id DESC};
    my $t = $self->table();
    $self->table('domain_whitelist');
    my @recs = $self->retrieve_from_sql($sql);
    $self->table($t);
    return @recs;
}

__PACKAGE__->set_sql('feed' => qq{
    SELECT * FROM __TABLE__
    WHERE type = 'A'
    AND severity >= ?
    AND restriction <= ?
    AND NOT (lower(impact) = 'search' OR lower(impact) = 'domain whitelist' OR lower(impact) LIKE '% whitelist %')
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

__PACKAGE__->set_sql('by_address' => qq{
    SELECT * FROM __TABLE__
    WHERE lower(address) LIKE lower(?)
    AND lower(impact) NOT LIKE '% whitelist %'
    LIMIT ?
});

__PACKAGE__->set_sql('by_rdata' => qq{
    SELECT * FROM __TABLE__
    WHERE lower(rdata) LIKE lower(?)
    ORDER BY detecttime DESC, created DESC, id DESC,
    LIMIT ?
});

__PACKAGE__->set_sql('by_asn' => qq{
    SELECT * FROM __TABLE__
    WHERE asn = ?
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;
