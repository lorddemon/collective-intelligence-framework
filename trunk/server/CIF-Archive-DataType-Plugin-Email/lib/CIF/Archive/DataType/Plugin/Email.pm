package CIF::Archive::DataType::Plugin::Email;
use base 'CIF::Archive::DataType';

require 5.008;
use strict;
use warnings;

our $VERSION = '0.01_01';
eval $VERSION;

use Module::Pluggable require => 1, search_path => [__PACKAGE__];

__PACKAGE__->table('email');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description address subject impact source confidence severity restriction alternativeid alternativeid_restriction detecttime created/);
__PACKAGE__->sequence('email_id_seq');

sub prepare {
    my $class = shift;
    my $info = shift;

    my $address = $info->{'address'} || return(undef);
    return(undef) unless(/\w+@\w+$/);
    return(1);
}

sub insert {
    my $self = shift;
    my $info = shift;

    my $tbl = $self->table();
    foreach($self->plugins()){
        if(my $t = $_->prepare($info)){
            $self->table($t);
        }
    }
    
    my $id = eval { $self->SUPER::insert({
        uuid            => $info->{'uuid'},
        description     => lc($info->{'description'}),
        address         => $info->{'address'},
        source          => $info->{'source'},
        impact          => $info->{'impact'},
        confidence      => $info->{'confidence'},
        severity        => $info->{'severity'},
        restriction     => $info->{'restriction'} || 'private',
        detecttime      => $info->{'detecttime'},
        alternativeid   => $info->{'alternativeid'},
        alternativeid_restriction   => $info->{'alternativeid_restriction'} || 'private',
    }) };
    if($@){
        die unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $self->retrieve(uuid => $info->{'uuid'});
    }
    $self->table($tbl);
    return($id);
}

sub lookup {
    my $self = shift;
    my $info = shift;
    my $address = $info->{'query'};
    return(undef) unless($address =~ /\w+@\w+$/);
    return($self->SUPER::lookup($address,$info->{'limit'}));
}

1;

__END__
