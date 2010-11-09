package CIF::Message::Email;
use base 'CIF::DBI';

use strict;
use warnings;

use XML::IODEF;
use CIF::Message::IODEF;

__PACKAGE__->table('emails');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description address impact source confidence severity restriction alternativeid alternativeid_restriction detecttime created/);
__PACKAGE__->has_a(uuid   => 'CIF::Message');
__PACKAGE__->sequence('emails_id_seq');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    die('missing address') unless($info->{'address'});

    my $uuid    = $info->{'uuid'};
    my $source  = $info->{'source'};
    my $address = $info->{'address'};
    
    $source = CIF::Message::genSourceUUID($source) unless(CIF::Message::isUUID($source));
    $info->{'source'} = $source;

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
    my $confidence  = $info->{'confidence'} || 'low';
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

__PACKAGE__->set_sql('by_address' => qq{
    SELECT *
    FROM __TABLE__
    WHERE lower(address) = lower(?)
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

__PACKAGE__->set_sql('feed' => qq{
    SELECT *
    FROM __TABLE__
    WHERE detecttime >= ?
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;

__END__
