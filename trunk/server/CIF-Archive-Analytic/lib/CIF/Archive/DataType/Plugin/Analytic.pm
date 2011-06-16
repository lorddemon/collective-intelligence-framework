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

sub lookup { return; }

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

sub feed { return(0); }
    
sub next_run {
    my $class = shift;
    my $info = shift;

    # need to do this outside of the transaction lock
    require CIF::Archive;
    my $last_val = CIF::Archive->minimum_value_of('id') || $class->sql_lastval->select_val();
    my $max_val = CIF::Archive->maximum_value_of('id');

    local $class->db_Main->{'AutoCommit'};
    my @recs = $class->search__last_run();

    if($#recs > -1){
        $last_val = $recs[0]->endid();
    }
    my ($startid,$endid) = 0;
    return if($max_val && $max_val == $last_val);
    $startid = $last_val + 1;
    $endid = (($max_val - $startid) < $info->{'max'}) ? ($startid + ($max_val - $startid)) : $startid + $info->{'max'};
    warn $startid.' - '.$endid if($::debug);

    my $ret = CIF::Archive->insert({
        description => $info->{'description'} || 'analytics run start: '.($endid - $startid).' records',
        startid     => $startid,
        endid       => $endid,
    });
    return({
        startid => $startid,
        endid   => $endid,
    });
}

sub _do_transaction {
    my $class = shift;
    my ($code) = @_;
    local $class->db_Main->{'AutoCommit'};
    my @recs = eval { $code->() };
    if($@){
        my $err = $@;
        eval { $class->dbi_rollback() };
        die($err);
    }
    return(\@recs);
}

__PACKAGE__->set_sql('_last_run'  => qq{
    LOCK TABLE __TABLE__ IN ACCESS EXCLUSIVE MODE;
    SELECT __ESSENTIAL__
    FROM __TABLE__
    WHERE 1=1
    ORDER BY id DESC
    LIMIT 1;
});



1;
