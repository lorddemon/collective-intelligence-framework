package CIF::Archive::DataType::Plugin::Email;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;
use Regexp::Common qw/URI/;

__PACKAGE__->table('email');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(Essential => qw/id uuid address guid source confidence severity restriction detecttime created/);
__PACKAGE__->columns(All => qw/id uuid address guid source confidence severity restriction detecttime created/);
__PACKAGE__->sequence('email_id_seq');

my @plugins = __PACKAGE__->plugins();

sub isEmail {
    my $e = shift;
    return unless($e);
    return if($e =~ /^$RE{'URI'}/ || $e =~ /^$RE{'URI'}{'HTTP'}{-scheme => 'https'}$/);
    return unless(lc($e) =~ /^[a-z0-9_.-]+\@[a-z0-9.-]+\.[a-z0-9.-]{2,5}$/);
    return(1);
}

sub prepare {
    my $class = shift;
    my $info = shift;
   
    return unless(isEmail($info->{'address'}));
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
    
    my $id = eval { $self->SUPER::insert({
        uuid            => $info->{'uuid'},
        address         => $info->{'address'},
        source          => $info->{'source'},
        confidence      => $info->{'confidence'},
        severity        => $info->{'severity'} || 'null',
        restriction     => $info->{'restriction'} || 'private',
        detecttime      => $info->{'detecttime'},
        guid            => $info->{'guid'},
        created         => $info->{'created'},
    }) };
    if($@){
        return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
    }
    $self->table($t);
}

sub feed {
    my $class = shift;
    my $info = shift;

    my @feeds;
    $info->{'key'} = 'address';
    my $ret = $class->SUPER::_feed($info);
    return unless($ret);
    push(@feeds,$ret) if($ret);

    foreach(@plugins){
        my $r = $_->SUPER::_feed($info);
        push(@feeds,$r) if($r);
    }
    return(\@feeds);
}

sub lookup {
    my $self = shift;
    my $info = shift;
    my $address = $info->{'query'};
    return unless(isEmail($address));

    if($info->{'guid'}){
        return(
            $self->search__lookup(
                $address,
                $info->{'severity'},
                $info->{'confidence'},
                $info->{'restriction'},
                $info->{'guid'},
                $info->{'limit'},
            )
        );
    }
    return(
        $self->search_lookup(
            $address,
            $info->{'severity'},
            $info->{'confidence'},
            $info->{'restriction'},
            $info->{'apikey'},
            $info->{'limit'},
        )
    );
}

# this should all be sha1 or uuid or something.
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
    LEFT JOIN apikeys_groups ON __TABLE__.guid = apikeys_groups.guid
    LEFT JOIN archive ON archive.uuid = __TABLE__.uuid
    WHERE 
        lower(address) = lower(?)
        AND severity >= ?
        AND confidence >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
    ORDER BY __TABLE__.detecttime DESC, __TABLE__.created DESC, __TABLE__.id DESC
    LIMIT ?
});

__PACKAGE__->set_sql('feed' => qq{
    SELECT DISTINCT on (__TABLE__.address) __TABLE__.address, confidence, __TABLE__.uuid, archive.data
    FROM __TABLE__
    LEFT JOIN apikeys_groups ON __TABLE__.guid = apikeys_groups.guid
    LEFT JOIN archive ON __TABLE__.uuid = archive.uuid
    WHERE
        detecttime >= ?
        AND __TABLE__.confidence >= ?
        AND severity >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
    ORDER BY __TABLE__.address ASC, __TABLE__.id ASC, confidence DESC, severity DESC, __TABLE__.restriction ASC
    LIMIT ?
});

1;
__END__

=head1 NAME

 CIF::Archive::DataType::Plugin::Email - CIF::Archive plugin for indexing internet messages

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
