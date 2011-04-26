package CIF::Archive::DataType::Plugin::Domain::Phishing;
use base 'CIF::Archive::DataType::Plugin::Domain';

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /phish/);
    return('domain_phishing');
}

1;
