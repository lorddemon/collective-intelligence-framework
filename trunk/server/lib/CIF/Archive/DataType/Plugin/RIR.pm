package CIF::Archive::DataType::Plugin::RIR;
use base 'CIF::Archive::DataType';

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use Module::Pluggable require => 1, search_path => [__PACKAGE__];

__PACKAGE__->table('rir');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid rir source confidence severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid rir source confidence severity restriction detecttime created/);
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
            $class->table($t);
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
    return($class->SUPER::lookup($q,$info->{'severity'},$info->{'confidence'},$info->{'restriction'},$info->{'limit'}));
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
    return(\@feeds);

    $info->{'key'} = 'rir';
    my $ret = $class->SUPER::feed($info);
    push(@feeds,$ret) if($ret);

    foreach($class->plugins()){
        my $t = $_->set_table();
        my $r = $_->SUPER::feed($info);
        push(@feeds,$r) if($r);
    }
    return(\@feeds);
}

__PACKAGE__->set_sql('feed' => qq{
    SELECT count(rir),rir,max(detecttime) as detecttime
    FROM __TABLE__
    WHERE detecttime >= ?
    AND confidence >= ?
    AND severity >= ?
    AND restriction <= ?
    GROUP BY rir
    ORDER BY count DESC
    LIMIT ?
});

__PACKAGE__->set_sql('lookup' => qq{
    SELECT __ESSENTIAL__
    FROM __TABLE__
    WHERE rir = ?
    AND severity >= ?
    AND confidence >= ?
    and restriction <= ?
    ORDER BY detecttime DESC, created DESC, id DESC
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
