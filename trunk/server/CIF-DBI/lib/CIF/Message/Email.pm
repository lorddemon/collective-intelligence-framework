package CIF::Message::Email;
use base 'CIF::DBI';

use strict;
use warnings;

use XML::IODEF;
use CIF::Message::IODEF;

__PACKAGE__->table('email');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description address impact source confidence severity restriction alternativeid alternativeid_restriction detecttime created/);
__PACKAGE__->sequence('email_id_seq');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    die('missing address') unless($info->{'address'});

    my $uuid    = $info->{'uuid'};
    my $source  = $info->{'source'};
    my $address = $info->{'address'};
    
    $source = CIF::Message::genSourceUUID($source) unless(CIF::Message::isUUID($source));
    $info->{'source'} = $source;

    my $dt = $info->{'detecttime'};
    unless($dt =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/){
        if($dt && ref($dt) ne 'DateTime'){
            if($dt =~ /^\d+$/){
                $dt = DateTime->from_epoch(epoch => $dt);
            } else {
                $dt = DateTime::Format::DateParse->parse_datetime($dt);
                return(undef,'invaild detecttime') unless($dt);
            }
        }
        $info->{'detecttime'} = $dt->ymd().'T'.$dt->hms().'Z';
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

    my $address     = $info->{'address'} || die('no address given');
    my $description = $info->{'description'} || $impact.' - '.$address;
    my $confidence  = $info->{'confidence'} || 0;
    my $severity    = $info->{'severity'} || 'low';
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
    $iodef->add('IncidentAssessmentConfidencerating','numeric');
    $iodef->add('IncidentAssessmentConfidence',$confidence);
    $iodef->add('IncidentAssessmentImpactseverity',$severity);
    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','e-mail');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);

    return $iodef->out();
}

sub lookup {
    my ($self,$arg,$apikey,$limit,$nolog) = @_;
    my $source = CIF::Message::genMessageUUID('api',$apikey);
    my $desc = 'search '.$arg;
    my $col = 'address';
    my $address = $arg;
    my @recs = $self->search($col => $arg);

    return @recs if($nolog);

    my $dt = DateTime->from_epoch(epoch => time());
    $dt = $dt->ymd().'T'.$dt->hour().':00:00Z';
    my $t = $self->table();
    $self->table('email_search');
    my $sid = $self->insert({
        source      => $source,
        address     => $address,
        impact      => 'search',
        description => $desc,
        detecttime  => $dt,
    });
    $self->table($t);
    return @recs;
}

__PACKAGE__->set_sql('by_address' => qq{
    SELECT *
    FROM __TABLE__
    WHERE lower(address) = lower(?)
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;

__END__
