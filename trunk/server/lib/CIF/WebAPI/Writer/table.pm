package CIF::WebAPI::Writer::table;

use JSON;
use MIME::Base64;
use Compress::Zlib;
require CIF::Client;

=head1 NAME

Apache2::REST::Writer::table - Apache2::REST::Response Writer for Text::Table

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
    
    return $resp->{'message'} if($resp->{'message'});
    return 'no records, check back later' unless($resp->{'data'});
    my $hash = $resp;
    require CIF::Client;

    my $t = ref(@{$hash->{'data'}->{'feed'}->{'entry'}}[0]) || '';
    unless($t eq 'HASH'){
        my $r = @{$hash->{'data'}->{'feed'}->{'entry'}}[0];
        return unless($r);
        $r = uncompress(decode_base64($r));
        $r = from_json($r);
        $hash->{'data'}->{'feed'}->{'entry'} = $r;
    }
    if(1 || $args{'conf'}->{'simple'}){
        CIF::Client->hash_simple($hash);
    }
 
    my $t = CIF::Client::Plugin::Table->write_out(undef,$hash->{'data'},undef);
    return($t);
}

1;
