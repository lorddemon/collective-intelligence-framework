package CIF::Archive::DataType::Plugin::Infrastructure::Scanning;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /scan/);
    return('infrastructure_scanning');
}

1;
