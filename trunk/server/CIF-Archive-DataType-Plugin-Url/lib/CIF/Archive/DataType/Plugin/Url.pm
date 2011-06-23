package CIF::Archive::DataType::Plugin::Url;
use base 'CIF::Archive::DataType';

require 5.008;
use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;
use Digest::SHA1 qw(sha1_hex);
use Digest::MD5 qw(md5_hex);
use Encode qw/encode_utf8/;
use URI::Escape;
use Regexp::Common qw/URI/;

__PACKAGE__->table('url');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid source address confidence severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid source address confidence severity restriction detecttime created/);
__PACKAGE__->sequence('url_id_seq');

## sub lookup {} is via Plugin::Hash
sub lookup { return; }

sub prepare {
    my $class = shift;
    my $info = shift;
    return unless($info->{'impact'});
    return unless($info->{'impact'} =~ /url$/);
    return unless($info->{'address'});
    return unless($info->{'address'} =~ /^$RE{'URI'}/);
    $info->{'md5'} = md5_hex($info->{'address'}) unless($info->{'md5'});
    $info->{'sha1'} = sha1_hex($info->{'address'}) unless($info->{'sha1'});
    return(1);
}

sub insert {
    my $self = shift;
    my $info = shift;
    
    my $uuid    = $info->{'uuid'};
    my $address = $info->{'address'};

    my $tbl = $self->table();
    foreach($self->plugins()){
        if(my $t = $_->prepare($info)){
            $self->table($t);
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
    }) };
    if($@){
        die unless($@ =~ /duplicate key value violates unique constraint/);
        $id = CIF::Archive->retrieve(uuid => $uuid);
    }
    $self->table($tbl);
    return($id);
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
