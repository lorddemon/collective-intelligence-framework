package RINO::Client;

use 5.008008;
use strict;
use warnings;

use XML::IODEF;
use XML::Simple;
use Data::Dumper;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

# Preloaded methods go here.

sub in {
    my $xml = shift;
    return unless($xml);
    return XMLin($xml);
}
1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

RINO::Client - Perl extension for parsing RINO data

=head1 SYNOPSIS

 use RINO::Client;
 use Data::Dumper;

 my $f = '/tmp/iodef.txt';
 open(F,$f);
 my @array = <F>;
 my $xml = join('',@array);

 my $hash = RINO::Client::in($xml);
 warn Dumper($hash);

=head1 DESCRIPTION

Stub documentation for RINO::Client, created by h2xs. It looks like the
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
