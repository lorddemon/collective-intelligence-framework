package CIF::Archive::DataType::Plugin::Infrastructure::Spam;
use base 'CIF::Archive::DataType::Plugin::Infrastructure';

__PACKAGE__->table('infrastructure_spam');

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /spam/);
    return('spam');
}

1;
