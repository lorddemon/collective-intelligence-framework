package CIF::Archive::DataType::Plugin::Hash::Uuid;
use base 'CIF::Archive::DataType::Plugin::Hash';

sub prepare {
    my $class = shift;
    my $info = shift;
    my $h = $info->{'hash_uuid'} || $info->{'hash'};
    return unless(_prepare($h));
    $info->{'hash'} = $h;
    return('hash_uuid');
}

sub lookup {
    my $class = shift;
    my $q = shift;
    return unless(_prepare($q));
    return(1);
}

sub _prepare {
    my $arg = shift || return;
    return unless($arg =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/);
    return(1);
}

1;
