package CIF::Message::Structured;
use base 'CIF::DBI';

use CIF::Message;

use strict;
use warnings;

__PACKAGE__->table('messages_structured');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid source message/);
__PACKAGE__->columns(Essential => qw/id uuid source message/);
__PACKAGE__->sequence('messages_structured_id_seq');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = { %{+shift} };
    my $source = $info->{'source'};
    my $msg = $info->{'message'};

    die('source must be a vaild v3 uuid') unless(CIF::Message::isUUID($source));

    my $uuid = CIF::Message::genMessageUUID($source,$msg);

    my $mid = CIF::Message->insert({
        uuid        => $uuid,
        source      => $source,
        type        => 'structured',
        format      => $info->{'format'},
        confidence  => $info->{'confidence'},
        severity    => $info->{'severity'},
        description => $info->{'description'},
        impact      => $info->{'impact'},
        restriction => $info->{'restriction'},
        detecttime  => $info->{'detecttime'},
        reporttime  => $info->{'reporttime'},
    }); 
    
    my $id = eval {
        $self->SUPER::insert({
            uuid    => $mid->uuid(),
            source  => $source,
            message => $msg,
        })
    };
    if($@){
        die $@ unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $self->retrieve(uuid => $mid->uuid());
    }
    return($id);
}
