package CIF::WebAPI::emails::email;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Email;

sub GET {
    my ($self, $request, $response) = @_;

    my $arg = $self->address();
    my $sql = qq{
        WHERE lower(address) LIKE lower('%$arg%')
        ORDER BY detecttime DESC, created DESC, id DESC
        LIMIT 5000
    };
    my @recs = CIF::Message::Email->retrieve_from_sql($sql);
    unless(@recs){ return undef; }

    my @res = map { CIF::WebAPI::emails::mapIndex($_) } @recs;

    $response->data()->{'result'} = \@res;
    return Apache2::Const::HTTP_OK;
}

1;
