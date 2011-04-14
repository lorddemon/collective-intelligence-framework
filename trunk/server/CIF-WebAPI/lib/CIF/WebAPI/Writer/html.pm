package CIF::WebAPI::Writer::html;

use strict;
use warnings;

use Encode qw/encode_utf8/;

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
    return 'text/html';
}

=head2 asBytes

Returns the response as json UTF8 bytes for output.

=cut

sub asBytes{
    my ($self,  $resp ) = @_ ;
    
    my $text = $resp->{'data'}->{'result'};
    return(Encode::encode_utf8($text));
}

1;
