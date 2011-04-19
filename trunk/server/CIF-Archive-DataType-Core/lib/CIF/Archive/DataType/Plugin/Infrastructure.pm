package CIF::Archive::DataType::Plugin::Infrastructure;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => ['CIF::Archive::DataType::Plugin::Infrastructure'];

use Net::CIDR;
use Net::Abuse::Utils qw(:all);
use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR ();

__PACKAGE__->table('infrastructure');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description impact address cidr asn asn_desc cc rir protocol portlist confidence source severity restriction alternativeid alternativeid_restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid description address restriction created/);
__PACKAGE__->sequence('infrastructure_id_seq');

my @list = (
    "0.0.0.0/8",
    "10.0.0.0/8",
    "127.0.0.0/8",
    "192.168.0.0/16",
    "169.254.0.0/16",
    "192.0.2.0/24",
    "224.0.0.0/4",
    "240.0.0.0/5",
    "248.0.0.0/5"
);

sub prepare {
    my $class = shift;
    my $info = shift;

    my $address = $info->{'address'} || return(undef);
    return(undef) unless($address =~ /^$RE{'net'}{'IPv4'}/);
    return(0,'invalid address: private address space -- '.$address) if(isPrivateAddress($address));
    return(0,'invalid address: whitelisted -- '.$address) if(isWhitelisted($address));
    unless($info->{'asn'} || $info->{'cidr'}){
        my ($as,$network,$ccode,$rir,$date,$as_desc) = asninfo($info->{'address'});
        $info->{'asn'}  = $as;
        $info->{'cidr'} = $network;
        $info->{'cc'}   = $ccode;
        $info->{'rir'}  = $rir;
        $info->{'asn_desc'} = $as_desc;
    }
    return(1);
}

sub isPrivateAddress {
    my $addr = shift;
    return(undef) unless($addr && $addr =~ /^$RE{'net'}{'IPv4'}$/ || $addr =~ /^$RE{'net'}{'CIDR'}{'IPv4'}$/);
    my $found = Net::CIDR::cidrlookup($addr,@list);
    return($found);
}

sub asninfo {
    my $a = shift;
    return undef unless($a);
    my ($as,$network,$ccode,$rir,$date) = get_asn_info($a);
    my $as_desc;
    $as_desc = get_as_description($as) if($as);

    $as         = undef if($as && $as eq 'NA');
    $network    = undef if($network && $network eq 'NA');
    $ccode      = undef if($ccode && $ccode eq 'NA');
    $rir        = undef if($rir && $rir eq 'NA');
    $date       = undef if($date && $date eq 'NA');
    $as_desc    = undef if($as_desc && $as_desc eq 'NA');
    $a          = undef if($a eq '');
    return ($as,$network,$ccode,$rir,$date,$as_desc);
}

my $tests = {
    'severity'      => qr/^(low|medium|high||)$/,
    'address'       => qr/^$RE{'net'}{'IPv4'}/,
    'confidence'    => qr/\d+/,
};

sub insert {
    my $self = shift;
    my $info = shift;

    my ($ret,$err) = $self->check_params($tests,$info);
    return($ret,$err) unless($ret);

    my $tbl = $self->table();
    foreach($self->plugins()){
        if(my $t = $_->prepare($info)){
            $self->table($t);
        }
    }

    my $proto = convertProto($info->{'protocol'});
    my $uuid = $info->{'uuid'};
    $info->{'protocol'} = $proto;

    my $id = eval { $self->SUPER::insert({
        uuid        => $uuid,
        description => lc($info->{'description'}),
        impact      => $info->{'impact'},
        address     => $info->{'address'},
        cidr        => $info->{'cidr'},
        asn         => $info->{'asn'},
        asn_desc    => $info->{'asn_desc'},
        cc          => $info->{'cc'},
        rir         => $info->{'rir'},
        protocol    => $info->{'protocol'},
        portlist    => $info->{'portlist'},
        confidence  => $info->{'confidence'},
        source      => $info->{'source'},
        severity    => $info->{'severity'},
        restriction => $info->{'restriction'} || 'private',
        detecttime  => $info->{'detecttime'},
        impact      => $info->{'impact'},
        alternativeid   => $info->{'alternativeid'},
        alternativeid_restriction => $info->{'alternativeid_restriction'} || 'private',
    }) };
    if($@){
        return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $self->retrieve(uuid => $uuid);
    }
    $self->table($tbl);
    return($id);
}

sub convertProto {
    my $proto = shift;
    return unless($proto);
    return($proto) if($proto =~ /^\d+$/);

    for(lc($proto)){
        if(/^tcp$/){ $proto = 6; }
        if(/^udp$/){ $proto = 17; }
        if(/^icmp$/){ $proto = 1; }
    }
    $proto = undef unless($proto =~ /^\d+$/);
    return($proto);
}

sub lookup {
    my $self = shift;
    my $info = shift;
    my $address = $info->{'query'};
    my $limit = $info->{'limit'} || 5000;
    return(undef) unless($address && $address =~ /^$RE{'net'}{'IPv4'}/);
    my $asn;
    if($address !~ /^$RE{net}{IPv4}/){
        $asn = $address;
        $asn =~ s/^(AS|as)//;
        $address = '0/0';
    } elsif($address =~ /^$RE{net}{CIDR}{IPv4}{-keep}$/){
        return undef if($2 < 8);
    }

    my @args;
    my $sth;
    if($asn){
        $sth = $self->sql__by_asn();
        push(@args,($asn,$limit));
    } else {
        $sth = $self->sql_by_address();
        push(@args,($address,$address,$limit));
    }
    my $r = $sth->execute(@args);
    my $ret = $sth->fetchall_hash();
    return($ret);
}

sub isWhitelisted {
    my $self = shift;
    my $a = shift;

    return undef unless($a);

    my $sql = qq{
        family(address) = 4 AND masklen(address) < 32 AND '$a' <<= address 
        ORDER BY detecttime DESC, created DESC, id DESC
    };

    my $t = $self->table();
    $self->table('infrastructure_whitelist');
    my @ret = $self->retrieve_from_sql($sql);
    $self->table($t);
    return @ret;
}

__PACKAGE__->set_sql('by_address' => qq{
    SELECT * FROM __TABLE__
    WHERE address != '0/0'
    AND (address >>= ? OR address <<= ?)
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

__PACKAGE__->set_sql('by_asn' => qq{
    SELECT * FROM __TABLE__
    WHERE asn = ?
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;

__END__
