package CIF::Archive::DataType::Plugin::Email::Phishing;
use base 'CIF::Archive::DataType::Plugin::Email';

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'impact'} =~ /phish/);
    return('phishing');
}
1;
