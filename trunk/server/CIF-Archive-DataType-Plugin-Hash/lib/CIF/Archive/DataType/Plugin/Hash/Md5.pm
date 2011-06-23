package CIF::Archive::DataType::Plugin::Hash::Md5;
use base 'CIF::Archive::DataType::Plugin::Hash';

sub prepare {
    my $class = shift;
    my $info = shift;
    
    ## TODO -- fix this
    ## collision with CIF::Archive::DataType::Plugin::Feed
    return if($info->{'impact'} && $info->{'impact'} =~ /feed$/);
    my $hash = $info->{'md5'} || $info->{'hash'};
    return unless($hash);
    $hash = lc($hash);
    ## TODO -- set this up to accomodate multiple hashes
    return unless(_prepare($hash));
    $info->{'hash'} = $hash;
    return('hash_md5');
}

sub lookup {
    my $class = shift;
    my $q = shift || return;
    return unless(_prepare($q));
    return(1);
}

sub _prepare {
    my $arg = shift || return;
    return unless($arg =~ /^[a-fA-F0-9]{32}$/);
    return(1);
}

1;
