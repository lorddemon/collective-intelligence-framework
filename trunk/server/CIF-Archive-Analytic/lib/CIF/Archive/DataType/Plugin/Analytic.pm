package CIF::Archive::DataType::Plugin::Analytic;
use base 'CIF::Archive::DataType';

use 5.008008;
use strict;
use warnings;

__PACKAGE__->table('analytic');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid description startid endid source created/);
__PACKAGE__->columns(Essential => qw/id uuid startid endid created/);
__PACKAGE__->sequence('analytic_id_seq');

sub prepare {
    my $class = shift;
    my $info = shift;

    return unless($info->{'description'});
    return unless($info->{'description'} =~ /analytic/);
    return(1);
}

sub insert {
    my $class = shift;
    my $info = shift;

    my $id = $class->SUPER::insert({
        uuid        => $info->{'uuid'},
        startid     => $info->{'startid'},
        endid       => $info->{'endid'},
        description => $info->{'description'},
        source      => $info->{'source'},
    });
    return($id);
}
    
## TODO -- check this and see what the max value is
sub last_run {
    my $class = shift;

    my $sql = qq{
        1=1
        ORDER BY id DESC
        LIMIT 1
    };
    my @recs = $class->retrieve_from_sql($sql);
    unless(@recs){
        require CIF::Archive;
        my $ret = CIF::Archive->minimum_value_of('id');
        return($ret-1);
    }
    return($recs[0]->endid());
}


1;
