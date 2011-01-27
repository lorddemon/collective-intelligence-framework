package CIF::Client::Plugin::Pcapfilter;

use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;

sub write_out {
    my $self = shift;
    my $config = shift;
    my @array = @_;
    my $text = '';
    foreach (@array){
        my $address = $_->{'address'};
        if($address =~ /^$RE{'net'}{'CIDR'}{'IPv4'}$/){
            $text .= "net $address or ";
        } else {
            $text .= "host $address or ";
        }
    }
    $text =~ s/ or//;
    return $text;
}
1;
