package CIF::Message::Feed;
use base 'CIF::DBI';

use strict;
use warnings;

__PACKAGE__->table('feed');
__PACKAGE__->columns(All => qw/id uuid description source hash_sha1 signature impact severity restriction detecttime created message/);
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->sequence('feed_id_seq');

use CIF::Message::Unstructured;
use Data::Dumper;

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    unless(CIF::Message::isUUID($info->{'source'})){
        $info->{'source'} = CIF::Message::genSourceUUID($info->{'source'});
    };

    my $bid = CIF::Message::Unstructured->insert(
        $info,
    );
    delete($info->{'format'});

    my $id = eval {
        $self->SUPER::insert({
            uuid    => $bid->uuid(),
            %$info,
        })
    };
    if($@){
        return(undef,$@) unless($@ =~ /unique/);
        $id = $self->retrieve(uuid => $bid->uuid());
    }
    
    return($id);
}

sub aggregateFeed {
    my $self = shift;
    my $key = shift;
    my @recs = @_;

    my $hash;
    my @feed;
    foreach (@recs){
        if(exists($hash->{$_->$key()})){
            if($_->restriction() eq 'private'){
                next unless($_->restriction() eq 'need-to-know');
            }
        }
        $hash->{$_->$key()} = $_;
    }
    return(map { $hash->{$_} } keys(%$hash));
}

sub mapIndex {
    my $self = shift;
    my $rec = shift;
    my $msg = CIF::Message::Structured->retrieve(uuid => $rec->uuid());
    die ::Dumper($rec) unless($msg);
    $msg = $msg->message();
    return {
        rec         => $rec,
        restriction => $rec->restriction(),
        severity    => $rec->severity(),
        impact      => $rec->impact(),
        confidence  => $rec->confidence(),
        description => $rec->description(),
        detecttime  => $rec->detecttime(),
        uuid        => $rec->uuid(),
        alternativeid   => $rec->alternativeid(),
        alternativeid_restriction   => $rec->alternativeid_restriction(),
        created     => $rec->created(),
        message     => $msg,
    };
}

1;
