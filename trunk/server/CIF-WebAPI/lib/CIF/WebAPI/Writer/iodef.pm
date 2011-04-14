package CIF::WebAPI::Writer::iodef;
use strict;
use warnings;

use Data::Dumper;
use XML::IODEF;

=head1 NAME

Apache2::REST::Writer::json - Apache2::REST::Response Writer for json

=cut

=head2 new

=cut

sub new{
    my ( $class ) = @_;
    return bless {} , $class;
}

=head2 mimeType

Getter

=cut

sub mimeType {
    return 'text/plain';
}

=head2 asBytes

Returns the response as json UTF8 bytes for output.

=cut

sub asBytes{
    my ($self,  $resp ) = @_ ;
    
    my $f = $resp->{'data'}->{'feed'};
    my @e = @{$f->{'entry'}};
    my $iodef = XML::IODEF->new();
    ## TODO -- need to re-map this out
    #$iodef->add('Incidentrestriction',$f->{'restriction'});
    warn Dumper($f);
    $iodef->add('IncidentDetectTime',$f->{'detecttime'});
    $iodef->add('IncidentDescription',$f->{'description'});

    if(ref($e[0]) eq 'HASH'){
        foreach(@e){
            ## TODO -- need to re-map this out
            #$iodef->add('IncidentEventDatarestriction',$_->{'restriction'});
            $iodef->add('IncidentEventDatarestriction','private');
            $iodef->add('IncidentEventDataDescription',$_->{'description'});
            $iodef->add('IncidentEventDataAssessmentImpact',$_->{'impact'});
            $iodef->add('IncidentEventDataFlowSystemrestriction','private');
            $iodef->add('IncidentEventDataFlowSystemNodeAddress',$_->{'address'});
            $iodef->add('IncidentEventDataFlowSystemNodeAddressportlist',$_->{'portlist'}) if($_->{'portlist'});
            $iodef->add('IncidentEventDataFlowSystemNodeAddressprotocol',$_->{'protocol'}) if($_->{'protocol'});
        }
    } else {
         #$entry->content($e[0], { mode => 'base64' });
         $iodef->add('IncidentEventDataRecordRecordDataRecordItemdtype','string');
         $iodef->add('IncidentEventDataRecordRecordDataRecordItemmeaning','feed');
         $iodef->add('IncidentEventDataRecordRecordDataRecordItem',$e[0]);
    }
    return($iodef->out());

}

1;
