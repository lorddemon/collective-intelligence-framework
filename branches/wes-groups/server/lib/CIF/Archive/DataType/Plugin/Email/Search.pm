package CIF::Archive::DataType::Plugin::Email::Search;
use base 'CIF::Archive::DataType::Plugin::Email';

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'impact'} =~ /search/);
    return('search');
}
1;
