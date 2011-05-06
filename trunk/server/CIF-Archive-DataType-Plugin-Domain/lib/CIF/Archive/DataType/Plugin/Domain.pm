package CIF::Archive::DataType::Plugin::Domain;
use base 'CIF::Archive::DataType';

require 5.008;
use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;
use Net::Abuse::Utils qw(:all);
use Digest::MD5 qw/md5_hex/;
use Digest::SHA1 qw/sha1_hex/;

__PACKAGE__->table('domain');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description address md5 sha1 type rdata cidr asn asn_desc cc rir class ttl impact confidence source alternativeid alternativeid_restriction severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid description address md5 sha1 rdata impact restriction created/);
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
    $info->{'md5'} = md5_hex($address);
    $info->{'sha1'} = sha1_hex($address);

    return(0,'invalid address: whitelisted -- '.$address) if($class->isWhitelisted($address));
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
        md5         => $info->{'md5'},
        sha1        => $info->{'sha1'},
        type        => $info->{'type'} || 'A',
        rdata       => $info->{'rdata'} || 'unknown', ## in sql @NULL != NULL@, so to avoid dup's with no rdata, we have to fill it in
                                                      ## http://www.pgrs.net/2008/1/11/postgresql-allows-duplicate-nulls-in-unique-columns
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
    my $addr = shift;

    my @bits = reverse(split(/\./,$addr));
    my $tld = $bits[0];
    my @array;
    push(@array,$tld);
    my @hashes;
    foreach(1 ... $#bits){
        push(@array,$bits[$_]);
        my $d = join('.',reverse(@array));
        $d = md5_hex($d);
        $d = "'".$d."'";
        push(@hashes,$d);
    }
    my $sql .= join('OR md5 = ',@hashes);
    $sql =~ s/^/md5 = /;

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
    AND type = 'A'
    AND severity >= ?
    AND restriction <= ?
    AND NOT (lower(impact) = 'domain whitelist' OR lower(impact) LIKE '% whitelist %')
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
