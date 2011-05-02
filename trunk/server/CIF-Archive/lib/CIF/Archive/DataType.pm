package CIF::Archive::DataType;
use base 'CIF::DBI';

use Module::Pluggable require => 1, except => qr/::Plugin::\S+::/;

__PACKAGE__->set_sql('feed' => qq{
    SELECT * FROM __TABLE__
    WHERE detecttime >= ?
    AND severity >= ?
    AND restriction <= ?
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

sub prepare {
    my $class = shift;
    my $info = shift;

    my @bits = split(/::/,lc($class));
    my $t = $bits[$#bits];
    return(1) if($info->{'impact'} =~ /$t$/);
    return(0);
}

sub set_table {
    my $class = shift;

    my @bits = split(/::/,lc($class));
    my $t = $bits[$#bits];
    if($bits[$#bits-1] ne 'plugin'){
        $t = $bits[$#bits-1].'_'.$bits[$#bits];
    }
    return $class->table($t);
}

sub feed {
    my $class = shift;
    my $info = shift;

    my $key = $info->{'key'};
    my $max = $info->{'maxrecords'} || 10000;
    my $restriction = $info->{'restriction'} || 'need-to-know';
    my $severity = $info->{'severity'} || 'medium';

    my @bits = split(/::/,lc($class));
    my $feed_name = '';
    if($bits[$#bits-1] eq 'plugin'){
        $feed_name = $bits[$#bits];
    } else {
        $feed_name = $bits[$#bits].' '.$bits[$#bits-1];
    }

    my $sth = $class->sql_feed();
    $sth->execute($info->{'detecttime'},$severity,$restriction,$max);
    my $ret = $sth->fetchall_hash();
    return(undef) unless(@$ret);
    my @recs = @$ret;
    
    # declassify what we can
    my $hash;
    foreach (@recs){
        if($hash->{$_->{$key}}){
            if($_->{'restriction'} eq 'private'){
                next unless($_->{'restriction'} eq 'need-to-know');
            }
        }
        $hash->{$_->{$key}} = $_;
    }
    @recs = map { $hash->{$_} } keys(%$hash);

    # sort it out
    @recs = sort { $a->{'detecttime'} cmp $b->{'detecttime'} } @recs;
    my $feed = {
        feed    => {
            title   => $feed_name,
            entry   => \@recs,
        }
    };
    return($feed);
}

sub check_params {
    my ($self,$tests,$info) = @_;

    foreach my $key (keys %$info){
        if(exists($tests->{$key})){
            my $test = $tests->{$key};
            next unless($info->{$key});
            unless($info->{$key} =~ m/$test/){
                return(undef,'invaild value for '.$key.': '.$info->{$key});
            }
        }
    }
    return(1);
}

sub lookup {
    my $class = shift;
    my @args = @_;
    return(undef) unless(@args);

    my $sth = $class->sql_lookup();
    my $r = $sth->execute(@args);
    my $ret = $sth->fetchall_hash();
    return($ret);
}

1;
