package CIF::WebAPI::Writer::atom;
use strict;
use warnings;

use JSON;
use MIME::Base64;
use Compress::Zlib;
use Encode qw/encode_utf8/;
use Google::Data::JSON;
use Data::Dumper;
use XML::Atom::SimpleFeed;
use XML::Atom::Feed;
use XML::Atom::Entry;

=head1 NAME

Apache2::REST::Writer::json - Apache2::REST::Response Writer for json

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
    return 'text/plain';
}

=head2 asBytes

Returns the response as json UTF8 bytes for output.

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
         my $entry = XML::Atom::Entry->new();
         $entry->content($e[0], { mode => 'base64' });
         $feed->add_entry($entry);
    }
    return($feed->as_xml());
}

1;
