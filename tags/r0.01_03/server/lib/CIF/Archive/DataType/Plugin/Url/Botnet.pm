package CIF::Archive::DataType::Plugin::Url::Botnet;
use base 'CIF::Archive::DataType::Plugin::Url';

__PACKAGE__->table('url_botnet');

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /botnet/);
    return('botnet');
}

1;
