package CIF::Archive::DataType::Plugin::Url;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;
use Digest::SHA1 qw(sha1_hex);
use Digest::MD5 qw(md5_hex);
use Encode qw/encode_utf8/;
use URI::Escape;
use Regexp::Common qw/URI/;

__PACKAGE__->table('url');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid guid source address confidence severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid guid source address confidence severity restriction detecttime created/);
__PACKAGE__->sequence('url_id_seq');

my @plugins = __PACKAGE__->plugins();

## sub lookup {} is via Plugin::Hash
sub lookup { return; }

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless(isUrl($info->{'address'}));
    $info->{'address'} = lc($info->{'address'});
    $info->{'address'} =~ s/\/$//g;
    $info->{'md5'} = md5_hex($info->{'address'}) unless($info->{'md5'});
    $info->{'sha1'} = sha1_hex($info->{'address'}) unless($info->{'sha1'});
    return(1);
}

sub isUrl {
    my $address = shift;
    return unless($address);
    return unless($address =~ /^$RE{'URI'}$/ || $address =~ /^$RE{'URI'}{'HTTP'}{-scheme => 'https'}$/);
    return(1);
}

sub insert {
    my $self = shift;
    my $info = shift;
    
    my $uuid    = $info->{'uuid'};
    my $address = $info->{'address'};

    my $t = $self->table();
    foreach(@plugins){
        if($_->prepare($info)){
            $self->table($_->table());
        }
    }

    my $id = eval { $self->SUPER::insert({
        uuid            => $info->{'uuid'},
        address         => $address,
        source          => $info->{'source'},
        confidence      => $info->{'confidence'},
        severity        => $info->{'severity'} || 'null',
        restriction     => $info->{'restriction'} || 'private',
        detecttime      => $info->{'detecttime'},
        guid            => $info->{'guid'},
    }) };
    if($@){
        return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
    }
    $self->table($t);
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
            $info->{'limit'},
        );
    } else {
        @recs = $class->search__feed(
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
    $info->{'key'} = 'address';
    my $ret = $class->myfeed($info);
    return unless($ret);
    push(@feeds,$ret) if($ret);

    foreach(@plugins){
        my $r = $_->myfeed($info);
        push(@feeds,$r) if($r);
    }
    return(\@feeds);
}

__PACKAGE__->set_sql('feed' => qq{
    SELECT DISTINCT on (__TABLE__.address) __TABLE__.address, confidence, __TABLE__.uuid, archive.data
    FROM __TABLE__
    LEFT JOIN apikeys_groups ON __TABLE__.guid = apikeys_groups.guid
    LEFT JOIN archive ON __TABLE__.uuid = archive.uuid
    WHERE
        detecttime >= ?
        AND __TABLE__.severity >= ?
        AND __TABLE__.confidence >= ?
        AND __TABLE__.restriction <= ?
        AND apikeys_groups.uuid = ?
    ORDER BY __TABLE__.address ASC, __TABLE__.id ASC, confidence DESC, severity DESC, __TABLE__.restriction ASC, detecttime DESC, __TABLE__.id DESC
    LIMIT ?
});

1;
__END__

=head1 NAME

 CIF::Archive::DataType::Plugin::Url - CIF::Archive plugin for indexing urls

=head1 SEE ALSO

 http://code.google.com/p/collective-intelligence-framework/
 CIF::Archive
 CIF::Archive::DataType::Plugin::Hash

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
