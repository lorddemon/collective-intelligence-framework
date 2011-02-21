package CIF::FeedParser::ParseRss;

use strict;
use warnings;
use XML::RSS;

sub parse {
    my $f = shift;
    my $content = shift;
    
    my $rss = XML::RSS->new();
    $rss->parse($content);
    my @array;
    foreach my $item (@{$rss->{items}}){
        my $h;
        foreach my $key (keys %$item){
            if(my $r = $f->{'regex_'.$key}){
                my @m = ($item->{$key} =~ /$r/);
                my @cols = split(',',$f->{'regex_'.$key.'_values'});
                foreach (0 ... $#cols){
                    $h->{$cols[$_]} = $m[$_];
                }
            }
        }
        map { $h->{$_} = $f->{$_} } keys %$f;
        push(@array,$h);
    }
    return(@array);

}

1;
