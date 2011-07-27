package CIF::Client::Plugin::Iodef::Bgp;

sub hash_simple {
    my $class = shift;
    my $hash = shift;
    my $sh = shift;

    my ($asn,$prefix,$rir,$cc);

    my $ad = $hash->{'EventData'}->{'Flow'}->{'System'}->{'AdditionalData'};
    my @array;
    if(ref($ad) eq 'ARRAY'){
        @array = @$ad;
    } else {
        push(@array,$ad);
    }
    foreach my $a (@array){
        next unless($a->{'meaning'});
        for(lc($a->{'meaning'})){
            $asn    = $a->{'content'} if(/asn/);
            $prefix = $a->{'content'} if(/prefix/);
            $rir    = $a->{'content'} if(/rir/);
            $cc     = $a->{'content'} if(/cc/);
        }
    }
    return unless($asn || $prefix || $rir || $cc);
    $sh->{'asn'} = $asn;
    $sh->{'prefix'} = $prefix;
    $sh->{'rir'} = $rir;
    $sh->{'cc'} = $cc;
    return($sh);
}

1;
