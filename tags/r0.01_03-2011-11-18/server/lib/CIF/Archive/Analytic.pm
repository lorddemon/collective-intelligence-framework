package CIF::Archive::Analytic;

use 5.008008;
use strict;
use warnings;

use Module::Pluggable require => 1;
require CIF::Archive;
require CIF::Archive::DataType::Plugin::Analytic;
require CIF::Client;

sub start_run {
    my $self = shift;
    my $info = shift;

    my $ret;
    my @recs;
    require CIF::Archive;
    do {
        $ret = CIF::Archive::DataType::Plugin::Analytic->next_run($info);
        return unless($ret);
        my $startid = $ret->{'startid'};
        my $endid = $ret->{'endid'};

        @recs = CIF::Archive->retrieve_from_sql(qq{
            id >= $startid
            AND id <= $endid
            ORDER BY id ASC
        });
        unless(@recs && $::debug){
            warn 'no recs between id '.$startid.' and '.$endid;
        }
    } until(@recs);
    @recs = map { $_->{'data'} = $_->data_hash } @recs;
    my $f;
    @{$f->{'data'}->{'feed'}->{'entry'}} = @recs;
    $f = CIF::Client->hash_simple($f);
    @recs = @{$f->{'data'}->{'feed'}->{'entry'}};
    my @array;
    foreach(@recs){
        next unless(ref($_) eq 'HASH');
        push(@array,$_);
    }
    return(\@array);
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::Archive::Analytic - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::Archive::Analytic;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for CIF::Archive::Analytic, created by h2xs. It looks like the
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
