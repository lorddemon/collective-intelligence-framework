# Introduction #

Before you begin, you'll need to setup your ~/.cif config as follows:
```
[client]
host = https://www.example.com:443/api
apikey = xxxxxxx
timeout = 60
```

# Details #
  1. First, ensure you've installed the [PerlClient](ClientInstallSourcePerl_v0.md)
  1. We create a new instance of [CIF::Client](http://search.cpan.org/~saxjazman/CIF-Client/lib/CIF/Client.pm)
```
my ($client,$err) = CIF::Client->new({ 
    config      => '/home/wes/.cif',
});
```
  1. This set's up a new instance of REST::Client (a simple libwww wrapper).
  1. Now we query the API:
```
my $feed = $client->GET(
        query       => $q,
);
die('request failed with code: '.$client->responseCode()."\n\n".$client->responseContent()) unless($client->responseCode == 200);
```
  1. The server will return a hash reference that mostly resembles an [ATOM](http://tools.ietf.org/html/rfc4287) structure which looks like (using Data::Dumper):
```
$VAR1 = {
          'status' => 200,
          'data' => {
                      'feed' => {
                                  'source' => '19ecedcc4b9189f8c2b3bc2d1ad6f5d49c181d1d',
                                  'entry' => [
                                               {
                                                 'protocol' => undef,
                                                 'source' => '9658c1e0-81c2-31e6-b39c-0e2fe55ae1df',
                                                 'purpose' => 'mitigation',
                                                 'uuid' => '5a407066-378f-5454-81b5-83540c68989c',
                                                 'portlist' => undef,
                                                 'alternativeid' => undef,
                                                 'detecttime' => '2011-10-05T00:00:00Z',
                                                 'address' => 'example.com',
                                                 'guid' => '0146a333-cfa7-3464-b890-0e37b96a741d',
                                                 'alternativeid_restriction' => undef,
                                                 'severity' => 'low',
                                                 'rdata' => undef,
                                                 'description' => 'search example.com',
                                                 'relatedid' => undef,
                                                 'type' => 'A',
                                                 'confidence' => '50',
                                                 'restriction' => 'private',
                                                 'impact' => 'search'
                                               }
                                             ],
                                  'group_map' => {
                                                   '8c864306-d21a-37b1-8705-746a786719bf' => 'everyone',
                                                 },
                                  'detecttime' => '2011-10-05T09:52:29Z',
                                  'restriction' => 'private',
                                  'description' => 'search example.com'
                                }
                    },
          'message' => ''
        };
```
  1. The result records from the query are embedded in the "entry" object.
```
my @recs = @{$feed->{'feed'}->{'entry'}};
```
  1. Note that the client does some magic to convert the IODEF formated objects into simple key-pair values. To leverage the more complex format (used in describing complex infrastructure) see the AdvancedAPI.

# Examples #
  1. Rendering a text based table:
```
my ($client,$err) = CIF::Client->new({ 
    config      => '/home/wes/.cif',
});
my $feed = $client->GET(
        query       => $_,
);
die('request failed with code: '.$client->responseCode()."\n\n".$client->responseContent()) unless($client->responseCode == 200);

my @recs = @{$feed->{'feed'}->{'entry'}};

require CIF::Client::Plugin::Table;
my $text = CIF::Client::Plugin::Table->write_out($client,$feed);
print $text;
```
  1. Rendering an HTML based table:
```
require CIF::Client::Plugin::Html;
my $html = CIF::Client::Plugin::Html->write_out($client,$feed);
print $html;
```
  1. How the [CLI](http://code.google.com/p/collective-intelligence-framework/source/browse/trunk/client/perl/CIF-Client/script/cif) works
```
my ($client,$err) = CIF::Client->new({ 
    config      => $c,
    fields      => $fields,
    nolog       => $nolog,
    verify_tls  => $verify_tls,
    guid        => $guid,
});

die($err) unless($client);

my @q = split(/\,/,$query);
foreach (@q){
    my $feed = $client->GET(
        query       => $_,
        severity    => $severity,
        restriction => $restriction,
        nolog       => $nolog,
        nomap       => $nomap,
        confidence  => $confidence,
        limit       => $limit,
    );
    die('request failed with code: '.$client->responseCode()."\n\n".$client->responseContent()) unless($client->responseCode == 200);
   
    my $plug = 'CIF::Client::Plugin::'.ucfirst($plugin);
    eval "require $plug";
    die($@) if($@);
    $feed->{'query'} = $_;
    print $plug->write_out($client,$feed,$summary) if($feed->{'feed'});
}
```
  1. Getting data within [RT](http://code.google.com/p/collective-intelligence-framework/source/browse/trunk/misc/rt-cifminimal/lib/RT/CIFMinimal.pm#13)
  1. Another [RT Example](http://code.google.com/p/collective-intelligence-framework/source/browse/trunk/misc/rt-cifminimal/html/Minimal/Display.html)
  1. [Example Snort Output Plugin](http://code.google.com/p/collective-intelligence-framework/source/browse/trunk/client/perl/CIF-Client/lib/CIF/Client/Plugin/Snort.pm)
```
package CIF::Client::Plugin::Snort;
use base 'CIF::Client::Plugin::Output';

use Snort::Rule;

sub write_out {
    my $self = shift;
    my $config = shift;
    my $feed = shift;
    my @array = @{$feed->{'feed'}->{'entry'}};
    return '' unless(exists($array[0]->{'address'}));
    my $sid = ($config->{'snortsid'}) ? $config->{'snortsid'} : 1;
    my $rules = '';
    foreach (@array){
        next unless($_->{'address'});
        if(exists($_->{'rdata'})){
            $_->{'portlist'} = 53;
        }
        my $portlist = ($_->{'portlist'}) ? $_->{'portlist'} : 'any';

        my $priority = 1;
        for(lc($_->{'severity'})){
            $priority = 5 if(/medium/);
            $priority = 9 if(/high/);
        }

        my $r = Snort::Rule->new(
            -action => 'alert',
            -proto  => 'ip',
            -src    => 'any',
            -sport  => 'any',
            -dst    => $_->{'address'},
            -dport  => $portlist,
            -dir    => '->',
        );
        $r->opts('msg',$_->{'restriction'}.' - '.$_->{'impact'}.' '.$_->{'description'});
        $r->opts('threshold','type limit,track by_src,count 1,seconds 3600');
        $r->opts('sid',$sid++);
        $r->opts('reference',$_->{'alternativeid'}) if($_->{'alternativeid'});
        $r->opts('priority',$priority);
        $rules .= $r->string()."\n";
    }
    return $rules;
}
1;
```