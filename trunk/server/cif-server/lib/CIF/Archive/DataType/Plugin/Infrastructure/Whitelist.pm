package CIF::Archive::DataType::Plugin::Infrastructure::Whitelist;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /whitelist/);
    return('infrastructure_whitelist');
}

1;
