package CIF::Archive::Analytic::Plugin::DomainWhitelistPrefix;

use strict;
use warnings;

sub process {
    my $class = shift;
    my $data = shift;
    my $config = shift;
    my $archive = shift;

    return unless(ref($data) eq 'HASH');
    return unless($data->{'impact'});
    return unless($data->{'impact'} eq 'domain whitelist');
    return unless($data->{'prefix'});

    return unless($data->{'confidence'} >= 69);
    my $conf = $data->{'confidence'};
    my $log = log($conf) / log(500);
    $conf = sprintf('%.3f',($conf * $log));
    my ($err,$id) = $archive->insert({
        source                      => $data->{'source'},
        severity                    => 'null',
        confidence                  => $conf,
        address                     => $data->{'prefix'},
        impact                      => 'infrastructure whitelist',
        description                 => $data->{'address'},
        restriction                 => $data->{'restriction'},
        alternativeid               => $data->{'alternativeid'},
        alternativeid_restriction   => $data->{'alternativeid_restriction'},
        guid                        => $data->{'guid'},
        relatedid                   => $data->{'uuid'},
    });
    warn $err if($err);
    warn $id->{'uuid'} if($::debug && $id);
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::Archive::Analytic::Plugin::DomainWhitelistPrefix - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::Archive::Analytic::Plugin::DomainWhitelistPrefix;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for CIF::Archive::Analytic::Plugin::DomainWhitelistPrefix, created by h2xs. It looks like the
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
