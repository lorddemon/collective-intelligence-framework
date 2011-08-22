package CIF::Archive::DataType::Plugin::Hash::Sha1;
use base 'CIF::Archive::DataType::Plugin::Hash';

sub prepare {
    my $class = shift;
    my $info = shift;

    ## TODO -- fix this
    ## collision with CIF::Archive::DataType::Plugin::Feed
    return if($info->{'impact'} && $info->{'impact'} =~ /feed$/);
    my $hash = $info->{'sha1'} || $info->{'hash'};
    return unless($hash);
    return unless(lc($hash) =~ /^[a-f0-9]{40}$/);
    $info->{'hash'} = $hash;
    return('sha1');


}

sub lookup {
    my $class = shift;
    my $q = shift;
    return unless($q);
    return unless(lc($q) =~ /^[a-f0-9]{40}$/);
    return(1);
}

1;
