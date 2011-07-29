package CIF::Archive::DataType::Plugin::Domain;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;
use Net::Abuse::Utils qw(:all);
use Digest::MD5 qw/md5_hex/;
use Digest::SHA1 qw/sha1_hex/;

__PACKAGE__->table('domain');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid address md5 sha1 type confidence source severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid address md5 sha1 type confidence source severity restriction detecttime created/);
__PACKAGE__->sequence('domain_id_seq');

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'address'});
    $info->{'address'} = lc($info->{'address'});
    
    my $address = $info->{'address'};
    return(undef) unless($address =~ /^[a-z0-9.-]+\.[a-zA-Z]{2,5}$/);
    $info->{'md5'} = md5_hex($address);
    $info->{'sha1'} = sha1_hex($address);

    return(1);
}

sub insert {
    my $self = shift;
    my $info = shift;

    my $tbl = $self->table();
    foreach($self->plugins()){
        if(my $t = $_->prepare($info)){
            $self->table($t);
        }
    }

    my $uuid    = $info->{'uuid'};

    my $id = eval { 
        $self->SUPER::insert({
            uuid        => $uuid,
            address     => $info->{'address'},
            type        => $info->{'type'} || 'A',
            md5         => $info->{'md5'},
            sha1        => $info->{'sha1'},
            source      => $info->{'source'},
            confidence  => $info->{'confidence'},
            severity    => $info->{'severity'} || 'null',
            restriction => $info->{'restriction'} || 'private',
            detecttime  => $info->{'detecttime'},
        }); 
    };
    if($@){
        return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
        $id = CIF::Archive->retrieve(uuid => $uuid);
    }

    ## TODO -- turn this into a for-loop to ensure the capture of all sub-domains
    ## eg: test1.test2.yahoo.com -- test2.yahoo.com gets indexed.
    if($info->{'address'} !~ /^[a-z0-9-]+\.[a-z]{2,5}$/){
        $info->{'address'} =~ m/([a-z0-9-]+\.[a-z]{2,5})$/;
        my $addr = $1;
        eval { $self->SUPER::insert({
            uuid    => $uuid,
            address => $addr,
            type    => $info->{'type'} || 'A',
            md5     => md5_hex($addr),
            sha1    => sha1_hex($addr),
            source  => $info->{'source'},
            confidence  => $info->{'confidence'},
            severity    => $info->{'severity'} || 'null',
            restriction => $info->{'restriction'} || 'private',
            detecttime  => $info->{'detecttime'},
        })};
    }
    $self->table($tbl);
    return($id);    
}

sub lookup {
    my $self = shift;
    my $info = shift;
    my $address = $info->{'query'};

    return(undef) unless($address && lc($address) =~ /^[a-z0-9.-]+\.[a-z]{2,5}$/);
    $address = md5_hex($address);
    my $sev = $info->{'severity'};
    my $conf = $info->{'confidence'};
    my $restriction = $info->{'restriction'};

    return($self->SUPER::lookup($address,$sev,$conf,$restriction,$info->{'limit'}));
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

    foreach($class->plugins()){
        my $t = $_->set_table();
        my $r = $_->SUPER::feed($info);
        push(@feeds,$r) if($r);
    }
    return(\@feeds);
}

__PACKAGE__->set_sql('feed' => qq{
    SELECT __ESSENTIAL__ 
    FROM __TABLE__
    WHERE detecttime >= ?
    AND confidence >= ?
    AND severity >= ?
    AND restriction <= ?
    AND type != 'NS'
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

## TODO -- maybe change this to an md5 lookup?
## the only con is that we'd lose fuzzy searches
## eg: yahoo.com would result with example.yahoo.com results

__PACKAGE__->set_sql('lookup' => qq{
    SELECT __ESSENTIAL__ 
    FROM __TABLE__
    WHERE md5 = ?
    AND severity >= ?
    AND confidence >= ?
    AND restriction <= ?
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
