package RT::CIF;

use strict;
use warnings;

our $VERSION = '0.00_01';

use Net::CIDR;

my @list = (
    "0.0.0.0/8",
    "10.0.0.0/8",
    "127.0.0.0/8",
    "192.168.0.0/16",
    "169.254.0.0/16",
    "192.0.2.0/24",
    "224.0.0.0/4",
    "240.0.0.0/5",
    "248.0.0.0/5"
);

sub isPrivateAddress {
    my $addr = shift;
    my $found =  Net::CIDR::cidrlookup($addr,@list);
    return($found);
}


1;
