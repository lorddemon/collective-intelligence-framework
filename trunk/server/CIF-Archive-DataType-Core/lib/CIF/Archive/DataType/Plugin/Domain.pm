package CIF::Archive::DataType::Plugin::Domain;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => ['CIF::Archive::DataType::Plugin::Domain'];

use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;
use DateTime::Format::DateParse;
use Data::Dumper;
use DateTime;
use IO::Select;

__PACKAGE__->table('domain');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description address type rdata cidr asn asn_desc cc rir class ttl whois impact confidence source alternativeid alternativeid_restriction severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid description address rdata impact restriction created/);
__PACKAGE__->sequence('domain_id_seq');

my $tests = {
    'severity'      => qr/^(low|medium|high)$/,
    'confidence'    => qr/^\d+/,
    'address'       => qr/[a-zA-Z0-9.-]+\.[a-zA-Z]{2,5}$/,
};

sub prepare {
    my $class = shift;
    my $info = shift;

    my $address = $info->{'address'} || return(undef);
    return(undef) unless($address =~ /^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,5}$/);
    return(0,'invalid address: whitelisted -- '.$address) if(isWhitelisted($address));
    return(1);
}

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

    my $uuid    = $info->{'uuid'};

    # work-around for domain_whitelist and cif_feed_parser
    if(exists($info->{'severity'})){
        delete($info->{'severity'}) unless($info->{'severity'});
    }

    my $id = eval { $self->SUPER::insert({
        uuid        => $uuid,
        description => lc($info->{'description'}),
        address     => $info->{'address'},
        type        => $info->{'type'},
        rdata       => $info->{'rdata'},
        cidr        => $info->{'cidr'},
        asn         => $info->{'asn'},
        asn_desc    => $info->{'asn_desc'},
        cc          => $info->{'cc'},
        rir         => $info->{'rir'},
        class       => $info->{'class'},
        ttl         => $info->{'ttl'},
        source      => $info->{'source'},
        impact      => $info->{'impact'} || 'malicious domain',
        confidence  => $info->{'confidence'},
        severity    => $info->{'severity'},
        restriction => $info->{'restriction'} || 'private',
        detecttime  => $info->{'detecttime'},
        alternativeid => $info->{'alternativeid'},
        alternativeid_restriction => $info->{'alternativeid_restriction'} || 'private',
    }) };
    if($@){
        return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $self->retrieve(uuid => $uuid);
    }
    $self->table($tbl);
    return($id);    
}

# send in a Net::DNS $res and the domain
# returns an array

sub getrdata {
    my ($res,$d) = @_;
    return undef unless($d);

    my @rdata;

    if($res){
        my $default = $res->bgsend($d);
        my $ns      = $res->bgsend($d,'NS');
        my $mx      = $res->bgsend($d,'MX');
        
        my $sel = IO::Select->new([$mx,$ns,$default]);
        my @ready = $sel->can_read(5);
        
        if(@ready){
            foreach my $sock (@ready){
                for($sock){
                    $default    = $res->bgread($default) if($default);
                    $ns         = $res->bgread($ns) if($ns);
                    $mx         = $res->bgread($mx) if($mx);
                }
                $sel->remove($sock);
                $sock = undef;
            }
        }
        if(ref($default) eq 'Net::DNS::Packet' && $default->answer()){
            push(@rdata,$default->answer());
        } else {
            push(@rdata, { name => $d, address => undef, type => 'A', class => 'IN', ttl => -1 });
        }
        push(@rdata,$ns->answer()) if(ref($ns) eq 'Net::DNS::Packet');
        push(@rdata,$mx->answer()) if(ref($mx) eq 'Net::DNS::Packet');
    }

    if($#rdata == -1){
        push(@rdata, { name => $d, address => undef, type => 'A', class => 'IN', ttl => undef });
    }

    return(@rdata);
}

sub lookup {
    my $self = shift;
    my $info = shift;
    my $address = $info->{'query'};

    return(undef) unless($address && lc($address) =~ /^[a-z0-9.-]+\.[a-z]{2,5}$/);
    return($self->SUPER::lookup($address,$info->{'limit'}));
}

sub isWhitelisted {
    my $self = shift;
    my $a = shift;

    return undef unless($a && $a =~ /\.[a-zA-Z]{2,4}$/);
    return(1) unless($a =~ /\.[a-zA-Z]{2,4}$/);

    my $sql = '';

    ## TODO -- do this by my $parts = split(/\./,$a); foreach ....
    for($a){
        if(/([a-zA-Z0-9-]+\.[a-zA-Z]{2,4})$/){
            $sql .= qq{address LIKE '$1'};
        }
        if(/((?:[a-zA-Z0-9-]+\.){2,2}[a-zA-Z]{2,4})$/){
            $sql .= qq{ OR address LIKE '$1'};
        }
        if(/((?:[a-zA-Z0-9-]+\.){3,3}[a-zA-Z]{2,4})$/){
            $sql .= qq{ OR address LIKE '$1'};
        }
        if(/((?:[a-zA-Z0-9-]+\.){4,4}[a-zA-Z]{2,4})$/){
            $sql .= qq{ OR address LIKE '$1'};
        }
    }
    #if($sql eq ''){ return(0); }

    $sql .= qq{\nORDER BY detecttime DESC, created DESC, id DESC};
    my $t = $self->table();
    $self->table('domain_whitelist');
    my @recs = $self->retrieve_from_sql($sql);
    $self->table($t);
    return @recs;
}

__PACKAGE__->set_sql('feed' => qq{
    SELECT * FROM __TABLE__
    WHERE detecttime > ?
    AND type = 'A'
    AND severity >= ?
    AND restriction <= ?
    AND NOT (lower(impact) = 'search' OR lower(impact) = 'domain whitelist' OR lower(impact) LIKE '% whitelist %')
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

__PACKAGE__->set_sql('lookup' => qq{
    SELECT * FROM __TABLE__
    WHERE lower(address) LIKE lower(?)
    AND lower(impact) NOT LIKE '% whitelist %'
    LIMIT ?
});

1;
