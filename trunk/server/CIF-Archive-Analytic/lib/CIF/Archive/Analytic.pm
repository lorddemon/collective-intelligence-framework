package CIF::Archive::Analytic;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use Module::Pluggable require => 1;
require CIF::Archive;
require CIF::Archive::DataType::Plugin::Analytic;

sub start_run {
    my $self = shift;
    my $info = shift;
    unless($info->{'max'}){
        $info->{'max'} = 500;
    }

    my $last_id = CIF::Archive::DataType::Plugin::Analytic->last_run();
    my $x = CIF::Archive->maximum_value_of('id');
    if(($x - $last_id) < $info->{'max'}){
        $info->{'max'} = ($x - $last_id);
    }

    my $nextid = 0;
    if($last_id){
        $nextid = $last_id + 1;
    }
    my $endid = $nextid + $info->{'max'};

    my $ret = CIF::Archive->insert({
        description => $info->{'description'} || 'analytics run start',
        startid     => $nextid,
        endid       => $endid,
    });
    return({
        startid => $nextid,
        endid   => $endid
    });
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
