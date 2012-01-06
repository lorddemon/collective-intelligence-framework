package CIF::Archive::Storage::Plugin::Iodef::Feed;

sub prepare {
    my $class   = shift;
    my $info    = shift;

    return unless($info->{'impact'} && $info->{'impact'} eq 'search');
    return unless($info->{'description'} && $info->{'description'} =~ /^search\s[\s\S]+\sfeed$/);
    return(1);
}

sub convert {
    my $self = shift;
    my $info = shift;
    my $iodef = shift;

    return $iodef;
}

1;
