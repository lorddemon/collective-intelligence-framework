package CIF::Archive::DataType::Plugin::Feed;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

__PACKAGE__->table('feed');
__PACKAGE__->columns(All => qw/id uuid guid description confidence source hash_sha1 signature impact severity restriction detecttime created data/);
__PACKAGE__->columns(Essential => qw/id uuid guid description confidence source hash_sha1 signature impact severity restriction detecttime created data/);
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->sequence('feed_id_seq');

sub prepare {
    my $class = shift;
    my $info = shift;
    return unless($info->{'impact'});
    return(undef) unless($info->{'impact'} =~ /feed/);
    return(1);
}

sub insert {
    my $self = shift;
    my $info = shift;
    my $uuid = $info->{'uuid'};

    my $id = eval { $self->SUPER::insert($info) };
    if($@){
        return(undef,$@) unless($@ =~ /unique/);
        $id = CIF::Archive->retrieve(uuid => $uuid);
    }
    return($id);
}

__PACKAGE__->set_sql('lookup' => qq{
    SELECT __ESSENTIAL__
    FROM __TABLE__
    WHERE impact = ?
    AND severity = ?
    AND confidence >= ?
    AND restriction = ?
    ORDER BY confidence asc, detecttime desc, created desc, id DESC LIMIT 1
});

sub lookup {
    my $class = shift;
    my $info = shift;

    my $severity = $info->{'severity'};
    my $restriction = $info->{'restriction'};
    my $query = $info->{'query'}.' feed';

    my @args = ($query,$severity,$info->{'confidence'},$restriction);
    return $class->SUPER::lookup(@args);
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
