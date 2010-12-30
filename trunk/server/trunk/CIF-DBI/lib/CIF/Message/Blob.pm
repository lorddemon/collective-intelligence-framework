package CIF::Message::Blob;
use base 'CIF::DBI';

use strict;
use warnings;

use Digest::SHA1 qw/sha1_hex/;

__PACKAGE__->table('messages_blob');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid message/);
__PACKAGE__->columns(Essential => qw/id uuid message/);
__PACKAGE__->sequence('messages_unstructured_id_seq');
__PACKAGE__->has_a(uuid => 'CIF::Message');
__PACKAGE__->data_type(message => {pg_type => DBD::Pg::PG_BYTEA});

sub insert {
    my $self = shift;
    my $info = { %{+shift} };
    my $source = $info->{'source'};
    my $msg = $info->{'message'};

    # we do this since UUID truncates a v5 hash at 128bits..
    # bad for similarly sized files
    ## TODO -- change uuids to sha1 hashes
    my $sha1 = sha1_hex($msg);
    my $uuid = CIF::Message::genMessageUUID($source,$sha1.$msg);

    my $mid = CIF::Message->insert({
        uuid        => $uuid,
        source      => $source,
        type        => 'blob',
        format      => $info->{'format'},
        confidence  => $info->{'confidence'},
        severity    => $info->{'severity'},
        description => $info->{'description'},
        impact      => $info->{'impact'},
        restriction => $info->{'restriction'} || 'private',
        detecttime  => $info->{'detecttime'},
    });

    my $id = eval {
        $self->SUPER::insert({
            uuid    => $mid->uuid(),
            message => $msg,
        })
    };
    if($@){
        die $@ unless($@ =~ /unique/);
        $id = $self->retrieve(uuid => $mid->uuid());
    }
    return($id);
}

1;
