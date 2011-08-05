package CIF::WebAPI::APIKey;
use base 'CIF::DBI';

__PACKAGE__->table('apikeys');
__PACKAGE__->columns(Primary => 'uuid');
__PACKAGE__->columns(All => qw/uuid uuid_alias parentid revoked write access created/);
__PACKAGE__->sequence('apikeys_id_seq');
__PACKAGE__->has_many(groups  => 'CIF::WebAPI::APIKeyGroups');

use CIF::Utils;

# because UUID's are really primary keys too in our schema
# this overrides some of the default functionality of Class::DBI and 'id'
sub retrieve {
    my $class = shift;
    my %keys = @_;

    return $class->SUPER::retrieve(@_) unless($keys{'uuid'});

    my @recs = $class->search(uuid => $keys{'uuid'});
    return unless(@recs);
    return($recs[0]);
}

sub genkey {
    my ($self,%args) = @_;
    my $uuid = CIF::Utils::genUUID();

    my $r = CIF::WebAPI::APIKey->insert({
        uuid        => $uuid,
        uuid_alias  => $args{'uuid_alias'},
        access      => $args{'access'} || 'all',
        parentid    => $args{'parentid'},
        write       => $args{'write'},
        revoked     => $args{'revoked'},
    });
    if($args{'groups'}){
        $r->add_groups($args{'groups'});
    }
    return($r);
}

sub add_groups {
    my ($self,$groups) = @_;

    foreach (split(',',$groups)){
        $_ = CIF::Utils::genSourceUUID($_) unless(CIF::Utils::isUUID($_));
        my $id = CIF::WebAPI::APIKeyGroups->insert({
            uuid    => $self->uuid(),
            guid    => $_,
        });
    }
}

sub mygroups {
    my $self = shift;
    
    my @groups = $self->groups();
    return unless($#groups > -1);
    my $g = '';
    foreach (@groups){
        $g .= $_->guid().',';
    }
    $g =~ s/,$//;
    return $g;
}

1;

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::APIKEY - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::APIKEY;
  blah blah blah

=head1 DESCRIPTION

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Wes Young, E<lt>wes@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Wes Young

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut

