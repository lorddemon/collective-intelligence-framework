package CIF::Client::Plugin::Csv;

use Regexp::Common qw/net/;

sub type { return 'output'; }

sub write_out {
    my $self = shift;
    my $config = shift;
    my $feed = shift;
    my @array = @{$feed->{'feed'}->{'entry'}};
    #my @header = keys(%{$array[0]});
    my @header;
    # skip things like arrays and hashrefs for now
    foreach (keys %{$array[0]}){
        next unless(!ref($array[0]{$_}));
        push(@header,$_);
    }
    @header = sort { $a cmp $b } @header;
    my $body = '';
    foreach my $a (@array){
        delete($a->{'message'}); 
        # the !ref() bits skip things like arrays and hashref's for now...
        $body .= join(',',map { ($a->{$_} && !ref($a->{$_})) ? $a->{$_} : ''} @header)."\n";
    }
    my $text = '# '.join(',',@header);
    $text .= "\n".$body;
    return $text;
}
1;
