package CIF::Client::Plugin::Raw;

sub write_out {
    my $self = shift;
    my @array = @_;
    my $text = '';
    foreach (@array){
        $text .= $_->{'message'};
    }
    return $text;
}
1;
