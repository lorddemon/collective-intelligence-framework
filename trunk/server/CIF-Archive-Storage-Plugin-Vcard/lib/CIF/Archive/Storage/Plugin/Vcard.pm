package CIF::Archive::Storage::Plugin::Vcard;
use base 'CIF::Archive::Storage';

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use Module::Pluggable search_path => [__PACKAGE__], require => 1;

use Text::vCard;
use Text::vCard::Addressbook;

# Preloaded methods go here.

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'impact'} =~ /[person|entity|organization]/);
    return unless($info->{'email'} && $info->{'fullname'});
    return(1);
}

sub convert {
    my $class = shift;
    my $info = shift;

    $info->{'format'} = 'vcard';

    my $ab = Text::vCard::Addressbook->new();
    $ab->add_vcard('utf-8');

    foreach my $v ($ab->vcards()){
        $v->fullname($info->{'fullname'});
        $v->email($info->{'email'});
    }
    return($ab->export());
}
1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::Archive::Storage::Plugin::Vcard - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::Archive::Storage::Plugin::Vcard;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for CIF::Archive::Storage::Plugin::Vcard, created by h2xs. It looks like the
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
