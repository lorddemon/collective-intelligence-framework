package CIF::Archive::DataType::Plugin::Hash::Sha1;
use base 'CIF::Archive::DataType::Plugin::Hash';

sub prepare {
    my $class = shift;
    my $info = shift;

    ## TODO -- fix this
    ## collision with CIF::Archive::DataType::Plugin::Feed
    return if($info->{'impact'} && $info->{'impact'} =~ /feed$/);

    my $h = $info->{'hash_sha1'} || $info->{'hash'};
    return unless($h);

    return unless($h =~ /^[a-fA-F0-9]{40}$/);
    $info->{'hash'} = $h;
    return('hash_sha1');
}

sub lookup {
    my $class = shift;
    my $q = shift;
    return unless($q && $q =~ /^[a-fA-F0-9]{40}$/);
    return(1);
}

1;
