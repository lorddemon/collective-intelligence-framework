package CIF::Archive::DataType::Plugin::Infrastructure;
use base 'CIF::Archive::DataType';

use warnings;
use strict;

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;

use Net::CIDR;
use Net::Abuse::Utils qw(:all);
use Regexp::Common qw/net URI/;
use Regexp::Common::net::CIDR ();
use DateTime;

__PACKAGE__->table('infrastructure');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid address portlist protocol confidence source guid severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/uuid address portlist protocol confidence source severity restriction detecttime created/);
__PACKAGE__->sequence('infrastructure_id_seq');

my @plugins = __PACKAGE__->plugins();


## TODO -- Net::Patricia
## TODO -- IPv6
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

    my $address = $info->{'rdata'} || $info->{'address'};
    return unless($address);

    # protect against hostnames with addresses in them
    return if($address =~ /^[a-zA-Z0-9.-]+\.[a-z]{2,6}$/);

    # be sure to guard against things like 1.1.1.1/exe.exe
    # when we move to ipv6, be sure to for() this and anchor them down
    # the DataType::Plugin::Url can confuse it if you don't
    return(undef) unless($address =~ /^$RE{'net'}{'IPv4'}$/ || $address =~ /^$RE{'net'}{'CIDR'}{'IPv4'}$/);
    # moving this to the feeds section.
    #return(0,'invalid address: private address space -- '.$address) if(isPrivateAddress($address));
    #return(0,'invalid address: whitelisted -- '.$address) if(isWhitelisted($address));
    unless($info->{'asn'} || $info->{'prefix'}){
        my ($as,$network,$ccode,$rir,$date,$as_desc) = asninfo($address);
        $info->{'asn'}  = $as;
        $info->{'prefix'} = $network;
        $info->{'cc'}   = $ccode;
        $info->{'rir'}  = $rir;
        $info->{'asn_desc'} = $as_desc;
    }
    return(1);
}

sub isPrivateAddress {
    my $addr = shift;
    return(undef) unless($addr && $addr =~ /^$RE{'net'}{'IPv4'}/);
    return if($addr =~ /^$RE{'URI'}/);

    ## Net::Patricia this
    ## store the list in the database?
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

sub myfeed {
    my $class = shift;
    my $info = shift;

    my @recs;
    if($info->{'apikey'}){
        @recs = $class->search_feed(
            $info->{'detecttime'},
            $info->{'severity'},
            $info->{'confidence'},
            $info->{'restriction'},
            $info->{'apikey'},
            $info->{'detecttime'},
            $info->{'limit'},
        );
    } else {
        @recs = $class->search__feed(
            $info->{'detecttime'},
            $info->{'detecttime'},
            $info->{'confidence'},
            $info->{'severity'},
            $info->{'restriction'},
            $info->{'guid'},
            $info->{'limit'},
        );
    }
    return unless(@recs);
    return $class->mapfeed(\@recs);
}

sub feed {
    my $class = shift;
    my $info = shift;

    my @snapshots;
    my $ret = $class->myfeed($info);
    return unless($ret);
    push(@snapshots,$ret);

    foreach(@plugins){
        my $r = $_->myfeed($info);
        push(@snapshots,$r) if($r);
    }
    return(\@snapshots);
}

sub insert {
    my $self = shift;
    my $info = shift;

    ## TODO -- clean this up
    ## this will auto-index rdata from a domain insert
    my $address = $info->{'rdata'} || $info->{'address'};
    
    my $tbl = $self->table();
    foreach(@plugins){
        if($_->prepare($info)){
            $self->table($_->table());
        }
    }

    my $uuid = $info->{'uuid'};

    my $id = eval {
        $self->SUPER::insert({
            uuid        => $uuid,
            address     => $address,
            portlist    => $info->{'portlist'},
            protocol    => $info->{'protocol'},
            confidence  => $info->{'confidence'},
            source      => $info->{'source'},
            guid        => $info->{'guid'},
            severity    => $info->{'severity'} || 'null',
            restriction => $info->{'restriction'} || 'private',
            detecttime  => $info->{'detecttime'},
            created     => $info->{'created'},
        });
    };
    if($@){
        return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
    }
    $self->table($tbl);
}

sub lookup {
    my $class = shift;
    my $info = shift;
    my $q = $info->{'query'};
    return(undef) unless($q && $q =~ /^$RE{'net'}{'IPv4'}/);
    return if($q =~ /^[a-zA-Z0-9.-]+\.[a-z]{2,6}$/);
    my $sev = $info->{'severity'};
    my $conf = $info->{'confidence'};
    my $restriction = $info->{'restriction'};
    if($info->{'guid'}){
        return($class->search__lookup(
            $q,
            $sev,
            $conf,
            $restriction,
            $info->{'guid'},
            $info->{'limit'},
        ));
    }
    return(
        $class->search_lookup(
            $q,
            $sev,
            $conf,
            $restriction,
            $info->{'apikey'},
            $info->{'limit'},
        )
    );
}

## TODO -- re-write this as a "good" SQL stmt
## newb.
sub isWhitelisted {
    my $class = shift;
    my $a = shift;
    my $apikey = shift;
    return;

    return (undef) unless($a);
    return (0,'is private address') if(isPrivateAddress($a));

    my @ret = $class->search_isWhitelisted(
        $a,
        25,
        $apikey,
    );
    return @ret;
}

__PACKAGE__->set_sql('isWhitelisted' => qq{
    SELECT iw.id, iw.uuid, archive.data
    FROM infrastructure_whitelist iw
    LEFT JOIN apikeys_groups on iw.guid = apikeys_groups.guid
    LEFT JOIN archive ON iw.uuid = archive.uuid
    WHERE
        family(address) = 4
        AND masklen(address) <= 32
        AND ? <<= address
        AND confidence >= ?
        AND apikeys_groups.uuid = ?
    ORDER BY confidence DESC, iw.id DESC
    LIMIT 5
});

__PACKAGE__->set_sql('lookup_byseverity' => qq{
    SELECT __TABLE__.id,__TABLE__.uuid, archive.data
    FROM __TABLE__
    LEFT JOIN apikeys_groups on __TABLE__.guid = apikeys_groups.guid
    LEFT JOIN archive ON __TABLE__.uuid = archive.uuid
    WHERE 
        address != '0/0'
        AND (address >>= ? OR address <<= ?)
        AND severity >= ?
        AND confidence >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
    ORDER BY severity DESC, confidence DESC, detecttime DESC, __TABLE__.id DESC
    LIMIT ?
});
__PACKAGE__->set_sql('lookup' => qq{
    SELECT t.id, t.uuid, archive.data
    FROM __TABLE__ t
    LEFT JOIN apikeys_groups on t.guid = apikeys_groups.guid
    LEFT JOIN archive ON t.uuid = archive.uuid
    WHERE 
        address >>= ?
        AND severity >= ?
        AND confidence >= ?
        AND t.restriction <= ?
        AND apikeys_groups.uuid = ?
    ORDER BY t.detecttime DESC, t.created DESC, t.id DESC
    LIMIT ?
});

__PACKAGE__->set_sql('_lookup' => qq{
    SELECT __TABLE__.id,__TABLE__.uuid, archive.data
    FROM __TABLE__
    LEFT JOIN archive ON archive.uuid = __TABLE__.uuid
    WHERE 
        address <<= ?
        AND severity >= ?
        AND confidence >= ?
        AND __TABLE__.restriction <= ?
        AND __TABLE__.guid = ?
    ORDER BY __TABLE__.detecttime DESC, __TABLE__.created DESC, __TABLE__.id DESC
    LIMIT ?
});

__PACKAGE__->set_sql('feed' => qq{
    SELECT DISTINCT ON (address,protocol,portlist) address, portlist, protocol, confidence, __TABLE__.restriction, archive.uuid, archive.data
    FROM __TABLE__
    LEFT JOIN apikeys_groups ON __TABLE__.guid = apikeys_groups.guid
    LEFT JOIN archive ON __TABLE__.uuid = archive.uuid
    WHERE 
        detecttime >= ?
        AND __TABLE__.severity >= ?
        AND __TABLE__.confidence >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
        AND NOT EXISTS (SELECT uuid FROM domain where __TABLE__.uuid = domain.uuid)
        AND NOT EXISTS (
            SELECT iw.address FROM infrastructure_whitelist iw 
            WHERE 
                __TABLE__.address <<= iw.address
                AND iw.detecttime >= ?
                AND iw.confidence >= 25 
                AND severity IS NULL
        ) 
    ORDER BY address,protocol,portlist ASC, confidence DESC, severity DESC, restriction ASC, detecttime DESC, __TABLE__.id DESC 
    LIMIT ?
});

1;
__END__

=head1 NAME

 CIF::Archive::DataType::Plugin::Infrastructure - CIF::Archive plugin for indexing infrastructure (ip based)

=head1 SEE ALSO

 http://code.google.com/p/collective-intelligence-framework/
 CIF::Archive

=head1 AUTHOR

 Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

 Copyright (C) 2011 by Wes Young (claimid.com/wesyoung)
 Copyright (C) 2011 by the Trustee's of Indiana University (www.iu.edu)
 Copyright (C) 2011 by the REN-ISAC (www.ren-isac.net)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
