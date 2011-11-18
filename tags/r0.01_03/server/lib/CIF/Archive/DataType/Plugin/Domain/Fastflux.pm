package CIF::Archive::DataType::Plugin::Domain::Fastflux;
use base 'CIF::Archive::DataType::Plugin::Domain';

__PACKAGE__->table('domain_fastflux');

sub prepare {
    my $class = shift;
    my $info = shift;
    return unless($info->{'impact'});
    return(0) unless($info->{'impact'} =~ /fastflux/);
    return('fastflux');
}

1;
