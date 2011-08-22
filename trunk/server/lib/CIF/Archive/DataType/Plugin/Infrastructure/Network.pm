package CIF::Archive::DataType::Plugin::Infrastructure::Network;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

sub prepare {
    my $class = shift;
    my $info = shift;

    ## TODO -- figure out how to sanely index cidrs as addresses in the suspicious networks index
#    return('network') if($info->{'cidr'});
    return unless($info->{'impact'} =~ /network/);
    return('network');
}

1;
