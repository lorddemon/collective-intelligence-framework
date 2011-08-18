package CIF::Client::Plugin::Iodef::Group;

sub hash_simple {
    my $class = shift;
    my $hash = shift;

    my ($rdata,$type);
    my $ad = $hash->{'AdditionalData'};
    my @array;
    if(ref($ad) eq 'ARRAY'){
        @array = @$ad;
    } else {
        push(@array,$ad);
    }
    foreach my $a (@array){
        for(lc($a->{'meaning'})){
            next unless(/guid/);
            $type   = $a->{'content'} if(/type/);
            return({
                guid   => $a->{'content'}
            });
        }
    }
}
1;
