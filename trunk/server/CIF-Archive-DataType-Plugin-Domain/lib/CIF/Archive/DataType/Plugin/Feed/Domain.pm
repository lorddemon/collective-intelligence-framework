package CIF::Archive::DataType::Feed::Plugin::Domain;


sub prepare {
    my $class = shift;
    my $info = shift;

    return(0) unless($info->{'impact'} =~ /domain/);
    return('feed_domain');
}

1;
