package CIF::DBI;
use base Class::DBI;

use strict;
use warnings;

our $VERSION = '0.00_02';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

__PACKAGE__->connection('DBI:Pg:database=cif;host=localhost','postgres','',{ AutoCommit => 1} );

sub check_params {
    my ($self,$tests,$info) = @_;
    
    foreach my $key (keys %$info){
        if(exists($tests->{$key})){
            my $test = $tests->{$key};
            unless($info->{$key} =~ m/$test/){
                return(undef,'invaild value for '.$key.': '.$info->{$key});
            }
        }
    }
    return(1);
}

__PACKAGE__->set_sql('feed' => qq{
    SELECT * FROM __TABLE__
    WHERE detecttime >= ?
    AND severity >= ?
    AND restriction <= ?
    AND NOT (lower(impact) LIKE 'search %' OR lower(impact) LIKE '% whitelist %')
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::DBI - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::DBI;
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

Wes Young, E<lt>wes@ren-isac.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by REN-ISAC and The Trustees of Indiana University 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut

