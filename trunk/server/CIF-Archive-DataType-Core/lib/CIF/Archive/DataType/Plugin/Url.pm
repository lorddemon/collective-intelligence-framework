package CIF::Archive::DataType::Plugin::Url;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];

use Digest::SHA1 qw(sha1_hex);
use Digest::MD5 qw(md5_hex);
use Encode qw/encode_utf8/;

__PACKAGE__->table('url');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description address impact source url_md5 url_sha1 malware_md5 malware_sha1 confidence severity restriction alternativeid alternativeid_restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid description address restriction created/);
__PACKAGE__->sequence('url_id_seq');

sub prepare {
    my $class = shift;
    my $info = shift;
    return(undef) unless($info->{'impact'});
    return(undef) unless($info->{'impact'} =~ /url$/);
    return(1);
}

sub insert {
    my $self = shift;
    my $info = shift;
    $info->{'address'} = encode_utf8($info->{'address'}) if($info->{'address'});

    my $uuid    = $info->{'uuid'};
    my $address = $info->{'address'};

    my $md5     = $info->{'md5'};
    my $sha1    = $info->{'sha1'};

    if($address){
        $md5 = md5_hex($address) unless($md5);
        $sha1 = sha1_hex($address) unless($sha1);
    } else {
        $info->{'address'} = $md5 || $sha1;
    }

    my $tbl = $self->table();
    foreach($self->plugins()){
        if(my $t = $_->prepare($info)){
            $self->table($t);
        }
    }

    my $id = eval { $self->SUPER::insert({
        uuid            => $info->{'uuid'},
        description     => lc($info->{'description'}),
        address         => $address,
        url_md5         => $md5,
        url_sha1        => $sha1,
        malware_md5     => $info->{'malware_md5'},
        malware_sha1    => $info->{'malware_sha1'},
        source          => $info->{'source'},
        impact          => $info->{'impact'},
        confidence      => $info->{'confidence'},
        severity        => $info->{'severity'},
        restriction     => $info->{'restriction'} || 'private',
        detecttime      => $info->{'detecttime'},
        alternativeid   => $info->{'alternativeid'},
        alternativeid_restriction   => $info->{'alternativeid_restriction'} || 'private',
    }) };
    if($@){
        die unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $self->retrieve(uuid => $uuid);
    }
    $self->table($tbl);
    return($id);
}

sub lookup {
    my $self = shift;
    my $info = shift;
    my $query = $info->{'query'};

    return(undef) unless($query && $query =~ /^[a-fA-F0-9]{32,40}$/);
    my $col = 'address';
    my ($address,$md5,$sha1);
    if($query =~ /^[a-fA-F0-9]{32}$/){
        $col = 'url_md5';
        $md5 = $query;
    } elsif($query =~ /^[a-fA-F0-9]{40}$/){
        $col = 'url_sha1';
        $sha1 = $query;
    } else {
        $col = 'address';
        $address = $query;
    }
    my @recs = $self->search($col => $query);
    return(\@recs);
}

1;

__END__
                                                       
