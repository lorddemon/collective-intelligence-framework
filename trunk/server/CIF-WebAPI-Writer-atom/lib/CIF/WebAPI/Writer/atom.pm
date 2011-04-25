package CIF::WebAPI::Writer::atom;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;

use 5.008;
use XML::Atom::Feed;
use XML::Atom::Entry;

=head1 NAME

CIF::WebAPI::Writer::atom - Apache2::REST::Response Writer for atom feeds, http://tools.ietf.org/html/rfc4287

=cut

=head2 new

=cut

sub new{
    my ( $class ) = @_;
    return bless {} , $class;
}

=head2 mimeType

Getter

=cut

sub mimeType {
    return 'text/xml';
}

=head2 asBytes

Returns the response as atom XML for output.

=cut

sub asBytes{
    my ($self,  $resp ) = @_ ;
    
    my $f = $resp->{'data'}->{'feed'};
    my @e = @{$f->{'entry'}};
    my $feed = XML::Atom::Feed->new();
    $feed->rights($f->{'restriction'});
    $feed->author($f->{'source'});
    $feed->title($f->{'description'});

    if(ref($e[0]) eq 'HASH'){
        foreach(@e){
            my $entry = XML::Atom::Entry->new();
            $entry->content($_->{'data'}) if($_->{'data'});
            $entry->title($_->{'description'});
            $entry->issued($_->{'detecttime'});
            $entry->updated($_->{'created'});
            $entry->rights($_->{'restriction'});
            $entry->author($_->{'source'});
            $entry->category($_->{'impact'});
            $feed->add_entry($entry);
        }
    } else {
        # it's an encoded feed object (usually zlib, base64, etc)
        my $entry = XML::Atom::Entry->new();
        $entry->content($e[0], { mode => 'base64' });
        $feed->add_entry($entry);
    }
    return(Encode::encode_utf8($feed->as_xml()));
}

1;

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
