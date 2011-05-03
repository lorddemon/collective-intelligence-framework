package CIF::FeedParser::Plugin::Pull::File;

sub pull {
    my $class = shift;
    my $f = shift;
    return unless($f->{'feed'} =~ /^(\/\S+)/);
    open(F,$1) || die($!.': '.$_);
    my $content = join('',<F>);
    return('no content',undef) unless($content && $content ne '');
    return($content);
}

1;
