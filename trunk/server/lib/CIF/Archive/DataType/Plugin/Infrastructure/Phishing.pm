package CIF::Archive::DataType::Plugin::Infrastructure::Phishing;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

__PACKAGE__->table('infrastructure_phishing');

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /phish/);
    return('phishing');
}

1;
