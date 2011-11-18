package CIF::Archive::DataType::Plugin::Domain::Suspicious;
use base 'CIF::Archive::DataType::Plugin::Domain';

__PACKAGE__->table('domain_suspicious');

sub prepare {
    my $class = shift;
    my $info = shift;
    return unless($info->{'impact'});
    return(0) unless($info->{'impact'} =~ /suspicious/);
    return(0) if($info->{'impact'} =~ /nameserver/);
    return('suspicious');
}

1;
