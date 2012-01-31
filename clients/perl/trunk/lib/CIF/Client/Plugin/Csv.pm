package CIF::Client::Plugin::Csv;

use Regexp::Common qw/net/;

sub type { return 'output'; }

sub write_out {
    my $self = shift;
    my $config = shift;
    my $feed = shift;
    my @array = @{$feed->{'feed'}->{'entry'}};
    
    $config = $config->{'config'};
    my $nosep = $config->{'csv_noseperator'};
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
        # there's no clean way to do this just yet
        foreach (@header){
            if($a->{$_} && !ref($a->{$_})){
                # deal with , in the field
                if($nosep){
                    $a->{$_} =~ s/,/ /g;
                    $a->{$_} =~ s/\s+/ /g;
                } else {
                    $a->{$_} =~ s/,/_/g;
                }
                # strip out non-ascii (typically unicode) chars
                # there are better ways to do this, but this works for now
                $a->{$_} =~ tr/\000-\177//cd;
            }
        }
        # the !ref() bits skip things like arrays and hashref's for now...
        $body .= join(',', map { ($a->{$_} && !ref($a->{$_})) ? $a->{$_} : ''} @header)."\n";
    }
    my $text = '# '.join(',',@header);
    $text .= "\n".$body;

    return $text;
}
1;
