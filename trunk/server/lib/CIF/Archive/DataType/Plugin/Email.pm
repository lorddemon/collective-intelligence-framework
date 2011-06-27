package CIF::Archive::DataType::Plugin::Email;
use base 'CIF::Archive::DataType';

require 5.008;
use strict;
use warnings;

our $VERSION = '0.01_01';
eval $VERSION;

use Module::Pluggable require => 1, search_path => [__PACKAGE__], except => qr/SUPER$/;
use Regexp::Common qw/URI/;

__PACKAGE__->table('email');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid address source confidence severity restriction detecttime created/);
__PACKAGE__->sequence('email_id_seq');

sub prepare {
    my $class = shift;
    my $info = shift;
   
    my $address = $info->{'address'} || return(undef);
    return if($address =~ /^$RE{'URI'}/);
    return unless($address =~ /\w+@\w+/);
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
        address         => $info->{'address'},
        source          => $info->{'source'},
        confidence      => $info->{'confidence'},
        severity        => $info->{'severity'} || 'null',
        restriction     => $info->{'restriction'} || 'private',
        detecttime      => $info->{'detecttime'},
    }) };
    if($@){
        die unless($@ =~ /duplicate key value violates unique constraint/);
        $id = CIF::Archive->retrieve(uuid => $info->{'uuid'});
    }
    $self->table($tbl);
    return($id);
}

sub feed {
    my $class = shift;
    my $info = shift;

    my @feeds;
    $info->{'key'} = 'address';
    my $ret = $class->SUPER::feed($info);
    push(@feeds,$ret) if($ret);

    my $tbl = $class->table();
    foreach($class->plugins()){
        my $t = $_->set_table();
        my $r = $_->SUPER::feed($info);
        push(@feeds,$r) if($r);
    }
    return(\@feeds);
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

=head1 NAME

 CIF::Archive::DataType::Plugin::Email - CIF::Archive plugin for indexing internet messages

=head1 SEE ALSO

 http://code.google.com/p/collective-intelligence-framework/
 CIF::Archive

=head1 AUTHOR

 Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

 Copyright (C) 2011 by Wes Young (claimid.com/wesyoung)
 Copyright (C) 2011 by the Trustee's of Indiana University (www.iu.edu)
 Copyright (C) 2011 by the REN-ISAC (www.ren-isac.net)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
