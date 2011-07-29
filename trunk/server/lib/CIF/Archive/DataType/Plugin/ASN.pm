package CIF::Archive::DataType::Plugin::ASN;
use base 'CIF::Archive::DataType';

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;;

__PACKAGE__->table('asn');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid asn asn_desc source confidence severity restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid asn asn_desc source confidence severity restriction detecttime created/);
__PACKAGE__->sequence('asn_id_seq');

# Preloaded methods go here.

sub prepare {
    my $class = shift;
    my $info = shift;

    ## TODO -- download list of IANA country codes for use in regex
    ## http://data.iana.org/TLD/tlds-alpha-by-domain.txt
    return unless($info->{'asn'});
    return unless($info->{'asn'} =~ /^[0-9]*\.?[0-9]*$/);
    return(1);
}

sub insert {
    my $class = shift;
    my $info = shift;

    return unless($info->{'asn'});

    # you could create different buckets for different country codes
    my $tbl = $class->table();
    foreach($class->plugins()){
        if(my $t = $_->prepare($info)){
            $class->table($t);
        }
    }

    my $id = eval { $class->SUPER::insert({
        uuid        => $info->{'uuid'},
        asn         => $info->{'asn'},
        asn_desc    => $info->{'asn_desc'},
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
    $class->table($tbl);
    return($id);
}

sub lookup {
    my $class = shift;
    my $info = shift;
    my $q = $info->{'query'};
    return unless($q =~ /^[0-9]*\.?[0-9]*$/);

    return(
        $class->SUPER::lookup(
            $q,
            $info->{'severity'},
            $info->{'confidence'},
            $info->{'restriction'},
            $info->{'limit'}
        )
    );
}

sub feed {
    my $class = shift;
    my $info = shift;

    my @feeds;

    # this doesn't work quite yet.
    # gets stuck on recursive loop because of count()
    ## TODO -- finish
    return(\@feeds);
    $info->{'key'} = 'asn';
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
    SELECT count(asn),asn,asn_desc,max(detecttime) as detecttime
    FROM __TABLE__
    WHERE detecttime >= ?
    AND confidence >= ?
    AND severity >= ?
    AND restriction <= ?
    GROUP BY asn,asn_desc
    ORDER BY count DESC
    LIMIT ?
});

__PACKAGE__->set_sql('lookup' => qq{
    SELECT __ESSENTIAL__
    FROM __TABLE__
    WHERE asn = ?
    and severity >= ?
    and confidence >= ?
    and restriction <= ?
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;
__END__
=head1 NAME

 CIF::Archive::DataType::Plugin::ASN - Perl extension for indexing ASN's

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
