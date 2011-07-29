package CIF::Archive::DataType::Plugin::Hash;
use base 'CIF::Archive::DataType';

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;

__PACKAGE__->table('hash');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid hash confidence source type severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid hash confidence source type severity restriction detecttime created/);
__PACKAGE__->sequence('hash_id_seq');

sub prepare {
    my $class = shift;
    my $info = shift;

    foreach my $p ($class->plugins()){
        return(1) if($p->prepare($info));
    }
    return(undef);
}

sub insert {
    my $class = shift;
    my $info = shift;

    my $tbl = $class->table();
    my $id;
    foreach($class->plugins()){
        if(my $t = $_->prepare($info)){
            $class->table($t);
            $id = eval { $class->SUPER::insert({
                uuid        => $info->{'uuid'},
                hash        => $info->{'hash'},
                source      => $info->{'source'},
                confidence  => $info->{'confidence'},
                severity    => $info->{'severity'} || 'null',
                restriction => $info->{'restriction'} || 'private',
                detecttime  => $info->{'detecttime'},
            }) };
            if($@){
                return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
                $id = CIF::Archive->retrieve(uuid => $info->{'uuid'});
            }
        }
    }
    $class->table($tbl);
    return($id);
}

sub feed {
    my $class = shift;
    my $info = shift;

    my @feeds;
    $info->{'key'} = 'hash';
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

sub lookup {
    my $class = shift;
    my $info = shift;
    my $q = $info->{'query'};
    foreach($class->plugins()){
        if(my $r = $_->lookup($q)){
            return($class->SUPER::lookup($q,$info->{'severity'},$info->{'confidence'},$info->{'restriction'},$info->{'limit'}));
        }
    }
    return(undef);
}

__PACKAGE__->set_sql('lookup' => qq{
    SELECT __ESSENTIAL__
    FROM __TABLE__
    WHERE lower(hash) = lower(?)
    and severity >= ?
    and confidence >= ?
    and restriction <= ?
    ORDER BY detecttime DESC, created DESC, id DESC
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
