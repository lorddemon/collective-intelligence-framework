package CIF::Archive::DataType::Plugin::Domain;
use base 'CIF::Archive::DataType';

require 5.008;
use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;
use Net::Abuse::Utils qw(:all);

__PACKAGE__->table('domain');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description address type rdata cidr asn asn_desc cc rir class ttl impact confidence source alternativeid alternativeid_restriction severity restriction detecttime created/);
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
        type        => $info->{'type'} || 'A',
        rdata       => $info->{'rdata'},
        cidr        => $info->{'cidr'},
        asn         => $info->{'asn'},
        asn_desc    => $info->{'asn_desc'},
        cc          => $info->{'cc'},
        rir         => $info->{'rir'},
        class       => $info->{'class'} || 'IN',
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
    ## TODO -- use hashing dumbass. LIKE, like really sucks.
    ## TODO -- maybe even had feed parser pull the whitelist and do this in memory.
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

sub feed {
    my $class = shift;
    my $info = shift;

    my @feeds;
    $info->{'key'} = 'address';
    my $ret = $class->SUPER::feed($info);
    push(@feeds,$ret) if($ret);

    my $tbl = $class->table();
    foreach($class->plugins()){
        my $t = $_->set_table();
        my $r = $_->SUPER::feed($info);
        push(@feeds,$r) if($r);
    }
    return(\@feeds);
}

__PACKAGE__->set_sql('feed' => qq{
    SELECT * FROM __TABLE__
    WHERE detecttime > ?
    AND (type IS NULL OR type = 'A')
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
__END__

=head1 NAME

 CIF::Archive::DataType::Plugin::Domain - CIF::Archive plugin for indexing domain data

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
