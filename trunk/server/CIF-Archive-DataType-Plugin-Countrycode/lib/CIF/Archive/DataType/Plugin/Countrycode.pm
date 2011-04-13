package CIF::Archive::DataType::Plugin::Countrycode;
use base 'CIF::Archive::DataType';

use 5.008008;
use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];

__PACKAGE__->table('countrycode');
__PACKAGE__->columns(Primary => 'id');__PACKAGE__->columns(All => qw/id uuid description cc source severity restriction alternativeid alternativeid_restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid description cc restriction created/);
__PACKAGE__->sequence('countrycode_id_seq');


our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

# Preloaded methods go here.

sub prepare {
    my $class = shift;
    my $info = shift;

    ## TODO -- download list of IANA country codes for use in regex
    ## http://data.iana.org/TLD/tlds-alpha-by-domain.txt
    return unless($info->{'cc'});
    return unless($info->{'cc'} =~ /^[a-zA-Z]{2,3}$/);
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
            $class->table($t);
        }
    }

    my $id = eval { $class->SUPER::insert({
        uuid        => $info->{'uuid'},
        description => lc($info->{'description'}),
        cc          => $info->{'cc'},
        source      => $info->{'source'},
        severity    => $info->{'severity'},
        restriction => $info->{'restriction'} || 'private',
        detecttime  => $info->{'detecttime'},
        alternativeid   => $info->{'alternativeid'},
        alternativeid_restriction => $info->{'alternativeid_restriction'} || 'private',
    }) };
    if($@){
        return(undef,$@) unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $class->retrieve(uuid => $info->{'uuid'});
    }
    $class->table($tbl);
    return($id);
}

sub lookup {
    my $class = shift;
    my $info = shift;
    my $q = $info->{'query'};
    $q = uc($q);

    my $sth = $class->sql_by_cc();
    my $r = $sth->execute($q,10000);
    my $ret = $sth->fetchall_hash();
    return($ret);
}

__PACKAGE__->set_sql('by_cc' => qq{
    SELECT * FROM __TABLE__
    WHERE cc = ?
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::Archive::DataType::Plugin::Countrycode - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::Archive::DataType::Plugin::Countrycode;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for CIF::Archive::DataType::Plugin::Countrycode, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

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

Copyright (C) 2011 by Wes Young

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
