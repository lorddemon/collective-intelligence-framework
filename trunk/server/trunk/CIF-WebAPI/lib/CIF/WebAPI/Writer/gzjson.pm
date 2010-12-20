package CIF::WebAPI::Writer::gzjson;
use strict;

use JSON::XS;
use IO::Compress::Gzip qw(gzip $GzipError);
use Data::Dumper;

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

sub mimeType{
    return 'application/x-gzip' ;
}

=head2 asBytes

Returns the response as json UTF8 bytes for output.

=cut

sub asBytes{
    my ($self,  $resp ) = @_ ;
    
    #Shallow unblessed copy of response
    # JSON wont output blessed object not implementing the TO_JSON request
    my %resp = %$resp ;
    my $coder = JSON::XS->new->allow_blessed(0)->utf8;
    ## These are bytes. This is correct.
    my $content = $coder->encode(\%resp);
    my $zcontent;
    gzip \$content => \$zcontent;
    return $zcontent;
}

1;
