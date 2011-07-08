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

    # first check to see if there are any values in the database
    my $min_val = CIF::Archive->minimum_value_of('id');
    return unless($min_val);
    # we have at-least one value

    # find the max value
    # there should be at-least one
    my $max_val = CIF::Archive->maximum_value_of('id');

    # now populate the two
    $min_val = CIF::Archive->retrieve($min_val);
    $max_val = CIF::Archive->retrieve($max_val);

    my $min_uuid = $min_val->uuid();
    my $max_uuid = $max_val->uuid();

    # here's where we start the transaction lock
    # it sticks till we move out of scope / exit the function
    local $class->db_Main->{'AutoCommit'};

    # we have a value in the db
    # now check out the last analytics run
    my @recs = $class->search__last_run();
    
    my ($startid,$endid);
    ## TODO -- test start -- end when there has been a last run
    ## cif -q goog.com

    if($#recs > -1){
        # if our last value was an anlaytics run return
        return if($recs[0]->endid() == $recs[0]->startid() && $recs[0]->uuid->uuid() eq $max_uuid);
        $startid = $recs[0]->endid() + 1;
    } else {
        $startid = $min_val->id();
    }

    # if max - start is less than our maximum record limit
    if(($max_val->id() - $startid) < $info->{'max'}){
        # set the endid
        $endid = ($startid + ($max_val->id() - $startid));
    } else {
        $endid = $startid + $info->{'max'};
    }
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

__PACKAGE__->set_sql('_last_run'  => qq{
    LOCK TABLE __TABLE__ IN ACCESS EXCLUSIVE MODE;
    SELECT __ESSENTIAL__
    FROM __TABLE__
    WHERE 1=1
    ORDER BY id DESC
    LIMIT 1;
});



1;
