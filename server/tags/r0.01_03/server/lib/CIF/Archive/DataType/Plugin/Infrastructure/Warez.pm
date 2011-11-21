package CIF::Archive::DataType::Plugin::Infrastructure::Warez;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

__PACKAGE__->table('infrastructure_warez');

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'impact'} =~ /warez infrastructure$/);
    return('warez');
}
1;
