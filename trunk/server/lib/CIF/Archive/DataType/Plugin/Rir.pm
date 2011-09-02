package CIF::Archive::DataType::Plugin::Rir;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];

__PACKAGE__->table('rir');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid rir guid source confidence severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid rir guid source confidence severity restriction detecttime created/);
__PACKAGE__->sequence('asn_id_seq');

# Preloaded methods go here.

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'rir'});
    return unless($class->isrir($info->{'rir'}));
    return(1);
}

sub insert {
    my $class = shift;
    my $info = shift;

    my $tbl = $class->table();
    foreach($class->plugins()){
        if(my $t = $_->prepare($info)){
            $class->table($tbl.'_'.$t);
        }
    }

    my $id = eval { $class->SUPER::insert({
        uuid        => $info->{'uuid'},
        rir         => $info->{'rir'},
        source      => $info->{'source'},
        confidence  => $info->{'confidence'},
        severity    => $info->{'severity'},
        restriction => $info->{'restriction'} || 'private',
        detecttime  => $info->{'detecttime'},
        guid        => $info->{'guid'},
    }) };
    if($@){
        return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
        $id = CIF::Archive->retrieve(uuid => $info->{'uuid'});
    }
    $class->table($tbl);
    return($id);
}

sub lookup {
    my $class = shift;
    my $info = shift;
    my $q = $info->{'query'};
    return unless($class->isrir($q));
    if($info->{'guid'}){
        return(
            $class->search_lookup(
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
        $class->SUPER::lookup(
            $q,
            $info->{'severity'},
            $info->{'confidence'},
            $info->{'restriction'},
            $info->{'apikey'},
            $info->{'limit'},
        )
    );
}

sub isrir {
    my $class = shift;
    my $rir = shift;
    return unless($rir =~ /^(apnic|arin|ripencc|lacnic|afrinic)$/);
    return(1);
}

sub feed {
    my $class = shift;
    my $info = shift;
    my @feeds;
    # this doesn't work quite yet.
    # gets stuck in a recursive loop for some reason on count()

    $info->{'key'} = 'rir';
    my $ret = $class->_feed($info);
    return unless($ret);
    push(@feeds,$ret) if($ret);

    foreach($class->plugins()){
        my $r = $_->_feed($info);
        push(@feeds,$r) if($r);
    }
    return(\@feeds);
}

__PACKAGE__->set_sql('feed' => qq{
    SELECT count(rir),rir
    FROM __TABLE__
    LEFT JOIN apikeys_groups ON __TABLE__.guid = apikeys_groups.guid
    LEFT JOIN archive ON __TABLE__.uuid = archive.uuid
    WHERE
        detecttime >= ?
        AND __TABLE__.confidence >= ?
        AND severity >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
    GROUP BY rir
    ORDER BY count DESC
    LIMIT ?
});

# convert this to use the hashes as lookup
__PACKAGE__->set_sql('_lookup' => qq{
    SELECT __TABLE__.id,__TABLE__.uuid, archive.data 
    FROM __TABLE__
    LEFT JOIN archive ON archive.uuid = __TABLE__.uuid
    WHERE 
        lower(rir) = lower(?)
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
    LEFT JOIN apikeys_groups ON __TABLE__.guid = apikeys_groups.guid
    LEFT JOIN archive ON archive.uuid = __TABLE__.uuid
    WHERE 
        lower(rir) = lower(?)
        AND severity >= ?
        AND confidence >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
    ORDER BY __TABLE__.detecttime DESC, __TABLE__.created DESC, __TABLE__.id DESC
    LIMIT ?
});

1;
__END__
=head1 NAME

 CIF::Archive::DataType::Plugin::RIR - Perl extension for indexing RIR's

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
