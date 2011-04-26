package CIF::Archive::DataType::Feed::Plugin::Domain;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];

sub prepare {
    my $class = shift;
    my $info = shift;

    return(0) unless($info->{'impact'} =~ /domain/);
    return('feed_domain');
}

1;
