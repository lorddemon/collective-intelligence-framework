package CIF::Client::Plugin::Raw;

sub write_out {
    my $self = shift;
    my $config = shift;
    my @array = @_;
    my $text = '';
    foreach (@array){
        $text .= $_->{'message'};
    }
    return $text;
}
1;
