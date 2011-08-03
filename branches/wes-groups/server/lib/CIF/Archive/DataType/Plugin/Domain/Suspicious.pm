package CIF::Archive::DataType::Plugin::Domain::Suspicious;
use base 'CIF::Archive::DataType::Plugin::Domain';

sub prepare {
    my $class = shift;
    my $info = shift;
    return unless($info->{'impact'});
    return(0) unless($info->{'impact'} =~ /suspicious/);
    return(0) if($info->{'impact'} =~ /nameserver/);
    return('domain_suspicious');
}

1;
