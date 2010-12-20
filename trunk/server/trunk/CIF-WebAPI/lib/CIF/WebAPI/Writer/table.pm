package CIF::WebAPI::Writer::table;
use strict;

use Text::Table;

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
    
    #Shallow unblessed copy of response
    my @array = @{$resp->{'data'}->{'result'}};
    my @cols = (
        'restriction',
        'asn',
        'asn_desc',
        'cidr',
        'address',
        'rdata',
        'portlist',
        'description',
        'severity',
        'detecttime',
        'created'
    );
    my @header;
    foreach (@cols){
         push(@header,($_,{ is_sep => 1, title => '|', }));
    }
    pop(@header);
    my $t = Text::Table->new(@header);
    foreach my $r (@array){
        $t->load([map { $r->{$_} } @cols]);
    }
    return(Encode::encode_utf8($t));
}

1;
