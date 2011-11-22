package CIF::Archive::DataType::Plugin::Feed::Search;
use base 'CIF::Archive::DataType::Plugin::Feed';

__PACKAGE__->table('feed_search');

sub prepare {
    my $class = shift;
    my $info = shift;
    return(0) unless($info->{'impact'} =~ /search/);
    return(1);
}

__PACKAGE__->set_sql('feed' => qq{
    SELECT COUNT(description),description,severity,confidence,restriction
    FROM
        (SELECT DISTINCT ON (source,description,severity,confidence,restriction) * FROM __TABLE__) AS t1
    WHERE 
        t1.detecttime >= ?
    GROUP BY
        description,severity,confidence,restriction
    ORDER BY 
        count desc,description asc, severity desc, confidence desc, restriction desc
    LIMIT ?
});
1;
