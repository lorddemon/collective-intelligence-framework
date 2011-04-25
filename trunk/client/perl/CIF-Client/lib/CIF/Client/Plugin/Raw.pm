package CIF::Client::Plugin::Raw;

sub write_out {
    my $self = shift;
    my $config = shift;
    my $feed = shift;
    my @array = @{$feed->{'feed'}->{'entry'}};

    my $text = '';
    foreach (@array){
        $text .= $_->{'data'};
    }
    return $text;
}
1;
