package CIF::Archive::DataType::Plugin::Domain::Nameserver;
use base 'CIF::Archive::DataType::Plugin::Domain';

sub prepare {
    my $class = shift;
    my $info = shift;
    return unless($info->{'impact'});
    return(0) unless($info->{'impact'} =~ /nameserver/);
    return('domain_nameserver');
}

1;
