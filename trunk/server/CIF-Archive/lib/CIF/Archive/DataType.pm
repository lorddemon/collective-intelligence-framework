package CIF::Archive::DataType;
use base 'CIF::DBI';

use strict;
use warnings;

use Module::Pluggable require => 1, except => qr/::Plugin::\S+::/;

sub prepare { return(0) };

__PACKAGE__->set_sql('feed' => qq{
    SELECT * FROM __TABLE__
    WHERE detecttime >= ?
    AND severity >= ?
    AND restriction <= ?
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

sub feed {
    my $class = shift;
    my $info = shift;

    my $key = $info->{'key'};
    my $max = $info->{'maxrecords'} || 10000;
    my $restriction = $info->{'restriction'} || 'need-to-know';
    my $severity = $info->{'severity'} || 'medium';

    my $sth = $class->sql_feed();
    $sth->execute($info->{'detecttime'},$severity,$restriction,$max);
    my $ret = $sth->fetchall_hash();
    return(undef) unless($ret);
    my @recs = @$ret;
    
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
    return(\@recs);
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

    my $sth = $class->sql_lookup();
    my $r = $sth->execute(@args);
    my $ret = $sth->fetchall_hash();
    return($ret);
}

1;
