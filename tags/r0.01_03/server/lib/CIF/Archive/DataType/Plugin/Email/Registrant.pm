package CIF::Archive::DataType::Plugin::Email::Registrant;
use base 'CIF::Archive::DataType::Plugin::Email';

__PACKAGE__->table('email_registrant');

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'impact'} =~ /registrant/);
    return('registrant');
}
1;
