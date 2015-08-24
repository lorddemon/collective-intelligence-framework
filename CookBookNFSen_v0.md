
```
#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use CIF::Client;
use JSON;
use Net::CIDR;
use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;
use Text::Table;

# set the default configs
my $config = $ENV{'HOME'}.'/.cif';

# these get passed to the REST->GET() line, default feed fetch
my $feed = 'infrastructure';
my $severity = 'medium';
my $default_restriction = 'privileged';

# jsut for the demo, IP's found in the Spamhaus DROP list (eg: infrastructure/network feed)
my @ips = (
    '170.25.0.1',
    '46.252.130.1',
    '198.12.32.1',
);

# setup the client connection based off ~/.cif
my ($client,$err) = CIF::Client->new({
    config  => $config,
});

# redirect to syslog if necessary
die($err) unless($client);

# GET the feed
$client->GET($feed,$severity,$default_restriction);

# make sure apache gives us a response code of 200 else fail
die('request failed with code: '.$client->responseCode()."\n\n".$client->responseContent()) unless($client->responseCode == 200);

# the response text will be json output, the client auto-decodes any gzip or base64 encoding of the feed
my $json = $client->responseContent();
# convert from json to a perl hashref
$json = from_json($json);

# make sure we have data to process
if($json->{'data'}->{'result'}){
    my @items = @{$json->{'data'}->{'result'}->{'feed'}->{'items'}};
    my $addrs;

    # map out a hashref for quick indexing of our feed based on ip-address (we use this later)
    map { $addrs->{$_->{'address'}} = $_; } @items;
    my @matches;
    foreach(@items){
        my $a = $_->{'address'};
        # check to see if address is already a cidr, if not append the /32 to it for Net::CIDR::cidrlookup
        unless($a =~ /^$RE{'net'}{'CIDR'}{'IPv4'}$/){
            $a .= '/32';
        }
        # try to match the address against each of our cidr lists (infrastructure api gives us everything
        # /32's and lower (eg: /24, /23, etc)
        foreach my $ip (@ips){
            if(match($ip,$a)){
                # if we get a match, push the match and what the address we found was into the matches array
                push(@matches,{ address => $ip, match => $addrs->{$_->{'address'}}});
            }
        }
    }
    
    # for neater output
    my $t = Text::Table->new('address','impact','description','severity');
    foreach(@matches){
        my $m = $_->{'match'};
        $t->load([$m->{'address'},$m->{'impact'},$m->{'description'},$m->{'severity'}]);
    }
    print $t."\n";
    # uncommenting this will show you the results of the dataset
    # warn Dumper(@matches)

}

sub match {
    my ($addr,@list) = (shift,@_);
    # make sure we're handed an actual IPv4 address, or cidrlookup croaks
    return undef unless($addr && $addr =~ /^$RE{'net'}{'IPv4'}/);
    my $ret = eval { Net::CIDR::cidrlookup($addr,@list) };
    return($ret);
}
```