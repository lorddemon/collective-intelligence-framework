package CIF::Message::DomainSimple;
use base 'CIF::Message::Domain';

use strict;
use warnings;

use CIF::Message::Infrastructure;
use CIF::Message::InfrastructureSimple;
use CIF::Message::DomainMalware;
use CIF::Message::DomainBotnet;
use CIF::Message::DomainFastflux;
use CIF::Message::DomainNameserver;
use Data::Dumper;

use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    return (undef,'invalid address: whitelisted') if(CIF::Message::Domain::isWhitelisted($info->{'address'}));

    my @ids;
    my @results = CIF::Message::Domain::getrdata($info->{'nsres'},$info->{'address'});

    my $bucket = 'CIF::Message::DomainMalware';
    my $impact = lc($info->{'impact'});
    my $description = $info->{'description'};

    for(lc($impact)){
        if(/fastflux/){
            $bucket = 'CIF::Message::DomainFastflux';
            last;
        }
        if(/nameserver/){
            $bucket = 'CIF::Message::DomainNameserver';
            last;
        }
        if(/botnet/){
            $bucket = 'CIF::Message::DomainBotnet';
            last;
        }
    }

    foreach my $r (@results){
        my %hash = %$info;
        my ($id,$err) = $self->_insert($bucket,{%hash},$r);
        return(undef,$err) unless($id);
        push(@ids,$id);
    }

    # do the same for the nameservers
    $info->{'severity'} = ($info->{'severity'} eq 'high') ? 'medium' : 'low';
    $info->{'confidence'} = ($info->{'confidence'}) ? ($info->{'confidence'} - 2) : 0;
    foreach my $r (grep { $_->{'type'} eq 'NS' } @results){
        my @recs = CIF::Message::Domain::getrdata($info->{'nsres'},$r->{'nsdname'});
        foreach my $rec (grep { $_->{'type'} eq 'A' } @recs){
            my %hash = %$info;
            $hash{'impact'} = 'suspicious nameserver';
            $hash{'description'} = 'suspicious nameserver '.$info->{'impact'}.' '.$info->{'address'};

            my ($id,$err) = $self->_insert('CIF::Message::DomainNameserver',{%hash},$rec);
            return(undef,$err) unless($id);
            push(@ids,$id);
        }
    }
    return($ids[0]);
}

sub _insert {
    my ($self,$b,$h,$r) = @_;
    my %hash = %$h;

    $hash{'address'} = $r->{'name'};
    my $rdata = $r->{'address'} || $r->{'cname'} || $r->{'ptrdname'} || $r->{'nsdname'} || $r->{'exchange'};
    my ($as,$network,$ccode,$rir,$date,$as_desc);
    if($rdata && $rdata =~ /^$RE{net}{IPv4}/){
        ($as,$network,$ccode,$rir,$date,$as_desc) = CIF::Message::Infrastructure::asninfo($rdata);
    } else {
        next if(CIF::Message::Domain::isWhitelisted($rdata));
    }
    $hash{'rdata'}  = $rdata;
    $hash{'type'}   = $r->{'type'};
    $hash{'class'}  = $r->{'class'};
    $hash{'ttl'}    = $r->{'ttl'};

    my ($id,$err) = $b->insert({%hash});
    return(undef,$err) unless($id);

    $hash{'severity'} = ($hash{'severity'} eq 'high') ? 'medium' : 'low';
    $hash{'confidence'} = ($hash{'confidence'}) ? ($hash{'confidence'} - 2) : 0;
    $hash{'detecttime'} = DateTime->from_epoch(epoch => time());

    if($rdata && $rdata =~ /^$RE{net}{IPv4}/){
        $hash{'address'} = $hash{'rdata'};
        CIF::Message::InfrastructureSimple->insert({
            relatedid   => $id->uuid(),
            %hash,
        });
    }
    return($id);
}

1;
