package CIF::Archive::DataType::Plugin::Infrastructure::Scan;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

__PACKAGE__->table('infrastructure_scan');

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /scan/);
    return('scan');
}

1;
