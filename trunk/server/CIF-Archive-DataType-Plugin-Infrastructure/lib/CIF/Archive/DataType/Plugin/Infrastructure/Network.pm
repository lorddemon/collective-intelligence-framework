package CIF::Archive::DataType::Plugin::Infrastructure::Network;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'impact'} =~ /network/);
    return('infrastructure_network');
}

1;
