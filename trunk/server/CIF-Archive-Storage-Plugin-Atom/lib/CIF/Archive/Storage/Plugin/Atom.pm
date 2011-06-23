package CIF::Archive::Storage::Plugin::Atom;
use base 'CIF::Archive::Storage';

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use Module::Pluggable search_path => [__PACKAGE__], require => 1;

use strict;
use warnings;

use XML::Atom::Feed;
use XML::Atom::Entry;
use MIME::Base64;
use Data::Dumper;

sub prepare {
    my $class = shift;
    my $info = shift;

#    return unless($info->{'impact'} =~ /feed/);
#    return(1);
    return;
}

sub convert {
    my $class = shift;
    my $info = shift;

    my $impact          = $info->{'impact'};
    my $description     = lc($info->{'description'});
    my $severity        = $info->{'severity'};
    my $restriction     = $info->{'restriction'} || 'private';
    my $source          = $info->{'source'};
    my $detecttime      = $info->{'detecttime'};
    my $hash_sha1       = $info->{'hash_sha1'};
    my $data            = $info->{'data'};
    my $lang            = $info->{'lang'} || 'en';

    if($class->_is_printable($data)){
        $data = decode_base64($data);
    }

    $info->{'format'}   = 'application/xml+atom' unless($info->{'format'});

    my $feed = XML::Atom::Feed->new();
    $feed->rights($restriction);
    my $s = XML::Atom::Person->new();
    $s->name($source);
    $feed->author($s);
    $feed->title($description);
    $feed->language($lang);
    $feed->updated($detecttime);
    $feed->subtitle($hash_sha1);

    my $entry = XML::Atom::Entry->new();
    $entry->content($data);
    $entry->published($detecttime);

    $feed->add_entry($entry);

    foreach($class->plugins()){
        if($_->prepare($info)){
            $feed = $_->convert($info,$feed);
            return($feed);
        }
    }
    return($feed->as_xml());
}

sub from {
    my $self = shift;
    my $msg = shift;
}
    
1;
