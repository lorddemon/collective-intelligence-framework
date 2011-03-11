package CIF::Message::Structured;
use base 'CIF::DBI';

use strict;
use warnings;

__PACKAGE__->table('message_structured');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid format description message detecttime created source restriction/);
__PACKAGE__->columns(Essential => qw/id uuid format description message/);
__PACKAGE__->sequence('message_structured_id_seq');

use CIF::Message;

sub insert {
    my $self = shift;
    my $info = { %{+shift} };
    my $source = $info->{'source'};
    my $msg = $info->{'message'};

    die('source must be a vaild v3 uuid') unless(CIF::Message::isUUID($source));

    my $uuid = CIF::Message::genMessageUUID($source,$msg);

    my $mid = CIF::Message->insert({
        uuid        => $uuid,
        type        => 'structured',
        format      => $info->{'format'},
        description => $info->{'description'},
        restriction => $info->{'restriction'},
        created     => $info->{'created'},
        message     => $info->{'message'},
        source      => $info->{'source'},
    }); 

    my $id = eval {
        $self->SUPER::insert({
            uuid    => $uuid,
            %$info,
        })
    };
    if($@){
        die $@ unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $self->retrieve(uuid => $mid->uuid());
    }
    return($id);
}

