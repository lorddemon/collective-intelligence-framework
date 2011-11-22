package CIF::Archive::DataType::Plugin::Feed::Search;
use base 'CIF::Archive::DataType::Plugin::Feed';

__PACKAGE__->table('feed_search');

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /search/);
    return(1);
}

1;
