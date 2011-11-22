package CIF::Archive::DataType::Plugin::Feed;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;

__PACKAGE__->table('feed');
__PACKAGE__->columns(All => qw/id uuid guid description confidence source hash_sha1 signature impact severity restriction detecttime created data/);
__PACKAGE__->columns(Essential => qw/id uuid guid description confidence source hash_sha1 signature impact severity restriction detecttime created data/);
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->sequence('feed_id_seq');

my @plugins = __PACKAGE__->plugins();

sub prepare {
    my $class = shift;
    my $info = shift;
    return unless($info->{'impact'});
    return unless($info->{'impact'} =~ /feed/ || $info->{'description'} =~ /^search\s[\S\s]+\sfeed$/);
    return(1);
}

sub insert {
    my $self = shift;
    my $info = shift;

    my $tbl = $self->table();
    foreach(@plugins){
        if($_->prepare($info)){
            $self->table($_->table());
        }
    }

    my $uuid = $info->{'uuid'};

    my $id = eval {
        $self->SUPER::insert({
            uuid        => $info->{'uuid'},
            guid        => $info->{'guid'},
            impact      => $info->{'impact'},
            description => $info->{'description'},
            severity    => $info->{'severity'},
            confidence  => $info->{'confidence'},
            restriction => $info->{'restriction'} || 'private',
            detecttime  => $info->{'detecttime'},
            data        => $info->{'data'},
            source      => $info->{'source'},
        });
    };
    if($@){
        return(undef,$@) unless($@ =~ /unique/);
    }
    $self->table($tbl);
    return($id);
}

__PACKAGE__->set_sql('lookup' => qq{
    SELECT __TABLE__.id, __TABLE__.uuid, data
    FROM __TABLE__
    LEFT JOIN apikeys_groups on __TABLE__.guid = apikeys_groups.guid
    WHERE
        impact = ?
        AND severity = ?
        AND confidence >= ?
        AND feed.restriction <= ?
        AND apikeys_groups.uuid = ?
    ORDER BY confidence ASC, feed.restriction DESC, default_guid ASC, feed.id DESC
    LIMIT 1
});

__PACKAGE__->set_sql('_lookup' => qq{
    SELECT __TABLE__.id,__TABLE__.uuid, feed.restriction, data
    FROM __TABLE__
    WHERE 
        impact = ?
        AND severity = ?
        AND confidence >= ?
        AND restriction <= ?
        AND guid = ?
    ORDER BY confidence ASC, restriction DESC, id DESC
    LIMIT 1
});

sub lookup {
    my $class = shift;
    my $info = shift;
    my $q = $info->{'query'};

    if($info->{'guid'}){
        return(
            $class->search__lookup(
                $info->{'query'},
                $info->{'severity'},
                $info->{'confidence'},
                $info->{'restriction'},
                $info->{'guid'},
            )
        );
    }
    return(
        $class->search_lookup(
            $info->{'query'},
            $info->{'severity'},
            $info->{'confidence'},
            $info->{'restriction'},
            $info->{'apikey'},
   ));
}

1;
__END__

=head1 NAME

 CIF::Archive::DataType::Plugin::Feed - CIF::Archive plugin for indexing feed's

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
