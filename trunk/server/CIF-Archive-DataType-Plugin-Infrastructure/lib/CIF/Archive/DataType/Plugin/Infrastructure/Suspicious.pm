package CIF::Archive::DataType::Plugin::Infrastructure::Suspicious;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'impact'} =~ /suspicious/);
    return('infrastructure_suspicious');
}
1;
