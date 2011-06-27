package CIF::Archive::DataType::Plugin::Hash::Uuid;
use base 'CIF::Archive::DataType::Plugin::Hash';

sub prepare {
    my $class = shift;
    my $info = shift;
    foreach(keys %$info){
        next if($_ eq 'uuid');
        next if($_ eq 'source');
        next unless($info->{$_});
        if(_prepare($info->{$_})){
            $info->{'hash'} = $info->{$_};
            return('hash_uuid');
        }
    }
    return(undef);
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
