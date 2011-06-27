package CIF::Archive::DataType::Plugin::Url::Botnet;
use base 'CIF::Archive::DataType::Plugin::Url';

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /botnet/);
    return('url_botnet');
}

1;
