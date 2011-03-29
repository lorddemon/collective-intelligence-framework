package CIF::Archive::Storage::Plugin::Atom::Json;

use strict;
use warnings;

use Google::Data::JSON;

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'format'} eq 'application/json+atom');
    return(1);
}

sub convert {
    my $class = shift;
    my $info = shift;
    my $feed = shift;
    
    my $gdata = Google::Data::JSON->new(xml => $feed->as_xml());
    return($gdata->as_json());
} 
1;
