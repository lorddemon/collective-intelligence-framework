package CIF::Client::Plugin::Snort;

use Snort::Rule;
use Regexp::Common qw/net/;
use Data::Dumper;

sub type { return 'output'; }

sub write_out {
    my $self = shift;
    my $config = shift;
    my $feed = shift;
    my @array = @{$feed->{'feed'}->{'entry'}};
    return '' unless(exists($array[0]->{'address'}));
    my $sid = ($config->{'snortsid'}) ? $config->{'snortsid'} : 1;
    my $rules = '';
    foreach (@array){
        #next unless($_->{'address'} =~ /^$RE{'net'}{'IPv4'}/);
        next unless($_->{'address'});
        if(exists($_->{'rdata'})){
            $_->{'portlist'} = 53;
        }
        my $portlist = ($_->{'portlist'}) ? $_->{'portlist'} : 'any';

        my $r = Snort::Rule->new(
            -action => 'alert',
            -proto  => 'ip',
            -src    => 'any',
            -sport  => 'any',
            -dst    => $_->{'address'},
            -dport  => $portlist,
            -dir    => '->',
        );
        $r->opts('msg',$_->{'restriction'}.' - '.$_->{'description'});
        $r->opts('threshold','type limit,track by_src,count 1,seconds 3600');
        $r->opts('sid',$sid++);
        $r->opts('reference',$_->{'alternativeid'}) if($_->{'alternativeid'});
        $rules .= $r->string()."\n";
    }
    return $rules;
}
1;
