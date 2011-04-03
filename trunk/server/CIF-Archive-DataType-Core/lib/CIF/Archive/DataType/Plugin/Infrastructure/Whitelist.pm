package CIF::Archive::DataType::Plugin::Infrastructure::Whitelist;

use strict;
use warnings;

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /whitelist/);
    return('infrastructure_whitelist');
}

sub search_feed {
    my $class = shift;
    my $info = shift;
    my $dt = $info->{'detecttime'};
    my $max = $info->{'maxrecords'};    

    my $ret = $class->retrieve_from_sql(qq{
        detecttime >= '$dt'
        ORDER BY id DESC
        LIMIT $max
    });
    return unless($ret);
    return(@$ret);
}

1;
