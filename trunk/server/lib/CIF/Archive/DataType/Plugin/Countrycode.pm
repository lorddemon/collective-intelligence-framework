package CIF::Archive::DataType::Plugin::Countrycode;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];

__PACKAGE__->table('countrycode');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid cc source guid severity confidence restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid cc source guid severity confidence restriction detecttime created/);
__PACKAGE__->sequence('countrycode_id_seq');

sub prepare {
    my $class = shift;
    my $info = shift;

    ## TODO -- download list of IANA country codes for use in regex
    ## http://data.iana.org/TLD/tlds-alpha-by-domain.txt
    return unless($info->{'cc'});
    return unless($info->{'cc'} =~ /^[a-zA-Z]{2,2}$/);
    return(1);
}

sub insert {
    my $class = shift;
    my $info = shift;

    return unless($info->{'cc'});

    # you could create different buckets for different country codes
    my $tbl = $class->table();
    foreach($class->plugins()){
        if(my $t = $_->prepare($info)){
            $class->table($tbl.'_'.$t);
        }
    }

    my $id = eval { $class->SUPER::insert({
        uuid        => $info->{'uuid'},
        cc          => $info->{'cc'},
        source      => $info->{'source'},
        severity    => $info->{'severity'} || 'null',
        confidence  => $info->{'confidence'},
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

sub feed {
    my $class = shift;
    my $info = shift;
    my @feeds;

    ## TODO -- same as rir ans asn
    $info->{'key'} = 'cc';
    my $ret = $class->_feed($info);
    push(@feeds,$ret) if($ret);

    foreach($class->plugins()){
        my $r = $_->_feed($info);
        push(@feeds,$r) if($r);
    }
    return(\@feeds);
}

sub lookup {
    my $class = shift;
    my $info = shift;
    my $query = ($info->{'query'});
    return unless($query =~ /^[a-z]{2,2}$/);

    if($info->{'guid'}){
        return(
            $class->search__lookup(
                $query,
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
            $query,
            $info->{'severity'},
            $info->{'confidence'},
            $info->{'restriction'},
            $info->{'apikey'},
            $info->{'limit'},
        )
    );
}

__PACKAGE__->set_sql('feed' => qq{
    SELECT count(cc),cc
    FROM __TABLE__
    LEFT JOIN apikeys_groups ON __TABLE__.guid = apikeys_groups.guid
    LEFT JOIN archive ON __TABLE__.uuid = archive.uuid
    WHERE
        detecttime >= ?
        AND __TABLE__.confidence >= ?
        AND severity >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
    GROUP BY cc
    ORDER BY count DESC
    LIMIT ?
});

__PACKAGE__->set_sql('_lookup' => qq{
    SELECT __TABLE__.id,__TABLE__.uuid
    FROM __TABLE__
    LEFT JOIN apikeys_groups ON __TABLE__.guid = apikeys_groups.guid
    WHERE upper(cc) = upper(?)
    AND severity >= ?
    AND confidence >= ?
    AND restriction <= ?
    AND apikeys_groups.uuid = ?
    ORDER BY __TABLE__.detecttime DESC, __TABLE__.created DESC, __TABLE__.id DESC
    LIMIT ?
});

__PACKAGE__->set_sql('lookup' => qq{
    SELECT __ESSENTIAL__
    FROM __TABLE__
    WHERE upper(cc) = upper(?)
    AND severity >= ?
    AND confidence >= ?
    AND restriction <= ?
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::Archive::DataType::Plugin::Countrycode - CIF::Archive plugin for indexing country codes

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
