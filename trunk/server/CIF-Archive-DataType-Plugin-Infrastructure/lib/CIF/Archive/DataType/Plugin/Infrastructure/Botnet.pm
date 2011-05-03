package CIF::Archive::DataType::Plugin::Infrastructure::Botnet;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /botnet/);
    return('infrastructure_botnet');
}

1;
