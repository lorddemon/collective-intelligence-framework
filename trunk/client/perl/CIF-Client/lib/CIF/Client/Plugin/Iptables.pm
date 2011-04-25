package CIF::Client::Plugin::Iptables;

sub write_out {
    my $self = shift;
    my $config = shift;
    my $feed = shift;
    my @array = @{$feed->{'feed'}->{'entry'}};

    my $text = "iptables -N CIF_IN\n";
    $text .= "iptables -F CIF_IN\n";
    $text .= "iptables -N CIF_OUT\n";
    $text .= "iptables -F CIF_OUT\n";
    foreach (@array){
        $text .= "iptables -A CIF_IN -s $_->{'address'} -j DROP\n";
        $text .= "iptables -A CIF_OUT -d $_->{'address'} -j DROP\n";
    }

    $text .= "iptables -A INPUT -j CIF_IN\n";
    $text .= "iptables -A CIF_IN -j LOG --log-level 6 --log-prefix '[IPTABLES] cif dropped'\n";
    $text .= "iptables -A OUTPUT -j CIF_OUT\n";
    $text .= "iptables -A CIF_OUT -j LOG --log-level 6 --log-prefix '[IPTABLES cif dropped'\n";

    return $text;
}
1;
