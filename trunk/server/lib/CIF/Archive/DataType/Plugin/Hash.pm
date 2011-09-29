package CIF::Archive::DataType::Plugin::Hash;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;

__PACKAGE__->table('hash');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid hash confidence guid source type severity restriction detecttime created data/);
__PACKAGE__->columns(Essential => qw/id uuid hash confidence guid source type severity restriction detecttime created data/);
__PACKAGE__->sequence('hash_id_seq');

my @plugins = __PACKAGE__->plugins();

sub prepare {
    my $class = shift;
    my $info = shift;

    foreach my $p (@plugins){
        return(1) if($p->prepare($info));
    }
    return(undef);
}

sub insert {
    my $class = shift;
    my $info = shift;
    
    my $t = $class->table();
    foreach(@plugins){
        if($_->prepare($info)){
            $class->table($_->table());
        
        my $id = eval { $class->SUPER::insert({
            uuid        => $info->{'uuid'},
            hash        => $info->{'hash'},
            source      => $info->{'source'},
            confidence  => $info->{'confidence'},
            severity    => $info->{'severity'} || 'null',
            restriction => $info->{'restriction'} || 'private',
            detecttime  => $info->{'detecttime'},
            guid        => $info->{'guid'},
        }) };
    
        if($@){
                return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
            }
        }
    }
    $class->table($t);
}

sub feed {
    my $class = shift;
    my $info = shift;

    my @feeds;
    $info->{'key'} = 'hash';
    my $ret = $class->_feed($info);
    return unless($ret);
    push(@feeds,$ret) if($ret);

    foreach(@plugins){
        my $r = $_->_feed($info);
        push(@feeds,$r) if($r);
    }
    return(\@feeds);
}

sub lookup {
    my $class = shift;
    my $info = shift;
    my $q = $info->{'query'};
    foreach(@plugins){
        if(my $r = $_->lookup($q)){
            if($info->{'guid'}){
                return(
                    $class->search__lookup(
                        $q,
                        $info->{'severity'},
                        $info->{'confidence'},
                        $info->{'restriction'},
                        $info->{'guid'},
                        $info->{'limit'},
                    )
                );
            }
            return(
                $class->search_lookup(
                    $q,
                    $info->{'severity'},
                    $info->{'confidence'},
                    $info->{'restriction'},
                    $info->{'apikey'},
                    $info->{'limit'},
                )
            );
        }
    }
    return(undef);
}

__PACKAGE__->set_sql('_lookup' => qq{
    SELECT __TABLE__.id,__TABLE__.uuid, archive.data 
    FROM __TABLE__
    LEFT JOIN archive ON archive.uuid = __TABLE__.uuid
    WHERE 
        lower(address) = lower(?)
        AND severity >= ?
        AND confidence >= ?
        AND __TABLE__.restriction <= ?
        AND __TABLE__.guid = ?
    ORDER BY __TABLE__.detecttime DESC, __TABLE__.created DESC, __TABLE__.id DESC
    LIMIT ?
});

__PACKAGE__->set_sql('lookup' => qq{
    SELECT __TABLE__.id,__TABLE__.uuid, archive.data
    FROM __TABLE__
    LEFT JOIN archive ON archive.uuid = __TABLE__.uuid
    LEFT JOIN apikeys_groups on __TABLE__.guid = apikeys_groups.guid
    WHERE 
        lower(hash) = lower(?)
        AND severity >= ?
        AND confidence >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
    ORDER BY __TABLE__.detecttime DESC, __TABLE__.created DESC, __TABLE__.id DESC
    LIMIT ?
});

__PACKAGE__->set_sql('feed' => qq{
    SELECT DISTINCT on (__TABLE__.hash) __TABLE__.hash, confidence, archive.uuid, archive.data
    FROM __TABLE__
    LEFT JOIN apikeys_groups ON __TABLE__.guid = apikeys_groups.guid
    LEFT JOIN archive ON __TABLE__.uuid = archive.uuid
    WHERE
        detecttime >= ?
        AND __TABLE__.confidence >= ?
        AND severity >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
    ORDER BY __TABLE__.hash ASC, __TABLE__.id ASC, confidence DESC, severity DESC, __TABLE__.restriction ASC
    LIMIT ?
});

1;
__END__

=head1 NAME

 CIF::Archive::DataType::Plugin::Hash - CIF::Archive plugin for indexing hashes

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
