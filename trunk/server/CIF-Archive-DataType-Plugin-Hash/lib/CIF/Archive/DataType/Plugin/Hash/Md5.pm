package CIF::Archive::DataType::Plugin::Hash::Md5;
use base 'CIF::Archive::DataType::Plugin::Hash';

sub prepare {
    my $class = shift;
    my $info = shift;
    my $h = $info->{'hash_md5'} || $info->{'hash'};
    return unless($h);

    return unless($h =~ /^[a-fA-F0-9]{32}$/);
    $info->{'hash'} = $h;
    return('hash_md5');
}

sub lookup {
    my $class = shift;
    my $q = shift;
    return unless($q && $q =~ /^[a-fA-F0-9]{32}$/);
    return(1);
}

1;
