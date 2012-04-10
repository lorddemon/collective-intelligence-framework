package CIF::Archive::DataType::Plugin::Domain::Nameserver;
use base 'CIF::Archive::DataType::Plugin::Domain';

__PACKAGE__->table('domain_nameserver');

sub prepare {
    my $class = shift;
    my $info = shift;
    return unless($info->{'impact'});
    return(0) unless($info->{'impact'} =~ /nameserver/);
    return('nameserver');
}

1;
