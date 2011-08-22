package CIF::Archive::DataType::Plugin::Infrastructure::Passivedns;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'impact'} =~ /passive dns/);
    return('passivedns');
}
1;
