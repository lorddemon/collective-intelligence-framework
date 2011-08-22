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
        if($_->prepare($info)){
            my $dt = $info->{'detecttime'};
            # default it to the hour
            unless($dt){
                $dt = DateTime->from_epoch(epoch => time());
                $dt = $dt->ymd().'T'.$dt->hour().':00:00Z';
            }
            $info->{'detecttime'} = $dt;
            $info->{'format'}   = 'iodef';
            return(1);
        } 
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
    my $relatedid                   = $info->{'relatedid'};
    my $detecttime                  = $info->{'detecttime'};
    my $alternativeid               = $info->{'alternativeid'};
    my $alternativeid_restriction   = $info->{'alternativeid_restriction'} || 'private';
    my $protocol                    = $info->{'protocol'};
    my $portlist                    = $info->{'portlist'};
    my $purpose                     = $info->{'purpose'} || 'mitigation';
    my $guid                        = $info->{'guid'};

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
    $iodef->add('IncidentAdditionalDatameaning','guid');
    $iodef->add('IncidentAdditionalDatadtype','string');

    $iodef->add('IncidentAdditionalData',$guid) if($guid);

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
    if($severity && $severity =~ /(low|medium|high)/){
        $iodef->add('IncidentAssessmentImpactseverity',$severity);
    }

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
    my $uuid = shift;

    $data = $class->data_hash($data,$uuid);
    require CIF::Client::Plugin::Iodef;
    $data = CIF::Client::Plugin::Iodef->hash_simple($data);
    return($data);
}

sub data_hash {
    my $class = shift;
    my $data = shift;
    my $uuid = shift;
    require JSON;
    my $hash = JSON::from_json($data);
    $hash->{'Incident'}->{'IncidentID'}->{'content'} = $uuid;
    return($hash);
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
