package CIF::Message::Url;
use base 'CIF::DBI';

use strict;
use warnings;

use XML::IODEF;
use CIF::Message::IODEF;
use Digest::SHA1 qw(sha1_hex);
use Digest::MD5 qw(md5_hex);

__PACKAGE__->table('url');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description address impact source url_md5 url_sha1 malware_md5 malware_sha1 confidence severity restriction alternativeid alternativeid_restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid description address restriction created/);
__PACKAGE__->has_a(uuid   => 'CIF::Message');
__PACKAGE__->sequence('url_id_seq');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    my $uuid    = $info->{'uuid'};
    my $source  = $info->{'source'};
    my $address = $info->{'address'};
    
    $source = CIF::Message::genSourceUUID($source) unless(CIF::Message::isUUID($source));
    $info->{'source'} = $source;

    my $md5     = $info->{'md5'};
    my $sha1    = $info->{'sha1'};
    
    if($address){
        $md5 = md5_hex($address) unless($md5);
        $sha1 = sha1_hex($address) unless($sha1);
    } else {
        $info->{'address'} = $md5 || $sha1;
    }

    unless($uuid){
        $uuid = CIF::Message::IODEF->insert({
            message => $self->toIODEF($info)
        });
        $uuid = $uuid->uuid();
    }
    
    my $id = eval { $self->SUPER::insert({
        uuid            => $uuid,
        description     => $info->{'description'},
        address         => $info->{'address'},
        url_md5         => $md5,
        url_sha1        => $sha1,
        malware_md5     => $info->{'malware_md5'},
        malware_sha1    => $info->{'malware_sha1'},
        source          => $source,
        impact          => $info->{'impact'},
        confidence      => $info->{'confidence'},
        severity        => $info->{'severity'},
        restriction     => $info->{'restriction'} || 'private',
        detecttime      => $info->{'detecttime'},
        alternativeid   => $info->{'alternativeid'},
        alternativeid_restriction   => $info->{'alternativeid_restriction'} || 'private',
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
    die('invalid impact type') unless(lc($impact) =~ /^(search|phishing|malware|spam|botnet)/);

    my $address     = $info->{'address'};
    my $description = $info->{'description'} || $impact.' '.$address;
    my $confidence  = $info->{'confidence'};
    my $severity    = $info->{'severity'};
    my $restriction = $info->{'restriction'} || 'private';
    my $source      = $info->{'source'};
    my $sourceid    = $info->{'sourceid'};
    my $relatedid   = $info->{'relatedid'};
    my $detecttime  = $info->{'detecttime'};
    my $alternativeid  = $info->{'alternativeid'};
    my $alternativeid_restriction = $info->{'alternativeid_restriction'} || 'private';

    my $iodef = XML::IODEF->new();
    $iodef->add('IncidentIncidentIDname',$source);
    $iodef->add('IncidentDetectTime',$detecttime) if($detecttime);
    $iodef->add('IncidentRelatedActivityIncidentID',$relatedid) if($relatedid);
    if($alternativeid){
        $iodef->add('IncidentAlternativeIDIncidentID',$alternativeid);
        $iodef->add('IncidentAlternativeIDIncidentIDrestriction',$alternativeid_restriction);
    }
    $iodef->add('Incidentrestriction',$restriction);
    $iodef->add('IncidentDescription',$description);
    $iodef->add('IncidentAssessmentImpact',$impact);
    if($confidence){
        $iodef->add('IncidentAssessmentConfidencerating','numeric');
        $iodef->add('IncidentAssessmentConfidence',$confidence);
    }
    if($severity){
        $iodef->add('IncidentAssessmentImpactseverity',$severity);
    }
    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeAddressext-category','url');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address) if($address);

    return $iodef->out();
}

sub lookup {
    my ($self,$arg,$apikey) = @_;
    my $source = CIF::Message::genMessageUUID('api',$apikey);
    my $desc = 'search '.$arg;
    my $col = 'address';
    my ($address,$md5,$sha1);
    if($arg =~ /^[a-fA-F0-9]{32}$/){
        $col = 'url_md5';
        $md5 = $arg;
    } elsif($arg =~ /^[a-fA-F0-9]{40}$/){
        $col = 'url_sha1';
        $sha1 = $arg;
    } else {
        $col = 'address';
        $address = $arg;
    }
    my @recs = $self->search($col => $arg);
    my $dt = DateTime->from_epoch(epoch => time());
    $dt = $dt->ymd().'T'.$dt->hour().':00:00Z'; 
    my $t = $self->table();
    $self->table('url_search');
    my $sid = $self->insert({
        source      => $source,
        address     => $address,
        impact      => 'search',
        description => $desc,
        md5         => $md5,
        sha1        => $sha1,
        detecttime  => $dt,
    });
    $self->table($t);
    return @recs;
}

1;

__END__
