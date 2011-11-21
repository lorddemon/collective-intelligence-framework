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
__PACKAGE__->columns(All => qw/id uuid address md5 sha1 type confidence source guid severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid address md5 sha1 type confidence source guid severity restriction detecttime created/);
__PACKAGE__->sequence('domain_id_seq');

my @plugins = __PACKAGE__->plugins();

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'address'});
    $info->{'address'} = lc($info->{'address'});
    
    my $address = $info->{'address'};
    return unless(isDomain($address));
    return(1);
}

sub isDomain {
    my $d = shift || return;
    $d = lc($d);
    return unless($d =~ /^[a-z0-9.\-_]+\.[a-z]{2,6}$/);
    return(1);
}

sub insert {
    my $self = shift;
    my $info = shift;

    my $t = $self->table();
    foreach(@plugins){
        if($_->prepare($info)){
            $self->table($_->table());
        }
    }
    my $uuid    = $info->{'uuid'};
    my $addr = $info->{'address'};
    my @a1 = reverse(split(/\./,$addr));
    my @a2 = @a1;
    my $id;

    foreach (0 ... $#a1-1){
        my $addr = join('.',reverse(@a2));
        pop(@a2);
        my $md5 = md5_hex($addr);
        my $sha1 = sha1_hex($addr);

        $id = eval { 
            $self->SUPER::insert({
                uuid        => $uuid,
                address     => $addr,
                type        => $info->{'type'} || 'A',
                md5         => $md5,
                sha1        => $sha1,
                source      => $info->{'source'},
                confidence  => $info->{'confidence'},
                severity    => $info->{'severity'} || 'null',
                restriction => $info->{'restriction'} || 'private',
                detecttime  => $info->{'detecttime'},
                guid        => $info->{'guid'},
            }); 
        };
        if($@){
            return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
        }
    }
    $self->table($t);
    return $id;
}

sub lookup {
    my $self = shift;
    my $info = shift;
    my $address = $info->{'query'};

    return unless(isDomain($address));
    $address = md5_hex($address);
    my $sev = $info->{'severity'};
    my $conf = $info->{'confidence'};
    my $restriction = $info->{'restriction'};

    if($info->{'guid'}){
        return($self->search__lookup(
            $address,
            $sev,
            $conf,
            $restriction,
            $info->{'guid'},
            $info->{'limit'}
        ));
    }
    return(
        $self->search_lookup(
            $address,
            $sev,
            $conf,
            $restriction,
            $info->{'apikey'},
            $info->{'limit'}
        )
    );
}

## TODO -- fix this to work with feed
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
    my $sql .= join(' OR md5 = ',@hashes);
    $sql =~ s/^/md5 = /;

    $sql .= qq{\nORDER BY detecttime DESC, created DESC, id DESC};
    my $t = $self->table();
    $self->table('domain_whitelist');
    my @recs = $self->retrieve_from_sql($sql);
    $self->table($t);
    return @recs;
}

sub myfeed {
    my $class = shift;
    my $info = shift;

    my @recs;
    if($info->{'apikey'}){
        @recs = $class->search_feed(
            $info->{'detecttime'},
            $info->{'confidence'},
            $info->{'severity'},
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

    my @feeds;
    my $ret = $class->myfeed($info);
    return unless($ret);
    push(@feeds,$ret) if($ret);

    foreach($class->plugins()){
        my $r = $_->myfeed($info);
        push(@feeds,$r) if($r);
    }
    return(\@feeds);
}

## TODO -- fix this 
__PACKAGE__->set_sql('feed' => qq{
    SELECT DISTINCT on (__TABLE__.uuid) __TABLE__.uuid, address, confidence, archive.data
    FROM __TABLE__
    LEFT JOIN apikeys_groups ON __TABLE__.guid = apikeys_groups.guid
    LEFT JOIN archive ON __TABLE__.uuid = archive.uuid
    WHERE
        detecttime >= ?
        AND __TABLE__.confidence >= ?
        AND __TABLE__.severity >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
        AND NOT EXISTS (
            SELECT dw.address FROM domain_whitelist dw
            WHERE
                    dw.detecttime >= ?
                    AND dw.confidence >= 25
                    AND dw.md5 = __TABLE__.md5
                    AND dw.severity IS NULL
        )
    ORDER BY __TABLE__.uuid ASC, __TABLE__.id ASC, confidence DESC, severity DESC, __TABLE__.restriction ASC, detecttime DESC, __TABLE__.id DESC
    LIMIT ?
});

## TODO -- maybe change this to an md5 lookup?
## the only con is that we'd lose fuzzy searches
## eg: yahoo.com would result with example.yahoo.com results

__PACKAGE__->set_sql('lookup' => qq{
    SELECT __TABLE__.id,__TABLE__.uuid, archive.data 
    FROM __TABLE__
    LEFT JOIN apikeys_groups ON __TABLE__.guid = apikeys_groups.guid
    LEFT JOIN archive ON archive.uuid = __TABLE__.uuid
    WHERE 
        md5 = ?
        AND severity >= ?
        AND confidence >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
    ORDER BY __TABLE__.detecttime DESC, __TABLE__.created DESC, __TABLE__.id DESC
    LIMIT ?
});

__PACKAGE__->set_sql('_lookup' => qq{
    SELECT __TABLE__.id,__TABLE__.uuid, archive.data 
    FROM __TABLE__
    LEFT JOIN archive ON archive.uuid = __TABLE__.uuid
    WHERE 
        md5 = ?
        AND severity >= ?
        AND confidence >= ?
        AND __TABLE__.restriction <= ?
        AND __TABLE__.guid = ?
    ORDER BY __TABLE__.detecttime DESC, __TABLE__.created DESC, __TABLE__.id DESC
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
