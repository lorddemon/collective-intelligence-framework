package CIF::Client::Plugin::Csv;

use Regexp::Common qw/net/;

sub type { return 'output'; }

sub write_out {
    my $self = shift;
    my $config = shift;
    my @array = @_;
    my @header = keys(%{$array[0]});
    @header = sort { $a cmp $b } @header;
    my $body = '';
    foreach my $a (@array){
        delete($a->{'message'}); 
        $body .= join(',',map { $a->{$_} ? $a->{$_} : ''} @header)."\n";
    }
    my $text = '# '.join(',',@header);
    $text .= "\n".$body;
    return $text;
}
1;
