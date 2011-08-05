package CIF::Archive::DataType::Plugin::Infrastructure::Scan;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /scan/);
    return('scan');
}

1;
