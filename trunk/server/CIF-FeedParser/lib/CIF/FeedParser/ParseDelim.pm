package CIF::FeedParser::ParseDelim;

use strict;
use warnings;

sub parse {
    my $f = shift;
    my $content = shift;
    
    my $split = shift;
    my @lines = split(/\n/,$content);
    my @cols = split(',',$f->{'values'});
    my @array;
    foreach(@lines){
        next if(/^(#|$)/);
        my @m = split($split,$_);
        my $h;
        foreach (0 ... $#cols){
            $h->{$cols[$_]} = $m[$_];
        }
        map { $h->{$_} = $f->{$_} } keys %$f;
        push(@array,$h);
    }
    return(@array);

}

1;
