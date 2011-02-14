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

    unless($info->{'severity'} && $info->{'severity'} eq 'high'){
        return (undef,'invalid address: '.$info->{'address'}.' -- whitelisted') if($self->isWhitelisted($info->{'address'}));
    }
    my @ids;

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

    my @results = CIF::Message::Domain::getrdata($info->{'nsres'},$info->{'address'});
    foreach my $r (@results){
        my %hash = %$info;
        if($r->{'type'} ne 'A'){
            $hash{'detecttime'} = DateTime->from_epoch(epoch => time());
        }
        my ($id,$err) = $self->_insert($bucket,{%hash},$r);
        if($r->{'type'} eq 'A'){
            return(undef,$err) unless($id);
            push(@ids,$id);
        } else {
            next unless($id);
        }
    }

    # do the same for the nameservers
    $info->{'severity'} = ($info->{'severity'} && $info->{'severity'} eq 'high') ? 'medium' : 'low';
    $info->{'confidence'} = ($info->{'confidence'}) ? ($info->{'confidence'} - 2) : 0;
    my @ns = grep { $_->{'type'} eq 'NS' } @results;
    unless(@ns){
        my @bits = split(/\./,$info->{'address'});
        if($#bits > 1 && $bits[$#bits] =~ /net|com|edu|gov|ru|cn|org|info|biz/){
            my $y = '';
            foreach ( 1 ... $#bits){
                $y .= $bits[$_].".";
            }
            $y =~ s/\.$//;
            @ns = CIF::Message::Domain::getrdata($info->{'nsres'},$y);
            @ns = grep { $_->{'type'} eq 'NS' } @ns;
            push(@results,@ns);
        }
    }
    foreach my $r (grep { $_->{'type'} eq 'NS' } @results){
        my @recs = CIF::Message::Domain::getrdata($info->{'nsres'},$r->{'nsdname'});
        foreach my $rec (grep { $_->{'type'} && $_->{'type'} eq 'A' } @recs){
            my %hash = %$info;
            $hash{'impact'} = 'suspicious nameserver';
            $hash{'relatedid'} = $ids[0]->uuid();
            $hash{'description'} = $description;
            $hash{'detecttime'} = DateTime->from_epoch(epoch => time());

            my ($id,$err) = $self->_insert('CIF::Message::DomainNameserver',{%hash},$rec);
            push(@ids,$id) if($id);
        }
    }
    return($ids[0]);
}

sub _insert {
    my ($self,$b,$h,$r) = @_;
    my %hash = %$h;

    #$hash{'impact'} .= ' '.$hash{'address'};
    $hash{'address'} = $r->{'name'};
    my $rdata = $r->{'address'} || $r->{'cname'} || $r->{'ptrdname'} || $r->{'nsdname'} || $r->{'exchange'};
    if($rdata && $rdata =~ /^$RE{net}{IPv4}$/){
        ($hash{'asn'},$hash{'cidr'},$hash{'cc'},$hash{'rir'},$hash{'date'},$hash{'as_desc'}) = CIF::Message::Infrastructure::asninfo($rdata);
    } else {
        return(undef,'invalid address: '.$rdata.' -- whitelisted') if($self->isWhitelisted($rdata));
    }
    return(undef,'invalid address: '.$hash{'address'}.' -- whitelisted') if($self->isWhitelisted($hash{'address'}));
    $hash{'rdata'}  = $rdata;
    $hash{'type'}   = $r->{'type'};
    $hash{'class'}  = $r->{'class'};
    $hash{'ttl'}    = $r->{'ttl'};

    my ($id,$err) = $b->insert({%hash});
    return(undef,$err) unless($id);
    return($id) unless($rdata && $rdata =~ /^$RE{'net'}{'IPv4'}$/);

    $hash{'severity'} = ($hash{'severity'} && $hash{'severity'} eq 'high') ? 'medium' : 'low';
    $hash{'confidence'} = ($hash{'confidence'}) ? ($hash{'confidence'} - 2) : 0;
    $hash{'detecttime'} = DateTime->from_epoch(epoch => time());
    $hash{'impact'} =~ s/domain/infrastructure/;
    $hash{'description'} =~ s/domain/infrastructure/;

    $hash{'address'} = $hash{'rdata'};
    CIF::Message::InfrastructureSimple->insert({
        relatedid   => $id->uuid(),
        %hash,
    });
    return($id);
}

1;
