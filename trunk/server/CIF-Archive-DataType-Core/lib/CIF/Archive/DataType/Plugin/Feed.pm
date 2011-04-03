package CIF::Archive::DataType::Plugin::Feed;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable search_path => ['CIF::Archive::DataType::Plugin::Feed'], require => 1, except => qr/Feed::\S+::/;

__PACKAGE__->set_table('feed');
__PACKAGE__->columns(All => qw/id uuid description source hash_sha1 signature impact severity restriction detecttime created data/);
__PACKAGE__->columns(Essential => qw/id uuid description source hash_sha1 signature impact severity restriction detecttime created data/);
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->sequence('feed_id_seq');

sub prepare {
    my $class = shift;
    my $info = shift;

    return(undef) unless($info->{'impact'} =~ /feed/);
    return(1);
}

sub insert {
    my $self = shift;
    my $info = shift;
    my $uuid = $info->{'uuid'};

    my $tbl = $self->table();
    foreach($self->plugins()){
        if(my $t = $_->prepare($info)){
            $self->table($t);
        }
    }

    my $id = eval {
        $self->SUPER::insert($info)
    };
    if($@){
        return(undef,$@) unless($@ =~ /unique/);
        $id = $self->retrieve(uuid => $uuid);
    }
    $self->table($tbl);
    return($id);
}

__PACKAGE__->set_sql('lookup' => qq{
    SELECT * FROM __TABLE__
    WHERE impact = ?
    AND severity = ?
    and restriction = ?
    ORDER BY id DESC LIMIT 1
});

sub lookup {
    my $class = shift;
    my $info = shift;

    my $severity = $info->{'severity'};
    my $restriction = $info->{'restriction'};
    
    my $query = $info->{'query'}.' feed';
    my $sth = $class->sql_lookup();
    my $r = $sth->execute($query,$severity,$restriction);
    my $ret = $sth->fetchall_hash();
    return($ret);
}

1;
